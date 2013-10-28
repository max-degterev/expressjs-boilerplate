#= require ../shared/helpers

@jade.helpers = helpers
$('html').removeClass('no-js').addClass('js')

$('body').append(app.templates.sample_template())

helpers.log('initialized')
