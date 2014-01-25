#= require ../shared/helpers

@jade.helpers = helpers
@jade.client_env = app.env

$('body').append(app.templates.sample_template())

helpers.log('initialized')
