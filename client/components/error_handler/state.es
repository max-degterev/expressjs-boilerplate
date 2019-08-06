import config from 'uni-config';

export const types = {
  ERROR_SET: 'ERROR_SET',
};

export const actions = {
  setError(payload) {
    if (config.debug && payload instanceof Error) console.error(payload.stack);
    return { type: types.ERROR_SET, payload };
  },
};

export const reducer = (state = null, action) => {
  switch (action.type) {
    case types.ERROR_SET: {
      return action.payload;
    }
    default: {
      return state;
    }
  }
};
