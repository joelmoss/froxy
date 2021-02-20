const { resolve } = require('../utils')

module.exports = absWorkingDir => ({
  name: 'froxy.images',
  setup(build) {
    const IMAGE_TYPES = /\.(png|gif|jpe?g|svg|ico|webp|avif)$/

    // Mark images as external. The proxy will render these directly. esbuild will just rewrite the
    // path.
    build.onResolve({ filter: IMAGE_TYPES }, args => ({
      path: resolve(absWorkingDir, args.resolveDir, args.path).slice(absWorkingDir.length),
      external: true
    }))
  }
})
