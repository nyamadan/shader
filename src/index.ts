import { watch } from "chokidar";
import { writeFile, readFileSync, unlink, write, mkdir } from "fs";
import { promisify } from "util";
// eslint-disable-next-line no-unused-vars
import { compileFile, Includer } from "node-shader-compiler";
import { spawnSync } from "child_process";
import { ArgumentParser } from "argparse";
import path from "path";
import glob from "glob";
import minimatch from "minimatch";
import tmp from "tmp";

const pkg = JSON.parse(readFileSync("package.json", { encoding: "utf8" }));

const parser = new ArgumentParser({
  version: pkg.version,
  addHelp: true,
  description: pkg.description,
});
parser.addArgument(["-V", "--glsl-version"], {
  help: "Specify the version of GLSL to output.",
  metavar: ["VERSION"],
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
parser.addArgument(["-D", "--define"], {
  metavar: ["KEY", "VALUE"],
  help: "Define symbols",
  type: "string",
  nargs: 2,
  action: "append",
  defaultValue: []
});

const args = parser.parseArgs();
const argEnableOptimization: boolean = args.enable_optimization;
const argUseGlslEs: boolean = args.es;
const argGlslVersion: number = args.glsl_version;
const argIsWatchMode: boolean = args.watch;
const argDefines: { [key: string]: string } = {};
for (const [key, value] of args.define as ReadonlyArray<[string,string]>) {
  argDefines[key] = value;
}

let processingCount = 0;

const dependencies = new Map<string, Set<string>>();

const includer: Includer = (header, includerPath, depth) => {
  if (includerPath == null || depth == null) {
    return null;
  }

  const fileDir = path.dirname(includerPath);
  const filePath = path.join(fileDir, header);

  if (depth === 1) {
    dependencies.set(includerPath, new Set());
  }

  const set = dependencies.get(includerPath);
  set?.add(filePath);

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
};

const wait = (ms: number) => new Promise((resolve) => setTimeout(resolve, ms));

const buildWithOption = async (
  file: string,
  version: number,
  es: boolean,
  enableOptimization: boolean,
  defines: {[key:string]: string}
) => {
  console.log(`[node-shader-compiler]:Compile:${file}`);

  await wait(100);

  const { isLinked, sourceCode, shaderLog, binarySpirv } = compileFile(file, {
    includer,
    version,
    es,
    defines,
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

    const option = ["--output", distname, f1, "--version", version.toString()];

    if (es) {
      option.push("--es");
    } else {
      option.push("--no-es");
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
const buildFile = async (file: string) => {
  processingCount++;
  if (processingCount === 1) {
    console.log("[node-shader-compiler]:BeginCompile");
  }
  try {
    await buildWithOption(file, argGlslVersion, argUseGlslEs, argEnableOptimization, argDefines);
  } catch (e) {
    console.error(e);
  }
  processingCount--;
  if (processingCount === 0) {
    console.log("[node-shader-compiler]:EndCompile");
  }
};

const update = async (file: string) => {
  if (minimatch(file, "**/*.frag.glsl")) {
    await buildFile(file);
    return;
  }

  const tasks: Promise<void>[] = [];
  for (const [parent, children] of dependencies) {
    if (children.has(file)) {
      tasks.push(buildFile(parent));
    }
  }
  await Promise.all(tasks);
};

if (argIsWatchMode) {
  const watcher = watch(["**/*.glsl"], {
    ignored: ["node_modules/**/*.glsl", "dist/**/*.glsl"],
    ignoreInitial: false,
  });

  watcher.on("add", update);
  watcher.on("change", update);
} else {
  (async () => {
    const files = await promisify(glob)("**/*.frag.glsl", {
      ignore: ["node_modules/**/*.glsl", "dist/**/*.glsl"],
    });

    await Promise.all(files.map((file: string) => update(file)));
  })();
}
