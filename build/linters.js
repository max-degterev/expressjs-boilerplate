const fs = require('fs');
const gulp = require('gulp');
const { run } = require('./utils');

const getLinters = () => {
  const eslint = require('gulp-eslint');
  const stylelint = require('gulp-stylelint');
  const exhaustively = require('stream-exhaust');

  const scripts = [
    '!./public/**/*',
    '!./node_modules/**/*',
    '!./vendor/**/*',

    '**/*.es',
    '**/*.js',
  ];

  const stylusStyles = [
    'client/**/*.styl',
    'styles/**/*.styl',
  ];

  const sassStyles = [
    'client/**/*.scss',
    'styles/**/*.scss',
  ];

  const lintScripts = (options = {}) => {
    const executor = (resolve) => {
      let stream = gulp.src(scripts).pipe(eslint());

      if (options.toFile) {
        stream = stream.pipe(eslint.results((results) => {
          const dest = `${__dirname}/../eslint-report.log`;
          const content = results.filter((report) => Boolean(report.messages.length));
          if (content.length) fs.writeFileSync(dest, JSON.stringify(content, null, 2));
        }));
      }

      stream = stream
        .pipe(eslint.format('codeframe'))
        .pipe(eslint.failAfterError());

      exhaustively(stream).on('end', resolve);
    };

    return new Promise(executor);
  };

  const lintStylusStyles = (options = {}) => {
    let lintArgs = '--colors';
    if (options.toFile) lintArgs = '--reporter stylint-json-reporter';

    const lintPath = (path) => run(`stylint ${lintArgs} ./${path.replace('**/*.styl', '')}`);
    const promises = stylusStyles.map(lintPath);

    const handleResults = ({ exitCode, output }) => {
      if (options.toFile) {
        const results = JSON.parse(output);
        const dest = `${__dirname}/../stylint-report.log`;
        const content = results.filter((report) => Boolean(report.messages.length));
        if (content.length) fs.writeFileSync(dest, JSON.stringify(content, null, 2));
      }

      process.exit(exitCode);
    };

    return Promise.all(promises).catch(handleResults);
  };

  const lintSassStyles = (options = {}) => {
    const executor = (resolve) => {
      const stylelintConfig = {
        reporters: [
          { formatter: 'string', console: true },
        ],
      };

      if (options.toFile) {
        stylelintConfig.reporters.push({
          formatter: (list) => {
            const formatted = list.reduce((acc, item) => {
              if (!item.errored) return acc;

              const {
                source,
                deprecations,
                invalidOptionWarnings,
                parseErrors,
                warnings,
                _postcssResult,
              } = item;

              const newItem = {
                filePath: source,
                messages: warnings.concat(parseErrors, invalidOptionWarnings, deprecations),
                errorCount: parseErrors.length,
                warningCount: warnings.length,
                source: _postcssResult.css,
              };

              acc.push(newItem);
              return acc;
            }, []);

            return JSON.stringify(formatted, null, 2);
          },

          save: `${__dirname}/../stylelint-report.log`,
          console: false,
        });
      }

      const stream = gulp.src(sassStyles).pipe(stylelint(stylelintConfig));

      exhaustively(stream).on('end', resolve);
    };

    return new Promise(executor);
  };

  const lintStyles = (options = {}) => {
    const promises = [lintStylusStyles(options), lintSassStyles(options)];
    return Promise.all(promises);
  };

  const lintRun = (options = {}) => {
    const promises = [lintScripts(options), lintStyles(options)];
    return Promise.all(promises);
  };

  const lintWatch = () => {
    gulp.watch(scripts).on('change', lintScripts);
    gulp.watch(stylusStyles).on('change', lintStylusStyles);
    gulp.watch(sassStyles).on('change', lintSassStyles);
    lintRun();
  };

  return { lintScripts, lintStylusStyles, lintSassStyles, lintStyles, lintRun, lintWatch };
};

module.exports = getLinters;
