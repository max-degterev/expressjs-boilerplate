
const FETCH_WRAPPER_DATA = 'FETCH_WRAPPER_DATA';

const getAsyncAction = (timeout) => new Promise((resolve) => setTimeout(resolve, timeout));

export const fetchWrapperData = () => ((dispatch) => {
  dispatch({ type: FETCH_WRAPPER_DATA });
  return getAsyncAction(1000).then(
    () => dispatch({ type: `${FETCH_WRAPPER_DATA}_RESOLVED` }),
    () => dispatch({ type: `${FETCH_WRAPPER_DATA}_REJECTED` }),
  );
});

export const reducer = (state = {}, action) => {
  switch (action.type) {
    case `${FETCH_WRAPPER_DATA}_RESOLVED`: {
      return { loadedTimes: (state.loadedTimes || 0) + 1 };
    }

    default: {
      return state;
    }
  }
};
