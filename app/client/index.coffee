{jade, _, config, env, helpers} = require('./dependencies')
template = require('templates/blocks/sample_template')


status = underscore: _.VERSION
data = _.extend({}, env.toJSON(), status)

global.document.body.insertAdjacentHTML('beforeend',template({ data }))
helpers.log('initialized')
