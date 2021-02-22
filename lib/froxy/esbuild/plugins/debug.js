module.exports = {
  name: 'froxy.debug',
  setup(build) {
    build.onResolve({ filter: /.*/ }, args => {
      console.log('onResolve', args)
    })
    build.onLoad({ filter: /.*/ }, args => {
      console.log('onLoad', args)
    })
  }
}
