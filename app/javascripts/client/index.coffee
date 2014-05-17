jade = require('jade').runtime
$ = require('jquery')
_ = require('lodash')
Backbone = require('backbone')
Backbone.$ = $

helpers = require('shared/helpers')
templates = require('templates')

# Setting jade helpers
jade.helpers = helpers
jade.client_env = app.env

# Polluting global namespace to avoid using shims
global.$ = global.jQuery = $
global.Backbone = Backbone

# Environment dump
env = _.extend {}, app.env,
  jquery: $.fn.jquery
  underscore: _.VERSION
  backbone: Backbone.VERSION
  'Backbone.$': !!Backbone.$
  jade: !!jade

# Render client template
$('body').append(templates.sample_template({ env }))
helpers.log('initialized')
