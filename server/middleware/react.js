const { error: logError } = require('winston');
const config = require('uni-config');

const React = require('react');
const { renderToString } = require('react-dom/server');

const match = require('react-router/lib/match');
const RouterContext = require('react-router/lib/RouterContext');

const { Provider } = require('react-redux');
const { trigger } = require('redial');

const createStore = require('../../client/store');
const createRouter = require('../../client/router');

const { getRoutesParams } = require('../../client/modules/routes/utils');

const { International } = require('../../client/modules/i18n');
const Error404 = require('../../client/containers/error_404');
const MicroHelmet = require('../../client/ui/micro_helmet');

const { setError } = require('../../client/components/errorhandler/state').actions;
const { setRoute } = require('../../client/modules/routes/state').actions;


const createComponent = (locale, store, props) => {
  const context = React.createElement(RouterContext, props);
  const provider = React.createElement(Provider, { store }, context);
  return React.createElement(International, { locale }, provider);
};

const renderPage = (res, store, props) => {
  const statusCode = props.components.includes(Error404) ? 404 : 200;

  const Component = createComponent(res.locals.locale, store, props);
  const content = renderToString(Component);
  const meta = MicroHelmet.rewind();

  Object.assign(res.locals.state, store.getState());
  Object.assign(res.locals.meta, meta);
  res.status(statusCode).render('index', { content });
};

const renderError = (res, store) => {
  const state = store.getState();
  Object.assign(res.locals.state, state);

  res.status(state.error.statusCode || 500).render('index');
};

const prerender = (req, res, next) => {
  const store = createStore();

  const handleError = (error) => {
    store.dispatch(setError(error));
    logError(`Request ${req.url} failed to fetch data:`, error);
    renderError(res, store);
  };

  const matchPage = (error, redirect, props) => {
    if (error) {
      logError(`Request ${req.url} failed to route:`, error.message);
      return next();
    }

    if (redirect) return res.redirect(302, `${redirect.pathname}${redirect.search}`);

    // if there was no props, this request isn't handled by FE explicitly
    if (!props) return next();

    const locals = {
      isFirstRender: true,
      location: props.location,
      params: props.params,
      locale: res.locals.locale,
      dispatch: store.dispatch,
      state: store.getState(),
      route: getRoutesParams(props.routes),
    };

    trigger('fetch', props.components, locals)
      .then(() => renderPage(res, store, props))
      .catch(handleError);
  };

  store.dispatch(setRoute(req.path));
  const { routes } = createRouter(store);
  match({ routes, location: req.url }, matchPage);
};

module.exports = () => prerender;
