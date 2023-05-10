const path = require('path');
const esbuild = require('esbuild');
const { execSync } = require("child_process");
const glob  = require('glob').sync

// Glob plugin derived from:
// https://github.com/thomaschaaf/esbuild-plugin-import-glob
// https://github.com/xiaohui-zhangxh/jsbundling-rails/commit/b15025dcc20f664b2b0eb238915991afdbc7cb58
const ImportGlobPlugin = () => ({
  name: 'require-context',
  setup: (build) => {
    build.onResolve({ filter: /\*/ }, async (args) => {
      console.log('resolveDir', args.resolveDir)
      if (args.resolveDir === '') {
        return; // Ignore unresolvable paths
      }
      console.log('path', args.path)
      return {
        path: args.path,
        namespace: 'import-glob',
        pluginData: {
          resolveDir: args.resolveDir,
        },
      };
    });

    build.onLoad({ filter: /.*/, namespace: 'import-glob' }, async (args) => {
      const files = (
        glob(args.path, {
          cwd: args.pluginData.resolveDir,
        })
      ).sort();

      let importerCode = `
        ${files
          .map((module, index) => `import * as module${index} from './${module}'`)
          .join(';')}
        export default [${files
          .map((module, index) => `module${index}.default`)
          .join(',')}];
        export const context = {
          ${files.map((module, index) => `'${module}': module${index}.default`).join(',')}
        }
      `;

      return { contents: importerCode, resolveDir: args.pluginData.resolveDir };
    });
  },
});

const watchDirectories = [
  "./app/javascript/**/*.js",
  "./app/views/**/*.html.erb",
  "./app/assets/stylesheets/*.css",
  "./app/assets/stylesheets/*.scss"
]
let themeFile = ""
if (process.env.THEME) {
  themeFile = execSync(`bundle exec bin/theme javascript ${process.env.THEME}`).toString().trim()
}

// Could also swap to packs?
const otherEntrypoints = {}
glob("app/javascript/entrypoints/**/*.js")
  .forEach((file) => {
  	// strips app/javascript/entrypoints from the key.
    const key = path.join(path.dirname(file), path.basename(file)).split(path.sep + "entrypoints" + path.sep)[1]
    const value = "." + path.sep + path.join(path.dirname(file), path.basename(file), path.extname(file))
    otherEntrypoints[key] = value
  });

async function rebuild() {
  const chokidar = require('chokidar')
  const http = require('http')
  const clients = []

  http.createServer((req, res) => {
    return clients.push(
        res.writeHead(200, {
          "Content-Type": "text/event-stream",
          "Cache-Control": "no-cache",
          "Access-Control-Allow-Origin": "*",
          Connection: "keep-alive",
        }),
    );
  }).listen(8082);

  let result = await esbuild.build({
    entryPoints: {
      ...otherEntrypoints,
      "application": path.join(process.cwd(), "app/javascript/application.js"),
      "intl-tel-input-utils": path.join(process.cwd(), "app/javascript/intl-tel-input-utils.js"),
      [`application.${process.env.THEME}`]: themeFile,
    },
    define: {
      global: "window"
    },
    bundle: true,
    // ESM + Splitting will only work if the script is type="module"
    // splitting: true,
    // format: "esm",
    format: "iife",
    incremental: true,
    banner: {
      js: ' (() => new EventSource("http://localhost:8082").onmessage = () => location.reload())();',
    },
    sourcemap: true,
    outdir: path.join(process.cwd(), "app/assets/builds"),
    loader: {
      ".png": "file",
      ".jpg": "file",
      ".svg": "file",
      ".woff": "file",
      ".woff2": "file",
      ".ttf": "file",
      ".eot": "file",
    },
    watch: process.argv.includes("--watch"),
    plugins: [
      ImportGlobPlugin()
    ],
    // TODO: Silencing warnings until the charset warning is fixed.
    logLevel: 'error',
  });

  chokidar.watch(watchDirectories).on('all', (event, path) => {
    if (path.includes("javascript")) {
      result.rebuild()
    }
    clients.forEach((res) => res.write('data: update\n\n'))
    clients.length = 0
  });
}

if (process.argv.includes("--rebuild")) {
  rebuild()
} else {
  esbuild.build({
    entryPoints: {
      ...otherEntrypoints,
      "application": path.join(process.cwd(), "app/javascript/application.js"),
      "intl-tel-input-utils": path.join(process.cwd(), "app/javascript/intl-tel-input-utils.js"),
      [`application.${process.env.THEME}`]: themeFile,
    },
    define: {
      global: "window"
    },
    bundle: true,
    // ESM + Splitting will only work if the script is type="module"
    // splitting: true,
    // format: "esm",
    format: "iife",
    sourcemap: true,
    outdir: path.join(process.cwd(), "app/assets/builds"),
    loader: {
      ".png": "file",
      ".jpg": "file",
      ".svg": "file",
      ".woff": "file",
      ".woff2": "file",
      ".ttf": "file",
      ".eot": "file",
    },
    watch: process.argv.includes("--watch"),
    plugins: [
      ImportGlobPlugin()
    ],
    // TODO: Silencing warnings until the charset warning is fixed.
    logLevel: 'error',
  }).catch(() => process.exit(1));
}