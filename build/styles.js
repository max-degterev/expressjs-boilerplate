const gulp = require('gulp');

const config = require('uni-config');
const sass = require('gulp-sass');
const utils = require('./utils');

const stylusSource = `${__dirname}/../styles/index.styl`;
const sassSource = `${__dirname}/../styles/index.scss`;


const stylusOptions = {
  errors: config.debug,
  sourcemaps: config.debug,
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

const sassOptions = {
  includePaths: [
    `${__dirname}/../client`,
    `${__dirname}/../node_modules`,
  ],
  importer: require('node-sass-glob-importer')(),
  outputStyle: 'expanded',
  sourceComments: config.debug,
};

sass.compiler = require('node-sass');

const process = (options = {}) => {
  const stylusPromise = new Promise((resolve) => {
    const startTime = Date.now();
    const name = 'app-stylus.css';

    const stream = gulp
      .src(stylusSource)
      .pipe(require('gulp-stylus')(stylusOptions))
      .pipe(require('gulp-postcss')([
        require('autoprefixer')(),
        require('postcss-flexbugs-fixes'),
      ]))
      .on('error', utils.errorReporter)

      .pipe(require('gulp-rename')(name))
      .pipe(gulp.dest(`${__dirname}/../${config.build.assets_location}`))

      .on('end', () => {
        utils.benchmarkReporter(`Stylusified ${utils.pathNormalize(stylusSource)}`, startTime);
        resolve(name);
      });

    if (options.pipe) options.pipe(stream);
  });

  const sassPromise = new Promise((resolve) => {
    const startTime = Date.now();
    const name = 'app-sass.css';

    const stream = gulp
      .src(sassSource)
      // .pipe(require('gulp-sass-glob')())
      .pipe(sass(sassOptions))
      .pipe(require('gulp-postcss')([
        require('autoprefixer')(),
        require('postcss-flexbugs-fixes'),
      ]))
      .on('error', utils.errorReporter)

      .pipe(require('gulp-rename')(name))
      .pipe(gulp.dest(`${__dirname}/../${config.build.assets_location}`))

      .on('end', () => {
        utils.benchmarkReporter(`Sassified ${utils.pathNormalize(sassSource)}`, startTime);
        resolve(name);
      });

    if (options.pipe) options.pipe(stream);
  });

  return Promise.all([stylusPromise, sassPromise]);
};

module.exports = process;
