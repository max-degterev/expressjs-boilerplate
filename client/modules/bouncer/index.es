const getReplay = (history, location, action) => {
  // attempting to replay `POP` with goBack simply returns to the same state as before.
  const key = action === 'POP' ? 'replace' : action.toLoweCase();
  return () => history[key](location);
};

export default (history, callback) => {
  let isTransitioning = false;
  let preventedAction = null;

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

    preventedAction = getReplay(history, location, action);
    const result = callback(location, action, handleResponse);

    // Awaiting asynchronous confirmation
    if (typeof result !== 'boolean') return false;

    preventedAction = null;
    return result;
  };

  return history.block(handleNavigate);
};
