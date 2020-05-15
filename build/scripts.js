const gulp = require('gulp');

const config = require('uni-config');
const utils = require('./utils');

const POLYFILLS_FILE = 'polyfills.js';
const APP_FILE = 'app.js';

const FILE_MAP = {
  [POLYFILLS_FILE]: `${__dirname}/../client/polyfills.es`,
  [APP_FILE]: `${__dirname}/../client/index.es`,
};

const ASSETS_LOCATION = `${__dirname}/../${config.build.assets_location}`;
const buildInProgress = {};

const setTransforms = (name, bundler) => {
  // Make sure to work on *source* files, otherwise matching isn't guaranteed
  if (utils.isBuild()) {
    const replaceOptions = { replace: utils.getReplacementRules() };

    bundler.transform(require('browserify-replace'), replaceOptions);
  }

  bundler.transform(require('babelify').configure({ extensions: ['.es', '.jsx'] }));

  if (utils.isBuild()) {
    const envifyOptions = {
      NODE_ENV: config.environment,
      global: true,
    };

    const uglifyOptions = {
      mangle: true,
      compress: { drop_console: true },
      output: { max_line_len: 64000 },
      global: true,
    };

    bundler.transform(require('loose-envify'), envifyOptions);
    bundler.transform(require('uglifyify'), uglifyOptions);
    bundler.plugin(require('bundle-collapser/plugin'));
  }

  if (name === APP_FILE) {
    // vendorify fails if directory doesn't exist
    require('mkdirp').sync(ASSETS_LOCATION);
    bundler.plugin(require('vendorify'), { outfile: `${ASSETS_LOCATION}/vendor.js` });
  }

  return bundler;
};

const compile = (source, name, options = {}) => {
  const startTime = Date.now();

  // Browserify incremental tends to fail to cancel build in progress
  if (options.watch && buildInProgress[name]) return Promise.resolve(name);
  buildInProgress[name] = true;

  const browserifyOptions = {
    entries: source,
    extensions: ['.es', '.jsx'],
    debug: config.debug,

    cache: {},
    packageCache: {},
    fullPaths: true,
  };

  const cacheOptions = {
    cacheFile: `${__dirname}/.browserify-cache-${name}.json`,
  };

  browserifyOptions.fullPaths = Boolean(options.watch);

  let bundler = require('browserify')(browserifyOptions);
  if (options.watch) bundler = require('browserify-incremental')(bundler, cacheOptions);

  bundler = setTransforms(name, bundler);

  const executor = (resolve) => {
    const stream = bundler
      .bundle()
      .on('error', (error) => {
        buildInProgress[name] = false;
        utils.errorReporter(error);
      })

      .pipe(require('vinyl-source-stream')(name))
      .pipe(gulp.dest(ASSETS_LOCATION))

      .on('end', () => {
        utils.benchmarkReporter(`Browserified ${utils.pathNormalize(source)}`, startTime);
        buildInProgress[name] = false;
        resolve(name);
      });

    if (options.pipe) options.pipe(stream);
  };

  return new Promise(executor);
};

const process = (name, options) => {
  if (name && !FILE_MAP[name]) throw new Error('File isn\'t supported!');
  const files = name ? [name] : Object.keys(FILE_MAP);
  const promises = files.map((key) => compile(FILE_MAP[key], key, options));
  if (promises.length === 1) return promises[0];
  return Promise.all(promises);
};

module.exports = process;
