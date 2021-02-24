const path = require('path')
const fs = require('fs')

const { resolve } = require('../utils')

const [, , cwd] = process.argv

module.exports = {
  name: 'froxy.css',
  setup(build) {
    build.onResolve({ filter: /\.css$/ }, async args => {
      let resolvedPath = resolve(args.resolveDir, args.path)

      // Resolved path is not relative or absolute, so we assume it's a node module, and attempt to
      // resolve it from node_modules.
      if (resolvedPath === args.path) {
        const nodeModulesDir = path.join(cwd, 'node_modules')

        try {
          await fs.promises.access(nodeModulesDir, fs.constants.R_OK)
          resolvedPath = path.join(nodeModulesDir, args.path)
        } catch {
          // Fail siently
        }
      }

      return {
        path: resolvedPath,
        namespace: args.importer.endsWith('.js') ? 'cssFromJs' : 'file'
      }
    })

    // When CSS is requested directly - and not imported from JS.
    build.onLoad({ filter: /\.css$/, namespace: 'file' }, async args => {
      // Don't parse node modules with postcss.
      if (args.path.includes('node_modules')) return

      const postcssrc = require(require.resolve('postcss-load-config', { paths: [cwd] }))

      let postcssConfig
      try {
        postcssConfig = await postcssrc({ cwd: cwd }, cwd)
      } catch {
        // Fail siently
      }

      if (postcssConfig) {
        const postcss = require(require.resolve('postcss', { paths: [cwd] }))
        const css = await fs.promises.readFile(args.path, 'utf8')

        const result = await postcss(postcssConfig.plugins).process(css, {
          ...postcssConfig.options,
          from: args.path
        })

        return {
          contents: result.css,
          loader: 'css'
        }
      }
    })

    // When CSS is imported from JS, the CSS is injected into the DOM as a <link> tag. The browser
    // then loads the CSS file as it usually would.
    build.onLoad({ filter: /\.css$/, namespace: 'cssFromJs' }, args => {
      return {
        contents: `
          import loadStyle from 'loadStyle'
          loadStyle("${args.path.slice(cwd.length)}")
        `,
        loader: 'js'
      }
    })
  }
}
