#!/usr/bin/env node

const [, , cwd] = process.argv

const postcssrc = require(require.resolve('postcss-load-config', { paths: [cwd] }))

postcssrc({ cwd }, cwd)
  .then(() => {
    process.exit(0)
  })
  .catch(() => {
    process.exit(1)
  })
