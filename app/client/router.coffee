class Router extends Backbone.Router
  errorRoute: '404'

  initialize: ->
    @addRoutes()
    super


# ==============================================
# ROUTES
# ==============================================
  addRoutes: ->
    # Backbone is anal with its routes. Less specific go up. More specific go down.
    # E.g. bottom ones HAVE PRIORITY

    # Catch all
    @route(/.+/, 'error')

    # Your normal routes go here

    # Index route
    @route('', 'index')


# ==============================================
# CONTROLLERS
# ==============================================
  index: ->
    new app.views.DemoView

  error: ->
    # do stuff

app.Router = Router
