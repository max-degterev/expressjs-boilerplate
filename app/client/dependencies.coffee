# DO NOT TOUCH. Has to be this way
global.$ = global.jQuery = require('jquery') # for plugins to work w/o shimming
global._ = require('underscore') # for backbone plugins to work
jade = require('jade/runtime') # for monkey-patching jadeifyed templates

global.Backbone = require('backbone') # for backbone plugins to work
global.Backbone.$ = global.$

config = require('config')
env = require('env')

helpers = require('app/common/helpers')

# Monkey patching jade for templates
_.extend(jade, {config, env: env.toJSON(), _, helpers})

if config.debug then global._testify = (obj)-> console.warn global.TEST = obj

module.exports = {$, _, jade, Backbone, config, env, helpers}
