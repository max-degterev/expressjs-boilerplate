const gulp = require('gulp');

const config = require('uni-config');
const utils = require('./utils');

const source = `${__dirname}/../client/index.es`;

const browserifyOptions = {
  entries: source,
  extensions: ['.es'],
  debug: config.debug,

  cache: {},
  packageCache: {},
  fullPaths: true,
};

const cacheOptions = {
  cacheFile: `${__dirname}/.browserify-cache.json`,
};

const process = (options = {}) => {
  browserifyOptions.fullPaths = Boolean(options.watch);
  const startTime = Date.now();

  let bundler = require('browserify')(browserifyOptions);
  if (options.watch) bundler = require('browserify-incremental')(bundler, cacheOptions);

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

  const { extensions } = browserifyOptions;
  bundler.transform(require('babelify').configure({ extensions }));

  if (utils.isBuild()) {
    const uglifyOptions = {
      compress: { drop_console: true },
      output: { max_line_len: 64000 },
    };
    bundler.transform(require('uglifyify'), uglifyOptions);
  }

  const executor = (resolve) => {
    const stream = bundler
      .bundle()
      .on('error', utils.errorReporter)

      .pipe(require('vinyl-source-stream')('app.js'))
      .pipe(gulp.dest(`${__dirname}/../${config.build.assets_location}`))

      .on('end', () => {
        utils.benchmarkReporter(`Browserified ${utils.sourcesNormalize(source)}`, startTime);
        resolve();
      });

    if (options.pipe) options.pipe(stream);
  };

  return new Promise(executor);
};

module.exports = process;
