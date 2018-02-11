const { info } = require('winston');
const app = require('express')();
const config = require('uni-config');

const setRequestHandlers = () => {
  app.use(require('express-domain-middleware'));
  app.use(require('middleware-sanitizeurl')({ log: true }));
  app.use(require('morgan')(config.debug ? 'dev' : 'combined'));

  // Static middleware is not needed in production, but still loaded for debug purposes,
  // E.g. running production mode locally
  if (config.sandbox) {
    app.use(require('serve-favicon')(`${__dirname}/../public/favicon.ico`));
    app.use(require('serve-static')(`${__dirname}/../public`, { redirect: false }));
  }

  app.use(require('middleware-trailingslash')());
  app.use(require('./middleware/locals')());
  if (config.debug) app.use(require('connect-livereload')());

  // This middleware has to go right before catchall because it ends requests
  if (config.server.prerender) app.use(require('./middleware/react')());
  app.get('*', require('./controllers/default')());

  if (config.debug) app.use(require('errorhandler')({ dumpExceptions: true, showStack: true }));
};

const startListening = () => {
  const host = process.env.HOST || config.server.host;
  const port = parseInt(process.env.PORT, 10) || config.server.port || 3000;
  const message = `Server listening on http://${host || 'localhost'}:${port}`;

  // usually sitting behind nginx
  app.enable('trust proxy');
  app.disable('x-powered-by');

  app.set('port', port);
  app.set('views', `${__dirname}/../templates`);
  app.set('view engine', 'pug');
  if (config.debug) app.set('json spaces', 2);

  setRequestHandlers();

  if (host) {
    app.listen(port, host, () => info(`${message} (bound to host: ${host})`));
  } else {
    app.listen(port, () => info(message));
  }
};

module.exports = startListening;
