data = global.app?.env or {}

_flush = ->
  for k, v of data
    delete data[k]
  data._flush = _flush

data._flush = _flush
module.exports = data
