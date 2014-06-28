# DO NOT TOUCH. Has to be this way
jade = require('jade/runtime') # for monkey-patching jadeifyed templates
global.$ = global.jQuery = require('jquery') # for plugins to work w/o shimming
global._ = require('underscore') # for backbone plugins to work
global.Backbone = require('backbone') # for backbone plugins to work

config = require('config')
env = require('env')

helpers = require('app/javascripts/shared/helpers')

# Monkey patching jade for templates
jade.config = config
jade.env = env.toJSON()
jade._ = _
jade.helpers = helpers

module.exports = {jade, $, _, Backbone, config, env, helpers}
