const gulp = require('gulp');
const fs = require('fs');
const path = require('path');

const utils = require('./utils');

const process = (targetFolder) => {
  const base = `${__dirname}/..`;

  const createFolder = () => {
    const startTime = Date.now();
    const promise = utils.run(`mkdir -p ${targetFolder}`);
    promise
      .then(() => utils.benchmarkReporter(`Created ${targetFolder}`, startTime))
      .catch(utils.errorReporter);

    return promise;
  };

  const createSymlinks = () => {
    const startTime = Date.now();
    const folders = [
      'build',
      'public',
      'templates',
      'vendor',
    ];

    const promises = folders.map((dir) => (
      utils.run(`ln -s ../${dir} ${dir}`, { options: { cwd: targetFolder } })
    ));

    const promise = Promise.all(promises);

    promise
      .then(() => utils.benchmarkReporter(`Created symlinks for ${folders.join(', ')}`, startTime))
      .catch(utils.errorReporter);

    return promise;
  };

  const copyFiles = () => {
    const startTime = Date.now();

    const executor = (resolve) => {
      gulp
        .src([
          `${base}/client/**/*.js`,
          `${base}/server/**/*.js`,
        ], { base })
        .on('error', utils.errorReporter)
        .pipe(gulp.dest(targetFolder))
        .on('end', () => {
          utils.benchmarkReporter('Copied source files', startTime);
          resolve();
        });
    };

    return new Promise(executor);
  };

  const compileBabel = (dir) => {
    const startTime = Date.now();
    const source = path.resolve(`${base}/${dir}`);
    const target = path.resolve(`${targetFolder}/${dir}`);
    const command = `babel ${source} --out-dir ${target}`;

    const promise = utils.run(command, { silent: true });
    promise
      .then(() => utils.benchmarkReporter(`Compiled es files in ${dir}`, startTime))
      .catch(utils.errorReporter);

    return promise;
  };

  const createLauncher = () => {
    const startTime = Date.now();
    const content = 'require(\'./server\')();';
    const destination = path.resolve(`${targetFolder}/app.js`);

    const executor = (resolve) => {
      const complete = (error) => {
        utils.benchmarkReporter('Launcher file created', startTime);
        if (error) utils.errorReporter(error);
        resolve();
      };

      fs.writeFile(destination, content, complete);
    };

    return new Promise(executor);
  };

  const startTime = Date.now();
  const promise = createFolder().then(() => Promise.all([
    createSymlinks(),
    copyFiles(),
    compileBabel('./client'),
    compileBabel('./server'),
    createLauncher(),
  ]));

  promise.then(() => utils.benchmarkReporter('Server compilation complete', startTime));
  return promise;
};

module.exports = process;
