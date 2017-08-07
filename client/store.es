import config from 'uni-config';
import { createStore, applyMiddleware, combineReducers } from 'redux';

const reducers = {
  route: require('./modules/routes/state').reducer,
  error: require('./components/errorhandler/state').reducer,
};

const middleware = [
  require('redux-thunk').default,
];

if (config.debug) middleware.push(require('redux-immutable-state-invariant').default());

if (config.sandbox) {
  const options = { duration: true };

  if (!process.browser) {
    Object.assign(options, {
      duration: true,
      colors: false,
      level: {
        prevState: () => false,
        nextState: () => false,
        action: () => 'log',
        error: () => 'error',
      },
    });
  }

  const { createLogger } = require('redux-logger');
  middleware.push(createLogger(options));
}


export default (initialState) => (
  createStore(combineReducers(reducers), initialState, applyMiddleware(...middleware))
);
