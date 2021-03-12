module.exports = {
  plugins: [
    require('postcss-nested'),
    require('postcss-modules')({
      getJSON: (cssFileName, json, outputFileName) => {
        return new Promise(resolve => {
          return resolve(json)
        })
      }
    })
  ]
}
