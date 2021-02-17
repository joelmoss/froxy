module.exports = {
  name: "froxy.loadStyle",

  setup(build) {
    build.onResolve({ filter: /^loadStyle$/ }, () => ({
      path: "loadStyle",
      namespace: "loadStyleShim",
    }));

    build.onLoad({ filter: /^loadStyle$/, namespace: "loadStyleShim" }, () => ({
      contents: `
          export default function (path) {
            const ele = document.createElement('link')
            ele.setAttribute('rel', 'stylesheet')
            ele.setAttribute('media', 'all')
            ele.setAttribute('href', path)
            document.head.appendChild(ele)
          }
        `,
    }));
  },
};
