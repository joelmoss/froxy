const path = require('path')
const esbuild = require('esbuild')

// Resolve the given path (`p`) to an absolute path.
const resolve = (absWorkingDir, b, p, options = {}) => {
  options = {
    fallbackToEsbuild: false,
    ...options
  }

  if (p.startsWith('/')) return path.resolve(absWorkingDir, p.slice(1))
  if (p.startsWith('.')) return path.resolve(b, p)

  if (options.fallbackToEsbuild) {
    return (async () => await esbuildResolve(p, b))()
  }

  return p
}

// Resolves a module using esbuild module resolution.
//
// @param {string} id Module to resolve
// @param {string} [resolveDir] The directory to resolve from
// @returns {string} The resolved module
async function esbuildResolve(id, resolveDir = process.cwd()) {
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
          sourcefile: __filename
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

module.exports = {
  resolve
}
