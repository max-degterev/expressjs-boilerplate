import config from 'uni-config';
import React from 'react';
import { render, hydrate } from 'react-dom';

import { Router } from 'react-router';
import { createBrowserHistory } from 'history';
import { matchRoutes, renderRoutes } from 'react-router-config';

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
  const Component = (
    <Provider store={store}>
      <Router history={history}>
        {renderRoutes(routes)}
      </Router>
    </Provider>
  );

  const renderer = isEmpty(global.__appState__) ? render : hydrate;
  return renderer(Component, document.getElementById('main'));
};

const startRouter = (store, history) => {
  const { subscribeRouter, routes } = createRouter(store);
  const handleError = (networkError) => store.dispatch(setError(networkError));

  // let hasInitialData = !isEmpty(global.__appState__);
  // let previousComponents = [];

  const handleFetch = (location) => {
    const matchPage = () => {
      // const shouldFetch = !hasInitialData;
      // hasInitialData = false;
      //
      // if (error) return handleError(error);
      // if (redirect) return;

      // const getLocals = () => ({
      //   // isFirstRender: !previousComponents.includes(component),
      //   // location: props.location,
      //   // params: props.params,
      //   // dispatch: store.dispatch,
      //   // state: store.getState(),
      //   // route: getRoutesParams(props.routes),
      // });

      // if (shouldFetch) trigger('fetch', props.components, getLocals).catch(handleError);
      // trigger('defer', props.components, getLocals).catch(handleError);
      // previousComponents = props.components;
    };

    store.dispatch(setRoute(location.pathname));
    const branch = matchRoutes(routes, location.pathname);

    const promises = branch.map(({ route }) => (
      route.component.loadData ? route.component.loadData({ dispatch: store.dispatch }) : Promise.resolve(null)
    ));

    Promise.all(promises).then(matchPage).catch(handleError);
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
const history = createBrowserHistory();
startRouter(store, history);
