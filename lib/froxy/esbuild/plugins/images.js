const { resolve } = require('../utils')

module.exports = absWorkingDir => ({
  name: 'froxy.images',
  setup(build) {
    const IMAGE_TYPES = /\.(png|gif|jpe?g|svg|ico|webp|avif)$/

    // Froxy proxy will render images directly. esbuild will just rewrite the path when an image is
    // imported from JS, and embed the file name into the bundle as a string. This string is
    // exported using the default export. Including an image in CSS using `url()`, will simply
    // return the relative URL of the image.
    build.onResolve({ filter: IMAGE_TYPES }, args => {
      const resolvedPath = resolve(absWorkingDir, args.resolveDir, args.path)

      if (args.importer.endsWith('.css')) {
        return {
          path: resolvedPath.slice(absWorkingDir.length),
          external: true
        }
      } else {
        return { path: resolvedPath }
      }
    })

    build.onLoad({ filter: IMAGE_TYPES }, args => {
      return {
        contents: `export default '${args.path.slice(absWorkingDir.length)}';`,
        loader: 'js'
      }
    })
  }
})
