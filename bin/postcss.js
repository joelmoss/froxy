#!/usr/bin/env node

const [, , cwd, entryPoint] = process.argv

const path = require('path')
const fs = require('fs')
const postcssrc = require(require.resolve('postcss-load-config', { paths: [cwd] }))

postcssrc({ cwd }, cwd).then(config => {
  const resolvedPath = path.resolve(cwd, entryPoint)
  const postcss = require(require.resolve('postcss', { paths: [cwd] }))
  const css = fs.readFileSync(resolvedPath, 'utf8')

  postcss(config.plugins)
    .process(css, {
      ...config.options,
      from: resolvedPath
    })
    .then(result => {
      process.stdout.write(result.css)
    })
    .catch(() => {
      process.exit(1)
    })
})
