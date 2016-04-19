{ keys } = require('../constants')

isDOMAvailable = process.browser
normalizeKey = (key) -> key.toUpperCase()

listeners = {}
listenersLength = 0
lastIndex = 0

codes = {}
for key, value of keys
  codes[value] = normalizeKey(key)


removeListener = (id) ->
  return unless listeners[id]
  delete listeners[id]
  listenersLength--

addListener = (_keys, callback) ->
  throw new Error('Listener function required') if typeof callback isnt 'function'
  id = lastIndex++

  keys = _keys.split(' ')
  keys = keys.map(normalizeKey)

  listeners[id] = { keys, callback }
  listenersLength++

  -> removeListener(id)


handleKeyDown = (event) ->
  return unless key = codes[event.keyCode]

  for id, item of listeners
    item.callback(event) if key in item.keys

attachHandlers = -> document.addEventListener('keydown', handleKeyDown)
attachHandlers() if isDOMAvailable

module.exports = addListener
