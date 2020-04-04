const { watch } = require("chokidar");
const { writeFile, readFileSync, unlink, write, mkdir } = require("fs");
const { promisify } = require("util");
const { compileFile } = require("node-shader-compiler");
const { spawnSync } = require("child_process");
const { ArgumentParser } = require("argparse");
const glob = require("glob");
const minimatch = require("minimatch");
const path = require("path");
const tmp = require("tmp");

const package = JSON.parse(readFileSync("package.json", { encoding: "utf8" }));

const parser = new ArgumentParser({
  version: package.version,
  addHelp: true,
  description: package.description,
});
parser.addArgument(["-V", "--glsl-version"], {
  help: "Specify the version of GLSL to output.",
  type: "int",
  required: true,
});
parser.addArgument(["--es"], {
  help: "Outputs the GLSL ES.",
  action: "storeTrue",
});
parser.addArgument(["-O", "--enable-optimization"], {
  help: "Optimize performance.",
  action: "storeTrue",
});
parser.addArgument(["-w", "--watch"], {
  help: "Watch files.",
  action: "storeTrue",
});

const args = parser.parseArgs();

/**
 * @type {boolean}
 */
const enableOptimization = args.enable_optimization;
/**
 * @type {boolean}
 */
const useGlslEs = args.es;
/**
 * @type {number}
 */
const glslVersion = args.glsl_version;

/**
 * @type {boolean}
 */
const isWatchMode = args.watch;

let processingCount = 0;

/**
 * @type {Map<string, Set<string>>}
 */
const dependencies = new Map();

/**
 *
 * @param {string} header
 * @param {string | null} includerPath
 * @param {number | null} depth
 * @returns {{header: string, content: string} | null}
 */
function includer(header, includerPath, depth) {
  if (includerPath == null || depth == null) {
    return null;
  }

  const fileDir = path.dirname(includerPath);
  const filePath = path.join(fileDir, header);

  if (depth === 1) {
    dependencies.set(includerPath, new Set());
  }

  const set = dependencies.get(includerPath);
  set.add(filePath);

  try {
    const source = readFileSync(filePath, { encoding: "utf8" });
    return {
      header: filePath,
      content: source,
    };
  } catch (e) {
    console.error(e);
    return null;
  }
}

/**
 *
 * @param {number} ms
 */
const wait = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

/**
 *
 * @param {string} file
 * @param {number} version
 * @param {boolean} es
 * @param {boolean} enableOptimization
 */
const buildWithOption = async (file, version, es, enableOptimization) => {
  console.log(`[node-shader-compiler]:Compile:${file}`);

  await wait(100);

  const { isLinked, sourceCode, shaderLog, binarySpirv } = compileFile(file, {
    includer,
    version,
    es,
    enableBinarySpirv: enableOptimization,
    disableSourceCode: enableOptimization,
  });

  if (!isLinked) {
    console.error(shaderLog);
    return;
  }

  const ext = path.extname(file);
  const basename = path.basename(file, ext);
  const distDir = path
    .dirname(file)
    .split(path.sep)
    .map((x, i) => (i == 0 ? "dist" : x))
    .join(path.sep);
  await promisify(mkdir)(distDir, { recursive: true });
  const distname = path.join(distDir, `${basename}${ext}`);

  if (enableOptimization) {
    const f0 = tmp.fileSync();

    await promisify(write)(f0.fd, Buffer.from(binarySpirv.buffer));

    const f1 = tmp.tmpNameSync();

    const optResult = spawnSync("spirv-opt", ["-O", f0.name, "-o", f1], {
      encoding: "utf8",
    });

    f0.removeCallback();

    if (optResult.error) {
      console.error(optResult.error);
      return;
    }

    if (optResult.stderr) {
      console.error(optResult.stderr);
      return;
    }

    const option = ["--output", distname, f1, "--version", version];

    if (es) {
      option.push("--es");
    }

    const crossResult = spawnSync("spirv-cross", option, { encoding: "utf8" });
    await promisify(unlink)(f1);

    if (crossResult.error) {
      console.error(crossResult.error);
      return;
    }

    if (crossResult.stderr) {
      console.error(crossResult.stderr);
      return;
    }
  } else {
    await promisify(writeFile)(distname, sourceCode);
  }

  console.log(`[node-shader-compiler]:Compiled:${distname}`);
};

/**
 * @param {string} file
 */
const buildFile = async (file) => {
  processingCount++;
  if (processingCount === 1) {
    console.log("[node-shader-compiler]:BeginCompile");
  }
  try {
    await buildWithOption(file, glslVersion, useGlslEs, enableOptimization);
  } catch (e) {
    console.error(e);
  }
  processingCount--;
  if (processingCount === 0) {
    console.log("[node-shader-compiler]:EndCompile");
  }
};

const update = async (file) => {
  if (!minimatch(file, "**/lib/**/*.glsl")) {
    await buildFile(file);
    return;
  }

  for (const [parent, children] of dependencies) {
    if (children.has(file)) {
      await buildFile(parent);
    }
  }
};

if (!isWatchMode) {
  (async () => {
    const files = await promisify(glob)("**/*.glsl", {
      ignore: ["node_modules/**/*.glsl", "dist/**/*.glsl", "**/lib/**/*.glsl"],
    });

    await Promise.all(files.map(file => update(file)));
  })();
  return;
}

const watcher = watch(["**/*.glsl"], {
  ignored: ["node_modules/**/*.glsl", "dist/**/*.glsl"],
  ignoreInitial: false,
});

watcher.on("add", update);
watcher.on("change", update);
