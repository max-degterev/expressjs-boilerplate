const gulp = require('gulp');

const config = require('uni-config');
const utils = require('./utils');

const source = `${__dirname}/../styles/index.styl`;

const stylusOptions = {
  errors: config.debug,
  sourcemaps: config.debug,
  use: [require('nib')()],
  paths: [
    `${__dirname}/../client`,
    `${__dirname}/../node_modules`,
  ],
  'include css': true,
  urlfunc: 'embedurl',
  linenos: config.debug,
  rawDefine: {
    $publicRoot: `${__dirname}/../${config.build.public_root}`,
  },
};

const process = (options = {}) => {
  const startTime = Date.now();

  const executor = (resolve) => {
    const stream = gulp
      .src(source)
      .pipe(require('gulp-stylus')(stylusOptions))
      .on('error', utils.errorReporter)

      .pipe(require('gulp-rename')('app.css'))
      .pipe(gulp.dest(`${__dirname}/../${config.build.assets_location}`))

      .on('end', () => {
        utils.benchmarkReporter(`Stylusified ${utils.sourcesNormalize(source)}`, startTime);
        resolve();
      });

    if (options.pipe) options.pipe(stream);
  };

  return new Promise(executor);
};

module.exports = process;
