const { resolve } = require('path');
const gulp = require('gulp');

const config = require('uni-config');
const utils = require('./utils');

const nodemonOptions = {
  script: 'app.js',
  ext: 'js json es',
  watch: [
    'config/*',
    'server/*',
    'app.js',
  ],
};

if (config.server.prerender) nodemonOptions.watch.push('client/*');

const SERVER_PATH = resolve(`${__dirname}/../app.js`);
// can dick around checking if port is up, but fuck it
const SERVER_RESTART_TIME = 1500;


const watcher = () => {
  const livereload = require('gulp-livereload');
  const compileScripts = require('./scripts');
  const compileStyles = require('./styles');

  let nodemonRestarts = 0;

  // relative paths required for watch/Gaze to detect changes in new files
  const scripts = [
    'client/**/*.es',
    'vendor/**/*.es',
    'client/**/*.js',
    'vendor/**/*.js',
    'client/**/*.json',
    'vendor/**/*.json',
  ];

  const stylesheets = [
    'client/**/*.styl',
    'styles/**/*.styl',
    'styles/**/*.css',
    'vendor/**/*.css',
  ];

  const templates = [
    'templates/**/*.pug',
  ];

  const reloadPage = () => livereload.reload(SERVER_PATH);

  livereload.listen();
  const nodemon = require('gulp-nodemon')(nodemonOptions);

  gulp.watch(scripts).on('change', (event) => {
    const options = { watch: true };
    if (!config.server.prerender) options.pipe = (stream) => stream.pipe(livereload());
    utils.watchReporter(event);
    compileScripts(options);
  });

  gulp.watch(stylesheets).on('change', (event) => {
    utils.watchReporter(event);
    const pipe = (stream) => stream.pipe(livereload());
    compileStyles({ pipe });
  });

  gulp.watch(templates).on('change', (event) => {
    utils.watchReporter(event);
    reloadPage();
  });

  nodemon.on('start', () => {
    if (nodemonRestarts) setTimeout(reloadPage, SERVER_RESTART_TIME);
    nodemonRestarts += 1;
  });

  nodemon.on('restart', (files) => {
    const event = { type: 'change' };

    files.forEach((path) => {
      event.path = path;
      utils.watchReporter(event);
    });
  });
};

module.exports = watcher;
