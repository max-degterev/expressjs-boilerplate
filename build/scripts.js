const gulp = require('gulp');

const config = require('uni-config');
const utils = require('./utils');

const FILE_MAP = {
  'polyfills.js': `${__dirname}/../client/polyfills.es`,
  'app.js': `${__dirname}/../client/index.es`,
};

const setTransforms = (bundler) => {
  // Make sure to work on *source* files, otherwise matching isn't guaranteed
  if (utils.isBuild()) {
    const replaceOptions = {
      replace: [
        { from: /config\.debug/g, to: config.debug },
        { from: /config\.sandbox/g, to: config.sandbox },
        { from: /process\.browser/g, to: true },
      ],
    };

    bundler.transform(require('browserify-replace'), replaceOptions);
  }

  bundler.transform(require('babelify').configure({ extensions: ['.es'] }));

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

  return bundler;
};

const compile = (source, name, options = {}) => {
  const startTime = Date.now();

  const browserifyOptions = {
    entries: source,
    extensions: ['.es'],
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
  bundler = setTransforms(bundler);

  const executor = (resolve) => {
    const stream = bundler
      .bundle()
      .on('error', utils.errorReporter)

      .pipe(require('vinyl-source-stream')(name))
      .pipe(gulp.dest(`${__dirname}/../${config.build.assets_location}`))

      .on('end', () => {
        utils.benchmarkReporter(`Browserified ${utils.sourcesNormalize(source)}`, startTime);
        resolve();
      });

    if (options.pipe) options.pipe(stream);
  };

  return new Promise(executor);
};

const process = (name, options) => {
  if (name && !FILE_MAP[name]) throw new Error('File isn\'t supported!');
  const files = name ? [name] : Object.keys(FILE_MAP);
  const promises = files.map((key) => compile(FILE_MAP[key], key, options));
  return Promise.all(promises);
};

module.exports = process;
