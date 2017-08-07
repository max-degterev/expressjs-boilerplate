const config = require('uni-config');
const pick = require('lodash/pick');
const asset = require('../../build/assetmanager');
const serialize = require('serialize-javascript');

const languages = require('../../i18n');

const localeName = config.client.language;
const locale = languages[localeName];

const getDefaultMeta = (currentLocale) => {
  if (!currentLocale.dictionary.meta) return {};
  const { title, description } = currentLocale.dictionary.meta;
  return Object.assign({}, config.meta, { title, description });
};

const injectLocals = (req, res, next) => {
  const locals = {
    config,
    pick,
    asset,
    serialize,
    locale,

    // used by Pug to have unminified output
    pretty: config.debug,

    state: {},
    localeName: localeName.toLowerCase(),
    meta: getDefaultMeta(locale),
  };

  Object.assign(res.locals, locals);
  next();
};

module.exports = () => injectLocals;
