# ExpressJS Boilerplate

A good starting point for your NodeJS project.

## Usage:
### Development:

1. Install nodejs:

  It is recommended to install NodeJS with OS native installer via [NodeJS.org website](http://nodejs.org/download/).

  If you prefer using Homebrew (`brew install node`) **DON'T**. NPM [cannot be installed with Homebrew](https://github.com/npm/npm/wiki/Installing-npm-with-Homebrew-on-OS%C2%A0X), so good luck with that.

2. Install dependencies:

  `sudo npm install -g coffee-script nodemon node-gyp`

  and then

  `npm install`

3. Edit your hosts:

  `echo "127.0.0.1 example.dev" >> /private/etc/hosts`

4. Start server:

  `cake dev`

  and navigate your browser to [http://example.dev:3000/](http://example.dev:3000/)

5. ???

6. PROFIT

### Assets management:

It's easier if you install gulp globally: `sudo npm install -g gulp`.

Cakefile already takes care of assets compilation for you. If you need to compile assets separately, use these commands.

* Compile assets for production:

  `gulp build`

* Just clean up previously created mess:

  `gulp clean`

* Build assets for development once

  `gulp`

* Build assets for development and watch for assets changes

  `gulp watch`

### Run tests:

  `mocha`

### Deployment:

Make sure you have Cakefile configuration updated, otherwise it won't work.

  `cake deploy`

Just push changes to the server without restarting and recompiling:

  `cake push`
