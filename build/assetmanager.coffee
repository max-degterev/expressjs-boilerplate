config = require('config')

unless config.debug
  assetsHashMap = {}

  for key, value of require("../#{config.build.assets_location}/hashmap.json")
    assetsHashMap[key.replace('.min', '')] = value

  assetsHashMap


module.exports = (name) ->
  name = assetsHashMap[name] unless config.debug
  "/assets/#{name}"
