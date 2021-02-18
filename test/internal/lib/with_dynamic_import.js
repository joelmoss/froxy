const file = 'time'
const time = import(`./${file}.js`)

console.log('/lib/with_dynamic_import.js')
console.log(`time = ${time}`)
