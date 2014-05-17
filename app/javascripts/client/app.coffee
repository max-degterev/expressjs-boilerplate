#= require ../shared/helpers

@jade.helpers = helpers
@jade.client_env = app.env

env =
  jquery: jQuery.fn.jquery
  underscore: _.VERSION
  backbone: Backbone.VERSION
  jade: !!jade

$('body').append(app.templates.sample_template({ env }))

helpers.log('initialized')
