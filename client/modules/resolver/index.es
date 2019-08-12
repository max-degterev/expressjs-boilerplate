/* eslint no-use-before-define: ["off"] */
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
  let matches = [];

  for (const route of routes) {
    const match = matchPath(path, route);
    if (!match) continue;

    matches.push({ route, match });
    if (Array.isArray(route.routes)) {
      const nested = matchRoute(route.routes, path);
      if (nested) matches = matches.concat(nested);
    }

    return matches;
  }

  return null;
};

const getResolver = ({ component }) => {
  if (!component) return null;
  return component.resolver || component[RESOLVER_PROP_NAME];
};

export const runResolver = (routes, path, getLocals = defaultGetLocals) => {
  const matches = matchRoute(routes, path);
  if (!matches || !matches.length) return emptyPromise;

  const promises = matches.map((details) => {
    const resolver = getResolver(details.route);
    if (!resolver) return emptyPromise;

    return resolver(getLocals(details));
  });

  return Promise.all(promises);
};

export const injectStatusCode = (context, statusCode) => {
  if (context && statusCode) context.statusCode = statusCode;
};

export const RouteStatus = ({ statusCode, children, ...props }) => {
  const render = ({ staticContext }) => {
    injectStatusCode(staticContext, statusCode);
    return children;
  };

  return <Route {...props} render={render} />;
};

export const renderRedirect = (route) => {
  const { statusCode, ...options } = route;
  if (!statusCode) return <Redirect {...options} />;

  const { key, ...props } = options;
  return (
    <RouteStatus {...{ key, statusCode }} path={options.from}>
      <Redirect {...props} />
    </RouteStatus>
  );
};

export const renderRoute = (route) => {
  const { component: RouteComponent, statusCode, props, routes, onEnter, ...options } = route;
  if (!route.render && !RouteComponent) {
    console.error('Either `component` or `render` is required for every route.');
    return null;
  }

  let nestedRoutes;
  if (Array.isArray(routes)) nestedRoutes = renderRoutes(routes);

  const render = (routeProps) => {
    injectStatusCode(routeProps.staticContext, statusCode);
    const redirect = typeof onEnter === 'function' && onEnter(routeProps);
    if (redirect) return renderRedirect(typeof redirect === 'string' ? { to: redirect } : redirect);
    if (route.render) return route.render({ ...routeProps, nestedRoutes });
    return <RouteComponent {...routeProps} {...props}>{nestedRoutes}</RouteComponent>;
  };

  return <Route {...options} render={render} />;
};

const renderItem = (route, i) => {
  const { ...options } = route;
  if (!options.key) options.key = i;
  const render = options.from ? renderRedirect : renderRoute;
  return render(options);
};

export const renderRoutes = (routes) => {
  if (!routes || !routes.length) return null;
  return <Switch>{routes.map(renderItem)}</Switch>;
};
