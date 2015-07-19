{$, _, jade, Backbone, config, env, helpers} = require('./dependencies')
template = require('templates/blocks/sample_template')


status =
  jquery: jQuery.fn.jquery
  underscore: _.VERSION
  backbone: Backbone.VERSION
  'backbone.$': !!Backbone.$
  env: env.toJSON()

global.document.body.insertAdjacentHTML('beforeend',template({ status }))
helpers.log('initialized')
