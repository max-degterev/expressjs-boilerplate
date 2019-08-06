import config from 'uni-config';
import { createStore, applyMiddleware, combineReducers } from 'redux';

const reducers = {
  route: require('./modules/routes/state').reducer,
  error: require('./components/error_handler/state').reducer,
  homeData: require('./containers/home/state').reducer,
};

const middleware = [
  require('redux-thunk').default,
];

if (config.debug) {
  middleware.push(require('redux-immutable-state-invariant').default());
}

if (config.sandbox) {
  const loggerOptions = { duration: true };
  if (!process.browser) {
    const extras = {
      duration: true,
      colors: false,
      level: {
        prevState() { return false; },
        nextState() { return false; },
        action() { return 'log'; },
        error() { return 'error'; },
      },
    };
    Object.assign(loggerOptions, extras);
  }

  middleware.push(require('redux-logger').createLogger(loggerOptions));
}

const createFromState = (initialState) => (
  createStore(combineReducers(reducers), initialState, applyMiddleware(...middleware))
);

export default createFromState;
