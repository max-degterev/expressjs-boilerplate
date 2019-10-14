const gulp = require('gulp');

const config = require('uni-config');
const utils = require('./utils');

const nodemonOptions = {
  script: 'app.js',
  ext: 'js json es',
  watch: [
    'config/*',
    'server/*',
  ],
  ignore: [
    'build/*',
    'test/*',
    'vendor/*',
  ],
};

const clientFiles = [
  'client/*',
];

if (config.server.prerender) {
  nodemonOptions.watch = nodemonOptions.watch.concat(clientFiles);
} else {
  nodemonOptions.ignore = nodemonOptions.ignore.concat(clientFiles);
}

// can dick around checking if port is up, but fuck it
const SERVER_RESTART_TIME = 1500;


const watcher = () => {
  const livereload = require('tiny-lr');
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
    '!client/polyfills.es',
  ];

  const stylesheets = [
    'client/**/*.styl',
    'styles/**/*.styl',
    'client/**/*.scss',
    'styles/**/*.scss',
    'styles/**/*.css',
    'vendor/**/*.css',
  ];

  const templates = [
    'templates/**/*.pug',
  ];

  livereload().listen();
  const nodemon = require('nodemon')(nodemonOptions);

  const handleReload = (name) => livereload.changed(name);
  const handleNoPrerenderReload = (name) => { if (!config.server.prerender) handleReload(name); };
  const handleServerReload = () => setTimeout(() => handleReload('server.js'), SERVER_RESTART_TIME);

  gulp.watch(scripts).on('change', (path) => {
    const options = { watch: true };
    utils.watchReporter(path);
    compileScripts('app.js', options).then(handleNoPrerenderReload);
  });

  gulp.watch(stylesheets).on('change', (path) => {
    utils.watchReporter(path);
    compileStyles().then(handleReload);
  });

  gulp.watch(templates).on('change', (path) => {
    utils.watchReporter(path);
    handleServerReload();
  });

  nodemon.on('start', () => {
    if (nodemonRestarts) handleServerReload();
    nodemonRestarts += 1;
  });

  nodemon.on('restart', (files = []) => {
    files.map(utils.pathNormalize).forEach(utils.watchReporter);
  });

  nodemon.on('log', (log) => { console.log(log.colour); });
};

module.exports = watcher;
