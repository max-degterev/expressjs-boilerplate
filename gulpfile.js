const config = require('uni-config');
const gulp = require('gulp');

const MINIFICATION_RULES = {
  suffix: '.min',
};

const ASSETS_LOCATION = `${__dirname}/${config.build.assets_location}`;
const SERVER_BUILD_LOCATION = `${__dirname}/.compiled`;


gulp.task('clean', () => require('del')([ASSETS_LOCATION]));
gulp.task('clean:server', () => require('del')([SERVER_BUILD_LOCATION]));

gulp.task('scripts', () => require('./build/scripts')());
gulp.task('scripts:server', () => require('./build/server')(SERVER_BUILD_LOCATION));
gulp.task('styles', () => require('./build/styles')());

gulp.task('decache:styles', () => (
  gulp
    .src([
      `${ASSETS_LOCATION}/*.css`,
      `!${ASSETS_LOCATION}/*.min.*`,
      `!${ASSETS_LOCATION}/*.min-*`,
    ])
    .pipe(require('gulp-css-decache')({
      base: `${__dirname}/public`,
      logMissing: true,
    }))
    .pipe(gulp.dest(ASSETS_LOCATION))
));

gulp.task('minify:scripts', () => (
  gulp
    .src([
      `${ASSETS_LOCATION}/*.js`,
      `!${ASSETS_LOCATION}/*.min.*`,
      `!${ASSETS_LOCATION}/*.min-*`,
    ])
    .pipe(require('gulp-uglify')({
      compress: { drop_console: true },
      output: { max_line_len: 64000 },
    }))
    .pipe(require('gulp-rename')(MINIFICATION_RULES))
    .pipe(gulp.dest(ASSETS_LOCATION))
));

gulp.task('minify:styles', () => (
  gulp
    .src([
      `${ASSETS_LOCATION}/*.css`,
      `!${ASSETS_LOCATION}/*.min.*`,
      `!${ASSETS_LOCATION}/*.min-*`,
    ])
    .pipe(require('gulp-clean-css')({
      processImport: false,
      keepSpecialComments: 0,
      aggressiveMerging: false,
    }))
    .pipe(require('gulp-rename')(MINIFICATION_RULES))
    .pipe(gulp.dest(ASSETS_LOCATION))
));

gulp.task('hashify', () => {
  const rev = require('gulp-rev');

  return gulp
    .src(`${ASSETS_LOCATION}/*.min.*`)
    .pipe(rev())
    .pipe(gulp.dest(ASSETS_LOCATION))
    .pipe(rev.manifest('hashmap.json'))
    .pipe(gulp.dest(ASSETS_LOCATION));
});

gulp.task('compress', () => (
  gulp
    .src([
      `${ASSETS_LOCATION}/app-*.min.*`,
      `${ASSETS_LOCATION}/locale-*.min.*`,
      `!${ASSETS_LOCATION}/*.gz`,
    ])
    .pipe(require('gulp-gzip')())
    .pipe(gulp.dest(ASSETS_LOCATION))
));

const buildSequence = [
  'clean',

  ['scripts', 'styles'],
  'decache:styles',

  ['minify:scripts', 'minify:styles'],
  'hashify',

  'compress',
];

gulp.task('build', require('gulp-sequence')(...buildSequence));

gulp.task('compile', ['scripts', 'styles']);
gulp.task('compile:server', require('gulp-sequence')('clean:server', 'scripts:server'));

gulp.task('lint', () => require('./build/linters')().lintRun());
gulp.task('lint:scripts', () => require('./build/linters')().lintScripts());
gulp.task('lint:styles', () => require('./build/linters')().lintStyles());
gulp.task('lint:tofile', () => require('./build/linters')().lintRun({ toFile: true }));

gulp.task('default', () => {
  // Gotta make sure each of these functions returns a promise
  const promises = [
    require('./build/scripts')({ watch: true }),
    require('./build/styles')(),
  ];

  return Promise.all(promises).then(require('./build/watcher'));
});
