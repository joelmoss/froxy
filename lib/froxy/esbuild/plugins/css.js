const path = require('path')
const fs = require('fs')

const { resolve } = require('../utils')

const [, , cwd] = process.argv

module.exports = {
  name: 'froxy.css',
  setup(build) {
    // esbuild should handle only CSS from node_modules. All else is marked as 'external' and
    // handled by the PostCSS builder.
    build.onResolve({ filter: /\.css$/ }, async args => {
      // Resolved path is external if it is relative or absolute. Otherwise we assume it's a node
      // module. External paths will then be handled by the PostCSS builder.
      return { external: resolve(args.resolveDir, args.path) !== args.path }
    })

    // When CSS is imported from JS, the CSS is injected into the DOM as a <link> tag. The browser
    // then loads the CSS file as it usually would.
    build.onLoad({ filter: /\.css$/ }, args => ({
      contents: `
        import loadStyle from 'loadStyle'
        loadStyle("${args.path.slice(cwd.length)}")
      `,
      loader: 'js'
    }))
  }
}
