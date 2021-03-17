const path = require('path')

const { resolveWithEsbuild } = require('../utils')

const [, , cwd] = process.argv

module.exports = {
  name: 'froxy.root',
  setup(build) {
    // Resolves paths starting with a `/` to the Rails root.
    //
    // Example:
    //  import '/my/lib.js' === import '{Rails.root}/my/lib.js'
    build.onResolve({ filter: /^\// }, async args => {
      return {
        path: await resolveWithEsbuild(`.${args.path}`, {
          resolveDir: cwd,
          sourceFile: args.importer
        })
      }
    })
  }
}
