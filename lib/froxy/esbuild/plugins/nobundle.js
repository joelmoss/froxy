const { join } = require('path')
const { resolve, resolveWithEsbuild, asNoBundle } = require('../utils')

const [, , cwd] = process.argv

module.exports = {
  name: 'froxy.nobundle',
  setup(build) {
    build.onResolve({ filter: /.*/ }, async args => {
      console.log('onResolve', args)

      if (args.kind !== 'entry-point') {
        return asNoBundle(args)
      }
    })
  }
}
