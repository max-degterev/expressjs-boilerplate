export const types = {
  ROUTE_SET: 'ROUTE_SET',
};

export const actions = {
  setRoute(payload) {
    return { type: types.ROUTE_SET, payload };
  },
};

export const reducer = (state = null, action) => {
  switch (action.type) {
    case types.ROUTE_SET: {
      return action.payload;
    }

    default: {
      return state;
    }
  }
};
