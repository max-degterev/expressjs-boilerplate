import React from 'react';
import { render } from 'react-dom';

import Router from 'react-router/lib/Router';
import browserHistory from 'react-router/lib/browserHistory';
import match from 'react-router/lib/match';

import { Provider } from 'react-redux';
import { trigger } from 'redial';

import attachFastClick from 'fastclick';

import isEmpty from 'lodash/isEmpty';

import createStore from './store';
import createRouter from './modules/routes';
import { getRoutesParams } from './modules/routes/utils';

import { actions as errorActions } from './components/error_handler/state';
import { actions as routeActions } from './modules/routes/state';

const { setError } = errorActions;
const { setRoute } = routeActions;

attachFastClick(document.body);

// Router setup. Accepts history and routes.
// Both history and routes are relying on store and dispatching events.
const renderPage = (store, history, routes) => {
  const node = (
    <Provider store={store}>
      <Router history={history} routes={routes} />
    </Provider>
  );

  render(node, document.getElementById('main'));
};

const startRouter = (store, history) => {
  const { subscribeRouter, routes } = createRouter(store);

  let hasInitialData = !isEmpty(global.__appState__);
  let previousComponents = [];

  const handleFetch = (location) => {
    const matchPage = (error, redirect, props) => {
      const shouldFetch = !hasInitialData;
      hasInitialData = false;

      const getLocals = (component) => ({
        isFirstRender: !previousComponents.includes(component),
        location: props.location,
        params: props.params,
        dispatch: store.dispatch,
        state: store.getState(),
        route: getRoutesParams(props.routes),
      });

      const handleError = (networkError) => store.dispatch(setError(networkError));

      if (error) return handleError(error);
      if (redirect) return;

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
const store = createStore(global.__appState__);
startRouter(store, browserHistory);
