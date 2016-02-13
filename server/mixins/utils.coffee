_ = require('underscore')
querystring = require('querystring')
log = require('app/common/logger')


utils =
  log: log

  bind: (callbacks)->
    if _.isArray(callbacks)
      _.bind(callback, @) for callback in callbacks
    else
      _.bind(callbacks, @)

  injectParams: (options = {})->
    url = options.url
    url += if !~url.indexOf('?') then '?' else '&'
    url += querystring.stringify(options.params)

module.exports = utils
