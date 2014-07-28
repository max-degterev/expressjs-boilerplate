{jade, $, _, Backbone, config, env, helpers} = require('./dependencies')
template = require('app/templates/blocks/sample_template')


status =
  jquery: $.fn.jquery
  underscore: _.VERSION
  backbone: Backbone.VERSION
  'Backbone.$': !!Backbone.$

data = _.extend({}, env.toJSON(), status)

$('body').append(template({ data }))
helpers.log('initialized')
