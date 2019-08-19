let instance;
let listeners = [];
let isTransitioning = false;
let preventedAction = null;

export const invoke = (fn, ...args) => {
  if (typeof fn === 'function') return fn(...args);
};

const getReplay = (location, action) => {
  // attempting to replay `POP` with goBack simply returns to the same state as before.
  const key = action === 'POP' ? 'replace' : action.toLowerCase();
  return () => instance[key](location);
};

const handleResponse = (confirmed) => {
  const reference = preventedAction;
  preventedAction = null;

  if (!confirmed || typeof reference !== 'function') return;
  isTransitioning = true;
  reference();
  isTransitioning = false;
};


const handleNavigate = (location, action) => {
  // Let internal transitions pass
  if (isTransitioning) return true;

  preventedAction = getReplay(location, action);

  for (const callback of listeners) {
    const result = callback(location, action, handleResponse);

    // Proceed to the next listener, this one clears the action
    if (result === true) continue;

    // Listener waits for an asynchronous confirmation
    if (typeof result !== 'boolean') return false;

    // Listener returned false, navigation impossible
    preventedAction = null;
    return false;
  }

  // Every registered listener cleared this transition
  preventedAction = null;
  return true;
};

// ========================================================================================
// Public api
// ========================================================================================
const addListener = (callback) => {
  if (typeof callback !== 'function') throw new Error('Listener function is required');
  listeners.push(callback);

  return () => {
    listeners = listeners.filter((fn) => (fn !== callback));
  };
};

const noopBlock = () => console.error('history.block is unavailable, please use replacer method');

const patchHistory = (history, methodName = 'preventNavigation') => {
  if (!process.browser) throw new Error('This can only work in a browser environment.');

  instance = history;
  history.block(handleNavigate);
  history.block = noopBlock;
  history[methodName] = addListener;

  return history;
};

export default patchHistory;
