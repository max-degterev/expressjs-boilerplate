const ROUTE_OPTIONS = [
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
    Object.keys(route).forEach((key) => {
      if (!ROUTE_OPTIONS[key]) acc[key] = route[key];
    });
    return acc;
  }, {})
);
