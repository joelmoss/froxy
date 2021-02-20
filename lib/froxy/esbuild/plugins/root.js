const path = require('path')

module.exports = absWorkingDir => ({
  name: 'froxy.root',
  setup(build) {
    // Resolves paths starting with a `/` to the Rails root.
    //
    // Example:
    //  import '/my/lib.js' //-> import '{Rails.root}/my/lib.js'
    build.onResolve({ filter: /^\// }, args => ({
      path: path.join(absWorkingDir, args.path)
    }))
  }
})
