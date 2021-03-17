// Resolves bare imports to Skypack URL's.
module.exports = {
  name: 'froxy.skypack',
  setup(build) {
    build.onResolve({ filter: /^[^./|../|/].+$/ }, args => {
      return {
        path: `https://jspm.dev/${args.path}`,
        external: true
      }
    })
  }
}
