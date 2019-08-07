const React = require('react');
const { renderToString } = require('react-dom/server');

const { StaticRouter } = require('react-router');

const { Provider } = require('react-redux');
const { getResolver, renderRoutes } = require('../../client/modules/resolver');

const createStore = require('../../client/store');
const createRouter = require('../../client/modules/routes');

const { setError } = require('../../client/components/error_handler/state').actions;
const { setRoute } = require('../../client/modules/routes/state').actions;


const renderApp = ({ routes, store, location, context }) => {
  const router = React.createElement(StaticRouter, { location, context }, renderRoutes(routes));
  const content = React.createElement(Provider, { store }, router);
  return renderToString(content);
};

const renderPage = (res, store, context, content) => {
  const statusCode = context.statusCode || 200;
  Object.assign(res.locals.state, store.getState());
  res.status(statusCode).render('index', { content });
};

const renderError = (res, store) => {
  const state = store.getState();
  Object.assign(res.locals.state, state);

  res.status(state.error.statusCode || 500).render('index');
};

const prerender = (req, res) => {
  const store = createStore();
  const { routes } = createRouter(store);

  const handleError = (error) => {
    store.dispatch(setError(error));
    console.error(`Request ${req.url} failed to fetch data:`, error);
    renderError(res, store);
  };

  const getLocals = (details) => ({ ...details, store });

  const matchPage = () => {
    const context = {};
    const content = renderApp({ routes, store, context, location: req.url });
    if (context.url) return res.redirect(301, context.url);
    renderPage(res, store, context, content);
  };

  store.dispatch(setRoute(req.path));
  getResolver(routes, req.path, getLocals).then(matchPage).catch(handleError);
};

module.exports = () => prerender;
