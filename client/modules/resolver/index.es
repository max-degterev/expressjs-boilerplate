import React from 'react';
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

const injectStatusCode = (context, statusCode) => {
  if (context && statusCode) context.statusCode = statusCode;
};

export const RouteStatus = ({ statusCode, children, ...props }) => {
  const render = ({ staticContext }) => {
    injectStatusCode(staticContext, statusCode);
    return children;
  };

  return <Route {...props} render={render} />;
};

const renderRedirect = (route) => {
  const { statusCode, ...options } = route;
  if (!statusCode) return <Redirect {...options} />;

  const { key, ...props } = options;
  return (
    <RouteStatus {...{ key, statusCode }} path={options.from}>
      <Redirect {...props} />
    </RouteStatus>
  );
};

const renderRoute = (route) => {
  const { component: RouteComponent, statusCode, props, ...options } = route;
  if (!route.render && !RouteComponent) {
    console.error('Either `component` or `render` is required for every route.');
    return null;
  }

  const render = (routeProps) => {
    injectStatusCode(routeProps.staticContext, statusCode);
    if (route.render) return route.render({ ...routeProps, ...props });
    return <RouteComponent {...routeProps} {...props} />;
  };

  return <Route {...options} render={render} />;
};

const renderItem = (route, i) => {
  const { ...options } = route;
  if (!options.key) options.key = i;
  if (options.from) return renderRedirect(options);
  return renderRoute(options);
};

export const renderRoutes = (routes) => {
  if (!routes || !routes.length) return null;
  return <Switch>{routes.map(renderItem)}</Switch>;
};
