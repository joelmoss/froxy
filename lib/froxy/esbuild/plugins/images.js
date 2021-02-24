const { resolve } = require('../utils')

const [, , cwd] = process.argv

module.exports = {
  name: 'froxy.images',
  setup(build) {
    const IMAGE_TYPES = /\.(png|gif|jpe?g|svg|ico|webp|avif)$/

    // Froxy proxy will render images directly. esbuild will just rewrite the path when an image is
    // imported from JS, and embed the file name into the bundle as a string. This string is
    // exported using the default export. Including an image in CSS using `url()`, will simply
    // return the relative URL of the image.
    build.onResolve({ filter: IMAGE_TYPES }, args => {
      const resolvedPath = resolve(args.resolveDir, args.path)

      if (args.importer.endsWith('.css')) {
        return {
          path: resolvedPath.slice(cwd.length),
          external: true
        }
      } else {
        return { path: resolvedPath }
      }
    })

    build.onLoad({ filter: IMAGE_TYPES }, args => {
      return {
        contents: `export default '${args.path.slice(cwd.length)}';`,
        loader: 'js'
      }
    })
  }
}
