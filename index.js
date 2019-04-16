const glslifyImport = require("glslify-import");
const glslify = require("glslify");
const watch = require("glob-watcher");
const path = require("path");
const { readFile, writeFile, mkdir } = require("fs");
const { promisify } = require("util");

/**
 * @type {ReadonlyArray<string>}
 */
const pattern = ["**/*.glsl"];

const ignored = ["node_modules", "dist", "lib"];

const ignoreInitial = false;

const options = { ignored, ignoreInitial };

const watcher = watch(pattern, options);

/**
 * Build file.
 *
 * @param {string} file
 */
const build = async (file) => {
  console.log(`read: ${file}`);
  await new Promise((resolve) => setTimeout(resolve, 100));
  const data = await promisify(readFile)(file, { encoding: "utf8" });
  const imported = glslifyImport(file, data);
  const source = glslify(imported);
  const ext = path.extname(file);
  const basename = path.basename(file, ext);
  const distDir = path
    .dirname(file)
    .split(path.sep)
    .map((x, i) => (i == 0 ? "dist" : x))
    .join(path.sep);
  await promisify(mkdir)(distDir, { recursive: true });
  const distname = path.join(distDir, `${basename}${ext}`);
  await promisify(writeFile)(distname, source);
  console.log(`wrote: ${distname}`);
};

watcher.on("add", build);
watcher.on("change", build);
