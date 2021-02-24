const path = require('path')

const { config } = require('../utils')

if (!config.ignore) return

module.exports = {
  name: 'froxy.ignore',
  setup(build) {
    build.onResolve({ filter: new RegExp(config.ignore) }, args => ({
      external: true
    }))
  }
}
