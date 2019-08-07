import React, { Fragment } from 'react';
import { matchPath, Switch, Route, Redirect } from 'react-router';

const RESOLVER_PROP_NAME = '__runResolverPromise__';
const emptyPromise = Promise.resolve(null);


const defaultGetLocals = (data) => data;

export const connectResolver = (getPromise, Component) => {
  // There is no point in implementing a real HOC since there is no way to have a component chain
  // with multiple `getPromise` methods. Simply override whatever the current value is.
  Component[RESOLVER_PROP_NAME] = getPromise;
  return Component;
};

const matchRoute = (routes, path) => {
  for (const route of routes) {
    const match = matchPath(path, route);
    if (match) return { route, match };
  }
  return null;
};

const getResolver = ({ component }) => {
  if (!component) return null;
  return component.resolver || component[RESOLVER_PROP_NAME];
};

export const runResolver = (routes, path, getLocals = defaultGetLocals) => {
  const details = matchRoute(routes, path);
  if (!details) return emptyPromise;

  const resolver = getResolver(details.route);
  if (!resolver) return emptyPromise;

  return resolver(getLocals(details));
};

export const ResponseStatus = ({ statusCode, children }) => {
  const render = ({ staticContext }) => {
    if (staticContext) staticContext.statusCode = statusCode;
    return children;
  };

  return <Route render={render} />;
};

const renderRoute = (route) => {
  const { component: RouteComponent, props, ...options } = route;
  if (!route.render && !RouteComponent) {
    console.error('Either `component` or `render` is required for every route.');
    return null;
  }

  const render = (routeProps) => {
    if (route.render) return route.render({ ...routeProps, ...props });
    return <RouteComponent {...routeProps} {...props} />;
  };

  return <Route {...options} render={render} />;
};

const renderItem = (route, i) => {
  const { key, statusCode, ...options } = route;
  const Wrapper = statusCode ? ResponseStatus : Fragment;
  const content = route.from ? <Redirect {...options} /> : renderRoute(options);

  return <Wrapper key={key || i} statusCode={statusCode}>{content}</Wrapper>;
};

export const renderRoutes = (routes) => {
  if (!routes || !routes.length) return null;
  return <Switch>{routes.map(renderItem)}</Switch>;
};
