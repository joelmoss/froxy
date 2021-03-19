#!/usr/bin/env node

const [, , cwd, entryPoint] = process.argv

const esbuild = require(require.resolve('esbuild', { paths: [cwd] }))

const { resolve, config } = require('../lib/froxy/esbuild/utils')
const loadStylePlugin = require('../lib/froxy/esbuild/plugins/load_style')
const aliasPlugin = require('../lib/froxy/esbuild/plugins/alias')
const cssPlugin = require('../lib/froxy/esbuild/plugins/css')
const imagesPlugin = require('../lib/froxy/esbuild/plugins/images')
const rootPlugin = require('../lib/froxy/esbuild/plugins/root')
const ignorePlugin = require('../lib/froxy/esbuild/plugins/ignore')

const nobundlePlugin = require('../lib/froxy/esbuild/plugins/nobundle')
const skypackPlugin = require('../lib/froxy/esbuild/plugins/skypack')
const debugPlugin = require('../lib/froxy/esbuild/plugins/debug')

const buildOptions = {
  absWorkingDir: cwd,
  entryPoints: [entryPoint],
  target: config.target,
  minify: config.minify,
  inject: config.inject,
  sourcemap: config.sourcemap,
  format: 'esm',
  bundle: true,
  splitting: true,
  outdir: 'public/froxy/build',
  outbase: '.',
  metafile: true,
  logLevel: 'error',
  define: {
    global: 'globalThis',
    'process.env.NODE_ENV': `"${process.env.NODE_ENV || 'development'}"`,
    'process.env.RAILS_ENV': `"${process.env.RAILS_ENV || 'development'}"`
  },
  plugins: [aliasPlugin, loadStylePlugin, cssPlugin, imagesPlugin, rootPlugin]
}

config.ignore && buildOptions.plugins.unshift(ignorePlugin)

esbuild
  .build(buildOptions)
  .then(result => {
    console.log(result.metafile)
    // require('fs').writeFileSync('meta.json', JSON.stringify(result.metafile))
  })
  .catch(() => {
    process.exit(1)
  })
