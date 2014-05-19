jade = require('jade/runtime')
$ = require('jquery')
_ = require('lodash')
Backbone = require('backbone')

helpers = require('shared/helpers')
template = require('templates/sample_template')


jade.helpers = helpers
jade.client_env = app.env

Backbone.$ = $

env =
  jquery: $.fn.jquery
  underscore: _.VERSION
  backbone: Backbone.VERSION
  'Backbone.$': !!Backbone.$
  jade: !!jade

_.extend(env, app.env)


$('body').append(template({ env }))
helpers.log('initialized')
