import { matchPath } from 'react-router';
import { isFunction, getMatchableRoute } from './utils';

export const defaultGetLocals = (data) => data;

export const getResolver = (request) => {
  const { route: originalRoute } = request;

  const { intercept } = originalRoute;
  const route = isFunction(intercept) ? intercept(request) : originalRoute;

  if (!route || !route.component) return null;
  const { resolver } = route.component;
  return isFunction(resolver) ? resolver : null;
};

const matchRoute = (routes, pathname) => {
  let matches = [];

  for (const route of routes) {
    const match = matchPath(pathname, getMatchableRoute(route));
    if (!match) continue;

    matches.push({ route, match });

    if (Array.isArray(route.routes)) {
      const nested = matchRoute(route.routes, pathname);
      if (nested) matches = matches.concat(nested);
    }

    // No need to continue because the first match needs to be returned.
    // Can't show multiple routes simultaneously. This matches <Switch> behavior.
    return matches;
  }

  return null;
};

export const runResolver = (routes, location, getLocals = defaultGetLocals) => {
  const matches = matchRoute(routes, location.pathname) || [];

  return matches.reduce((acc, details) => {
    const request = { location, ...details };
    const resolver = getResolver(request);
    if (!resolver) return acc;
    return acc.concat(resolver(getLocals(request)));
  }, []);
};
