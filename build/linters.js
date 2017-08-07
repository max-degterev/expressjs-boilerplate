const fs = require('fs');
const gulp = require('gulp');
const { run } = require('./utils');

const getLinters = () => {
  const eslint = require('gulp-eslint');
  const exhaustively = require('stream-exhaust');

  const scripts = [
    './**/*.es',
    '*.js',
  ];

  const styles = [
    'client/**/*.styl',
    'styles/**/*.styl',
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

  const lintStyles = (options = {}) => {
    let lintArgs = '--colors';
    if (options.toFile) lintArgs = '--reporter stylint-json-reporter';

    const lintPath = (path) => run(`stylint ${lintArgs} ./${path.replace('**/*.styl', '')}`);
    const promises = styles.map(lintPath);

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

  const lintRun = (options = {}) => {
    const promises = [lintScripts(options), lintStyles(options)];
    return Promise.all(promises);
  };

  const lintWatch = () => {
    gulp.watch(scripts).on('change', lintScripts);
    gulp.watch(styles).on('change', lintStyles);
    lintRun();
  };

  return { lintScripts, lintStyles, lintRun, lintWatch };
};

module.exports = getLinters;
