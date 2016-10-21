{ create } = require('domain')

module.exports = ->
  (req, res, next) ->
    domain = create()
    domain.add(req)
    domain.add(res)
    domain.run(next)
    domain.on('error', next)
