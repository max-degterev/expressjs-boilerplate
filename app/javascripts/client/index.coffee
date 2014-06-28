dependencies = require('./dependencies')
env = require('env')

template = require('app/templates/blocks/sample_template')
helpers = require('app/javascripts/shared/helpers')

jquery = require('jquery')
_ = require('underscore')
Backbone = require('backbone')

status =
  jquery: $.fn.jquery
  underscore: _.VERSION
  backbone: Backbone.VERSION
  'Backbone.$': !!Backbone.$

data = _.extend({}, env.toJSON(), status)

$('body').append(template({ data }))
helpers.log('initialized')
