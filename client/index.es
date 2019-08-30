import config from 'uni-config';
import React from 'react';
import { render, hydrate } from 'react-dom';

import { Router } from 'react-router';
import { runResolver, renderRoutes } from 'react-router-manager';
import { createBrowserHistory } from 'history';
import patchBlockFn from 'history-block-async';

import { Provider } from 'react-redux';

import isEmpty from 'lodash/isEmpty';

import createStore from './store';
import createRouter from './modules/routes';

import { actions as errorActions } from './components/error_handler/state';
import { actions as routeActions } from './modules/routes/state';

const { setError } = errorActions;
const { setRoute } = routeActions;

// Router setup. Accepts history and routes.
// Both history and routes are relying on store and dispatching events.
const renderPage = (store, history, routes) => {
  const content = (
    <Provider store={store}>
      <Router history={history}>{renderRoutes(routes)}</Router>
    </Provider>
  );

  const renderer = isEmpty(global.__appState__) ? render : hydrate;
  return renderer(content, document.getElementById('main'));
};

const startRouter = (store, history) => {
  const { subscribeRouter, routes } = createRouter(store);
  const handleError = (networkError) => store.dispatch(setError(networkError));

  let shouldFetch = isEmpty(global.__appState__);
  const handleFetch = (location) => {
    const { pathname } = location;
    const getLocals = (details) => ({ ...details, store, location });
    store.dispatch(setRoute(pathname));
    if (shouldFetch) Promise.all(runResolver(routes, pathname, getLocals)).catch(handleError);
    shouldFetch = true;
  };

  if (!global.__appState__.error || global.__appState__.error.statusCode === 404) {
    if (subscribeRouter) subscribeRouter();
    history.listen(handleFetch);
    handleFetch(history.location);
  }

  renderPage(store, history, routes);
};

// Call setup functions. First setup store, then initialize router.
if (config.debug) console.log(`Loading React v${React.version}`);
const store = createStore(global.__appState__);
const history = patchBlockFn(createBrowserHistory());
startRouter(store, history);
