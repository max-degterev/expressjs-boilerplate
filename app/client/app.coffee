#= require ../shared/helpers

#= require router.coffee
#= require_tree models
#= require_tree views


@jade.helpers = helpers
_.extend(app, Backbone.Events)

$('html').removeClass('no-js').addClass('js')
app.router = new app.Router()

Backbone.history.start(pushState: true, hashChange: false)

helpers.log('initialized')
