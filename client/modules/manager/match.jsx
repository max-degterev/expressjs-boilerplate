import { matchPath } from 'react-router';
import { isFunction, getMatchableRoute } from './utils';

const defaultGetLocals = (data) => data;

export const getResolver = (request) => {
  const { route: originalRoute } = request;

  const { hook } = originalRoute;
  const route = isFunction(hook) ? hook(request) : originalRoute;
  console.warn('match', request);

  const { component } = route;
  if (!component) return null;

  return component.resolver;
};

const matchRoute = (routes, pathname) => {
  let matches = [];

  for (const route of routes) {
    const matchableProps = getMatchableRoute(route);
    const match = matchPath(pathname, matchableProps);
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
  const { pathname } = location;
  const matches = matchRoute(routes, pathname) || [];

  return matches.reduce((acc, details) => {
    const resolver = getResolver({ location, ...details });
    if (!resolver) return acc;
    return acc.concat(resolver(getLocals(details)));
  }, []);
};
