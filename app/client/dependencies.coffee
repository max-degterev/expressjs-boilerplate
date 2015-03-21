# DO NOT TOUCH. Has to be this way
jade = require('jade/runtime') # for monkey-patching jadeifyed templates
_ = require('underscore') # for backbone plugins to work

config = require('config')
env = require('env')

helpers = require('app/common/helpers')

# Monkey patching jade for templates
jade.config = config
jade.env = env.toJSON()
jade._ = _
jade.helpers = helpers

module.exports = {jade, _, config, env, helpers}
