const blackListProps = [
  'component',
  'path',
  'childRoutes',
  'getChildRoutes',
  'indexRoute',
  'getIndexRoute',
  'onEnter',
  'onLeave',
].reduce((acc, key) => {
  acc[key] = true;
  return acc;
}, {});

export const getRoutesParams = (routes) => (
  routes.reduce((acc, route) => {
    const props = Object.keys(route).reduce((filtered, key) => {
      if (!blackListProps[key]) filtered[key] = route[key];
      return filtered;
    }, {});

    Object.assign(acc, props);
    return acc;
  }, {})
);
