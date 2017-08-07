const config = require('uni-config');

const assetsHashMap = {};

if (!config.debug) {
  const assets = require(`../${config.build.assets_location}/hashmap.json`);

  Object.keys(assets).forEach((key) => {
    assetsHashMap[key.replace('.min', '')] = assets[key];
  });
}

const getAsset = (name) => {
  const assetName = config.debug ? name : assetsHashMap[name];
  return `/assets/${assetName}`;
};

module.exports = getAsset;
