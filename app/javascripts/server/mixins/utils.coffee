_ = require('underscore')
querystring = require('querystring')
helpers = require('app/javascripts/shared/helpers')


utils =
  log: helpers.log
  api: helpers.api

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
