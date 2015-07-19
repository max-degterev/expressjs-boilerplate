{$, _, jade, Backbone, config, env, helpers} = require('./dependencies')
template = require('templates/blocks/sample_template')


status =
  jquery: jQuery.fn.jquery
  underscore: _.VERSION
  backbone: Backbone.VERSION
  backbone.$: !!Backbone.$

data = _.extend({}, env.toJSON(), status)

global.document.body.insertAdjacentHTML('beforeend',template({ data }))
helpers.log('initialized')
