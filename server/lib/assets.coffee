config = require('../../config')
ASSETS_NAME = 'assets'


generateAssetsMap = ->
  hash = {}

  for key, value of require("../../../public/#{ASSETS_NAME}/hashmap.json")
    hash[key.replace('.min', '')] = value

  hash

assetsHashMap = generateAssetsMap() unless config.debug

module.exports = (name) ->
  name = assetsHashMap[name] unless config.debug
  "/assets/#{name}"
