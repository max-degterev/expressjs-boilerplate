import React from 'react';
import { matchRoutes, renderRoutes } from 'react-router-config';

const RESOLVER_PROP_NAME = 'getResolverPromise';

export const connectResolver = (getPromise, Component) => {
  const name = Component.displayName || Component.name || 'Component';
  const displayName = `connectResolver(${name})`;
  const ResolvableComponent = (props) => <Component {...props} />;
  ResolvableComponent[RESOLVER_PROP_NAME] = getPromise;
  ResolvableComponent.displayName = displayName;
  ResolvableComponent.WrappedComponent = Component;
  return ResolvableComponent;
};

export const getResolver = (routes, pathname, getLocals) => {
  const branch = matchRoutes(routes, pathname);

  const promises = branch.map((matchDetails) => {
    const resolver = matchDetails.route.component[RESOLVER_PROP_NAME];
    if (!resolver) return Promise.resolve(null);
    const locals = getLocals ? getLocals(matchDetails) : null;
    return resolver(locals);
  });

  return Promise.all(promises);
};

export { renderRoutes };
