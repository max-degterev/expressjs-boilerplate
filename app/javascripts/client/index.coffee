jade = require('jade').runtime
$ = require('jquery')
_ = require('lodash')
Backbone = require('backbone')

helpers = require('shared/helpers')
templates = require('templates')


jade.helpers = helpers
jade.client_env = app.env

env =
  jquery: $.fn.jquery
  underscore: _.VERSION
  backbone: Backbone.VERSION
  jade: !!jade

_.extend(env, app.env)


$('body').append(templates.sample_template({ env }))
helpers.log('initialized')
