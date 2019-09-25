const gulp = require('gulp');

const config = require('uni-config');
const sass = require('node-sass');
const gulpSass = require('gulp-sass');
const sizeOf = require('image-size');
const utils = require('./utils');

const stylusSource = `${__dirname}/../styles/index.styl`;
const sassSource = `${__dirname}/../styles/index.scss`;
const publicRoot = `${__dirname}/../${config.build.public_root}`;


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
    $publicRoot: publicRoot,
  },
};

const functions = {
  'replace($pattern, $string, $replacement)': (pattern, string, replacement) => {
    const regex = new RegExp(pattern.getValue(), 'g');
    const result = string.getValue().replace(regex, replacement.getValue());
    return new sass.types.String(result);
  },
  'image-size($url)': (path) => {
    const file = `${publicRoot}/${path.getValue()}`;

    const dimensions = sizeOf(file);
    const keys = ['width', 'height'];
    const map = new sass.types.Map(keys.length);

    keys.forEach((key, index) => {
      map.setKey(index, new sass.types.String(key));
      map.setValue(index, new sass.types.Number(dimensions[key], 'px'));
    });

    return map;
  },
};

const sassOptions = {
  includePaths: [
    `${__dirname}/../client`,
    `${__dirname}/../node_modules`,
  ],
  functions,
  importer: require('node-sass-glob-importer')(),
  outputStyle: 'expanded',
  sourceComments: config.debug,
};

gulpSass.compiler = sass;


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
      .pipe(gulpSass(sassOptions))
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
