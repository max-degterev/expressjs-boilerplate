import config from 'uni-config';
import React from 'react';
import { render, hydrate } from 'react-dom';

import Router from 'react-router/lib/Router';
import browserHistory from 'react-router/lib/browserHistory';
import match from 'react-router/lib/match';

import { Provider } from 'react-redux';
import { trigger } from 'redial';

import isEmpty from 'lodash/isEmpty';

import createStore from './store';
import createRouter from './modules/routes';
import { getRoutesParams } from './modules/routes/utils';

import { actions as errorActions } from './components/error_handler/state';
import { actions as routeActions } from './modules/routes/state';

const { setError } = errorActions;
const { setRoute } = routeActions;

// Router setup. Accepts history and routes.
// Both history and routes are relying on store and dispatching events.
const renderPage = (store, history, routes) => {
  const Component = (
    <Provider store={store}>
      <Router history={history} routes={routes} />
    </Provider>
  );

  const renderer = isEmpty(global.__appState__) ? render : hydrate;
  return renderer(Component, document.getElementById('main'));
};

const startRouter = (store, history) => {
  const { subscribeRouter, routes } = createRouter(store);
  const handleError = (networkError) => store.dispatch(setError(networkError));

  let hasInitialData = !isEmpty(global.__appState__);
  let previousComponents = [];

  const handleFetch = (location) => {
    const matchPage = (error, redirect, props) => {
      const shouldFetch = !hasInitialData;
      hasInitialData = false;

      if (error) return handleError(error);
      if (redirect) return;

      const getLocals = (component) => ({
        isFirstRender: !previousComponents.includes(component),
        location: props.location,
        params: props.params,
        dispatch: store.dispatch,
        state: store.getState(),
        route: getRoutesParams(props.routes),
      });

      if (shouldFetch) trigger('fetch', props.components, getLocals).catch(handleError);
      trigger('defer', props.components, getLocals).catch(handleError);
      previousComponents = props.components;
    };

    store.dispatch(setRoute(location.pathname));
    match({ routes, location, history }, matchPage);
  };

  if (!global.__appState__.error || global.__appState__.error.statusCode === 404) {
    if (subscribeRouter) subscribeRouter();
    history.listen(handleFetch);
    handleFetch(history.getCurrentLocation());
  }

  renderPage(store, history, routes);
};

// Call setup functions. First setup store, then initialize router.
if (config.debug) console.log(`Loading React v${React.version}`);
const store = createStore(global.__appState__);
startRouter(store, browserHistory);
