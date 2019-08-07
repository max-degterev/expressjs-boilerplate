import React from 'react';
import { matchPath, Switch, Route, Redirect } from 'react-router';

const defaultResolve = Promise.resolve(null);

const RESOLVER_PROP_NAME = 'getResolverPromise';

const matchRoute = (routes, path) => {
  for (const route of routes) {
    const match = route.path && matchPath(path, route);
    if (match) return { route, match };
  }
  return null;
};

export const connectResolver = (getPromise, Component) => {
  const name = Component.displayName || Component.name || 'Component';
  const displayName = `connectResolver(${name})`;
  const ResolvableComponent = (props) => <Component {...props} />;
  ResolvableComponent[RESOLVER_PROP_NAME] = getPromise;
  ResolvableComponent.displayName = displayName;
  ResolvableComponent.WrappedComponent = Component;
  return ResolvableComponent;
};

export const getResolver = (routes, path, getLocals) => {
  const matchDetails = matchRoute(routes, path);

  if (!matchDetails) return defaultResolve;
  const { route } = matchDetails;

  const resolver = route.component && route.component[RESOLVER_PROP_NAME];
  if (!resolver) return defaultResolve;

  const locals = getLocals ? getLocals(matchDetails) : null;
  return resolver(locals);
};

export const renderRoute = (route, i) => {
  const { component: RouteComponent, props, ...options } = route;
  const key = route.key || i;
  const Component = options.from ? Redirect : Route;
  const render = (routeProps) => {
    if (route.render) return route.render({ ...routeProps, ...props });
    if (RouteComponent) return <RouteComponent {...routeProps} {...props} />;
    throw new Error('You must provide either render or component property for every Route.');
  };

  return <Component {...options} {...{ key, render }} />;
};

export const renderRoutes = (routes) => {
  if (!routes || !routes.length) return null;
  return <Switch>{routes.map(renderRoute)}</Switch>;
};
