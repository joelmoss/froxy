// import confetti from 'https://cdn.skypack.dev/canvas-confetti'
// import '/lib/some.css'
// // import "./_some.css";

// import imgUrl from '/lib/images/man.jpg'

// let image = new Image()
// image.src = imgUrl
// document.body.appendChild(image)

// console.log('app/views/pages/home.js')

// confetti()

import { render } from 'https://cdn.skypack.dev/react-dom'
import React, { createElement } from 'https://cdn.skypack.dev/react'

import Link from '/app/components/link.jsx'

const rootEle = document.createElement('div')
document.body.append(rootEle)
render(createElement(Link), rootEle)
