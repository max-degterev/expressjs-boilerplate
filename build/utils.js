const config = require('uni-config');
const { spawn } = require('child_process');
const { resolve: pathResolve } = require('path');
const chalk = require('chalk');

const ROOT_PATH = `${pathResolve(`${__dirname}/..`)}/`;

const utils = {
  isBuild() {
    return process.argv[2] === 'build';
  },

  pathNormalize(path) {
    return `${path.replace(`${__dirname}/../`, '').replace(ROOT_PATH, '')}`;
  },

  benchmarkReporter(action, startTime) {
    console.log(chalk.magenta(`${action} in ${((Date.now() - startTime) / 1000).toFixed(2)}s`));
  },

  watchReporter(path) {
    console.log(chalk.cyan(`File ${path} changed, flexing 💪`));
  },

  errorReporter(e) {
    console.log(chalk.bold.red(`Build error!\n${e.stack || e}`));
    if (utils.isBuild()) process.exit(1);
  },

  run(string, options = {}) {
    const [command, ...args] = string.split(' ');

    const executor = (resolve, reject) => {
      let output = '';
      let errors = '';

      const stream = spawn(command, args, options.options);

      const handleData = (chunk) => {
        output += chunk;
        if (!options.silent) process.stdout.write(chunk);
      };

      const handleError = (chunk) => {
        errors += chunk;
        if (!options.silent) process.stderr.write(chunk);
      };

      const handleExit = (exitCode) => {
        const result = { exitCode, output, errors };
        if (exitCode) return reject(result);
        return resolve(result);
      };

      stream.stdout.on('data', handleData);
      stream.stderr.on('data', handleError);
      stream.on('exit', handleExit);
    };

    return new Promise(executor);
  },

  getReplacementRules() {
    return [
      { from: /config\.debug/g, to: config.debug },
      { from: /config\.sandbox/g, to: config.sandbox },
      { from: /process\.browser/g, to: true },
    ];
  },
};

module.exports = utils;
