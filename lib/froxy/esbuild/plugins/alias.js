const { resolve, config } = require('../utils')

// esbuild plugin to support module aliases as defined in package.json. Supports local and node
// modules.
//
// In your package.json:
//
//  "froxy": {
//    "aliases": {
//      "_": "lodash", // a node module
//      "myalias": "/absolutle/path/to/alias.js", // local path
//    }
//  }
//
// Then import:
//
//  import { map } from '_'
//  import axios from 'myaxios'
//
module.exports = absWorkingDir => ({
  name: 'froxy.alias',
  setup(build) {
    let map = []
    let aliases = {}

    try {
      map = config(absWorkingDir).aliases
      aliases = Object.keys(map)
    } catch {
      // Fail silently, as there is no package.json.
      return
    }

    if (aliases.length > 0) {
      const re = new RegExp(`^${aliases.map(x => escapeRegExp(x)).join('|')}$`)

      build.onResolve({ filter: re }, async ({ resolveDir, path }) => ({
        path: await resolve(absWorkingDir, resolveDir, map[path], { fallbackToEsbuild: true })
      }))
    }
  }
})

function escapeRegExp(string) {
  // $& means the whole matched string
  return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
}
