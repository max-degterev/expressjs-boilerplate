
const FETCH_HOME_DATA = 'FETCH_HOME_DATA';

const getAsyncAction = (timeout) => new Promise((resolve) => setTimeout(resolve, timeout));

export const fetchHomeData = () => ((dispatch) => {
  dispatch({ type: FETCH_HOME_DATA });
  return getAsyncAction(1000).then(
    () => dispatch({ type: `${FETCH_HOME_DATA}_RESOLVED` }),
    () => dispatch({ type: `${FETCH_HOME_DATA}_REJECTED` }),
  );
});

export const reducer = (state = {}, action) => {
  switch (action.type) {
    case `${FETCH_HOME_DATA}_RESOLVED`: {
      return { loadedTimes: (state.loadedTimes || 0) + 1 };
    }

    default: {
      return state;
    }
  }
};
