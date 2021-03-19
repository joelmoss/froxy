const path = require('path')
const fs = require('fs')

const [, , cwd] = process.argv

// Resolve the given `params.path` to an absolute path.
async function resolve(params) {
  // Absolute path - append to current working dir.
  if (params.path.startsWith('/')) {
    params.resolvedAs = 'absolute'
    params.path = path.resolve(cwd, params.path.slice(1))
  }

  // Relative path - append to params.resolveDir.
  else if (params.path.startsWith('.')) {
    params.resolvedAs = 'relative'
    params.path = path.resolve(params.resolveDir, params.path)
  }

  // Bare module.
  else {
    params.resolvedAs = 'bare'
    params.path = await resolveWithEsbuild(params.path, {
      sourceFile: params.importer,
      resolveDir: params.resolveDir
    })
  }

  return params
}

async function asNoBundle({ path, resolveDir, importer }) {
  const resolvedPath = resolve(resolveDir, path)
  const esbResolvedPath = await resolveWithEsbuild(resolvedPath, {
    sourceFile: importer,
    resolveDir
  })

  // Let paths from node modules through, but not the actual bare module.
  if (!isBareModule(path) && isFromNodeModules(esbResolvedPath)) return

  return {
    path: esbResolvedPath.slice(cwd.length),
    external: true
  }
}

function isBareModule(p) {
  return !p.startsWith('.') && !p.startsWith('/')
}

function isFromNodeModules(p) {
  return p.startsWith(path.join(cwd, 'node_modules'))
}

module.exports = {
  resolve,
  resolveWithEsbuild,
  asNoBundle,
  isBareModule,
  isFromNodeModules,

  get config() {
    let packageConfig = {}
    const defaultConfig = {
      minify: false,
      sourcemap: true,
      bundle: false
    }

    try {
      const pkg = fs.readFileSync(path.join(cwd, 'package.json'))
      packageConfig = JSON.parse(pkg).froxy
    } catch {
      // Fail silently, as there is no package.json.
    }

    return { ...defaultConfig, ...packageConfig }
  }
}

// Resolves a module using esbuild module resolution.
//
// @param {string} id Module to resolve
// @param {string} [resolveDir] The directory to resolve from
// @returns {string} The resolved module
async function resolveWithEsbuild(id, { resolveDir, sourceFile }) {
  const esbuild = require(require.resolve('esbuild', { paths: [cwd] }))

  let _resolve
  const resolvedPromise = new Promise(resolve => (_resolve = resolve))

  return Promise.race([
    resolvedPromise,
    esbuild
      .build({
        sourcemap: false,
        write: false,
        bundle: true,
        format: 'esm',
        logLevel: 'silent',
        platform: 'node',
        stdin: {
          contents: `import ${JSON.stringify(id)}`,
          loader: 'js',
          resolveDir,
          sourcefile: sourceFile || __filename
        },
        plugins: [
          {
            name: 'esbuildResolve',
            setup(build) {
              build.onLoad({ filter: /.*/ }, ({ path }) => {
                id = path
                _resolve(id)
                return { contents: '' }
              })
            }
          }
        ]
      })
      .then(() => id)
  ])
}
