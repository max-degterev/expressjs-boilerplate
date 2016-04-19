media =
  mediaS: '(min-width: 450px)'
  mediaM: '(min-width: 690px)'
  mediaL: '(min-width: 960px)'

getMedia = (node, media) -> node.matchMedia(media).matches

offset = (node) ->
  top: node.offsetTop + (node.offsetParent?.offsetTop or 0)
  left:  node.offsetLeft + (node.offsetParent?.offsetLeft or 0)

position = (node) ->
  top: node.offsetTop
  left:  node.offsetLeft

size = (node) ->
  width: node.offsetWidth
  height:  node.offsetHeight

screenSize = (node) ->
  width: node.document.documentElement.clientWidth
  height: node.document.documentElement.clientHeight

module.exports = { media, getMedia, offset, position, size, screenSize }
