createDomain = require('domain').create

module.exports = ->
  (req, res, next) ->
    domain = createDomain()
    domain.add(req)
    domain.add(res)
    domain.run(next)
    domain.on('error', next)
