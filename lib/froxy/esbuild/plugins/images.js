const fs = require('fs')
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
    build.onResolve({ filter: IMAGE_TYPES }, async args => {
      const resolvedArgs = await resolve(args)

      if (args.importer.endsWith('.css')) {
        return {
          path: resolvedArgs.path.slice(cwd.length),
          external: true
        }
      } else {
        return { path: resolvedArgs.path }
      }
    })

    build.onLoad({ filter: IMAGE_TYPES }, async args => {
      if (args.path.endsWith('.svg')) {
        const svg = await fs.promises.readFile(args.path, 'utf8')

        return {
          contents: `export default function() { return ${svg}; }`,
          loader: 'jsx'
        }
      }

      return {
        contents: `export default '${args.path.slice(cwd.length)}';`,
        loader: 'js'
      }
    })
  }
}
