#!/usr/bin/env node

const [, , cwd, entryPoint] = process.argv

const path = require('path')
const fs = require('fs')
const postcssrc = require(require.resolve('postcss-load-config', { paths: [cwd] }))

postcssrc({ cwd }, cwd).then(config => {
  const wantsJS = entryPoint.endsWith('.js')
  const resolvedPath = path.resolve(cwd, wantsJS ? entryPoint.slice(0, -3) : entryPoint)
  const postcss = require(require.resolve('postcss', { paths: [cwd] }))
  const css = fs.readFileSync(resolvedPath, 'utf8')

  postcss(config.plugins)
    .process(css, {
      ...config.options,
      from: resolvedPath
    })
    .then(({ css, messages }) => {
      // We want JS, so return a JS function that injects the CSS into the head of the page as a
      // <style> tag, and export the CSS module class names as an object.
      if (wantsJS) {
        const escapedCss = css.replace('`', '\\`')
        const cssmMsg = messages.find(m => m.type === 'export' && m.plugin === 'postcss-modules')
        const classNames = cssmMsg ? JSON.stringify(cssmMsg.exportTokens) : {}

        process.stdout.write(`
          const s = document.createElement('style');
          s.appendChild(document.createTextNode(\`${escapedCss}\`));
          document.head.appendChild(s);
          export default ${classNames};
        `)
      } else {
        process.stdout.write(css)
      }
    })
    .catch(() => {
      process.exit(1)
    })
})
