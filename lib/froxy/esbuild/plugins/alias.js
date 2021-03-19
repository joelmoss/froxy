const URL = require('url').URL

const { resolve, resolveWithEsbuild, config, asNoBundle } = require('../utils')

const [, , cwd] = process.argv

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
module.exports = {
  name: 'froxy.alias',
  setup(build) {
    let map = []
    let aliases = {}

    try {
      map = config.aliases
      aliases = Object.keys(map)
    } catch {
      // Fail silently, as there is no package.json.
      return
    }

    if (aliases.length > 0) {
      const re = new RegExp(`^${aliases.map(x => escapeRegExp(x)).join('|')}$`)

      build.onResolve({ filter: re }, async args => {
        const path = map[args.path]
        const resolvedArgs = await resolve({ ...args, path })

        return { path: resolvedArgs.path }

        // if (!config.bundle) {
        //   return asNoBundle({ ...args, path })
        // }
      })
    }
  }
}

function escapeRegExp(string) {
  // $& means the whole matched string
  return string.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')
}
