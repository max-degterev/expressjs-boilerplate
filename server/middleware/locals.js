const config = require('uni-config');
const pick = require('lodash/pick');
const asset = require('../../build/assetmanager');
const serialize = require('serialize-javascript');


const injectLocals = (req, res, next) => {
  const locals = {
    config,
    pick,
    asset,
    serialize,

    // used by Pug to have unminified output
    pretty: config.debug,

    state: {},
  };

  Object.assign(res.locals, locals);
  next();
};

module.exports = () => injectLocals;
