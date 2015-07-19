config = require('config')

generateAssetsMap = ->
  hash = {}
  for key, value of require('../../public/assets/hashmap.json')
    hash[key.replace('.min', '')] = value

  hash

assetsHashMap = generateAssetsMap() unless config.debug

module.exports =
  getAsset: (name)->
    name = assetsHashMap[name] unless config.debug
    "/assets/#{name}"
