const { spawn } = require('child_process');
const chalk = require('chalk');

const utils = {
  isBuild() {
    return process.argv[2] === 'build';
  },

  pathNormalize(path) {
    return `${path.replace(`${__dirname}/../`, '')}`;
  },

  sourcesNormalize(input) {
    const paths = Array.isArray(input) ? input : [input];
    return paths.map(utils.pathNormalize);
  },

  benchmarkReporter(action, startTime) {
    console.log(chalk.magenta(`${action} in ${((Date.now() - startTime) / 1000).toFixed(2)}s`));
  },

  watchReporter(e) {
    console.log(chalk.cyan(`File ${utils.pathNormalize(e.path)} ${e.type}, flexing 💪`));
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
};

module.exports = utils;
