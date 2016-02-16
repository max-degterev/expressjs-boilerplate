config = require('config')


generateAssetsMap = ->
  hash = {}

  for key, value of require("../#{config.build.assets_location}/hashmap.json")
    hash[key.replace('.min', '')] = value

  hash

assetsHashMap = generateAssetsMap() unless config.debug

module.exports = (name) ->
  name = assetsHashMap[name] unless config.debug
  "/assets/#{name}"
