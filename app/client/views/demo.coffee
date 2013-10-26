class DemoView extends Backbone.View
  el: document.body

  initialize: ->
    super
    @render()

  render: ->
    @$el.append(app.templates.sample_template())

app.views.DemoView = DemoView
