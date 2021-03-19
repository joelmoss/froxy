const { resolve, resolveWithEsbuild } = require('../utils')

const [, , cwd] = process.argv

module.exports = {
  name: 'froxy.nobundle',
  setup(build) {
    build.onResolve({ filter: /.*/ }, async args => {
      console.log('onResolve', args)

      if (args.kind !== 'entry-point') {
        const resolvedPath = resolve(args.resolveDir, args.path)
        const esbResolvedPath = await resolveWithEsbuild(resolvedPath, {
          resolveDir: args.resolveDir,
          sourceFile: args.importer
        })
        console.log(resolvedPath, esbResolvedPath)

        return {
          path: esbResolvedPath.slice(cwd.length),
          external: true
        }
      }
    })
    build.onLoad({ filter: /.*/ }, args => {
      console.log('onLoad', args)
    })
  }
}
