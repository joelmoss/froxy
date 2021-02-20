const path = require('path')
const fs = require('fs')

const { resolve } = require('../utils')

module.exports = absWorkingDir => ({
  name: 'froxy.css',
  setup(build) {
    // Handle CSS imported from JS.
    build.onResolve({ filter: /\.css$/ }, args => {
      let resolvedPath = resolve(absWorkingDir, args.resolveDir, args.path)

      if (resolvedPath === args.path) {
        const nodeModulesDir = path.join(absWorkingDir, 'node_modules')

        try {
          fs.accessSync(nodeModulesDir, fs.constants.R_OK)
          resolvedPath = path.join(nodeModulesDir, args.path)
        } catch {
          // Do nothing
        }
      }

      return {
        path: resolvedPath,
        namespace: args.importer.endsWith('.js') ? 'cssFromJs' : 'file'
      }
    })

    // Handles CSS imports from JS (eg `import from 'some.css'`) by simply marking it as external.
    // This then allows the browser to handle the import. However, browsers do not yet support
    // importing non-JS assets, and will not include the CSS. So the Froxy proxy will return the
    // imported CSS as a JS file that inserts the CSS directly into the DOM. This unfortunately may
    // result in a flash of unstyled content (FOUC).
    //
    // --- OR
    //
    // esbuild returns the content of both the JS and CSS. Then Froxy returns the JS as normal,
    // and additionally includes the CSS directly into the rendered HTML. This way, there will be no
    // FOUC. But this method is a little more complex, as Froxy will need to somehow pass the CSS
    // content to Rails for insertion into the rendered view.
    build.onLoad({ filter: /\.css$/, namespace: 'cssFromJs' }, args => ({
      contents: `
        import loadStyle from 'loadStyle'
        loadStyle("${args.path.slice(absWorkingDir.length)}")
      `,
      loader: 'js'
    }))
  }
})
