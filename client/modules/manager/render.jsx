/* eslint no-use-before-define: "off" */

import React from 'react';
import { Switch, Route, Redirect } from 'react-router';
import { isFunction, getMatchableRoute } from './utils';

const getCleanProps = ({ component, statusCode, props, routes, onEnter, hook, ...options }) => (
  options
);

const getHookProps = ({ location, match, staticContext }) => ({ location, match, staticContext });

export const injectStatusCode = (context = {}, statusCode) => {
  if (typeof statusCode === 'number') context.statusCode = statusCode;
};

export const RouteStatus = ({ statusCode, children, ...props }) => {
  const render = ({ staticContext }) => {
    injectStatusCode(staticContext, statusCode);
    return children;
  };

  return <Route {...props} render={render} />;
};

const renderMatch = (route, onMatch) => {
  const props = getMatchableRoute(getCleanProps(route));
  return <Route {...props} render={onMatch} />;
};

export const renderRedirect = (route) => {
  const { statusCode, ...options } = route;
  const matchableProps = getMatchableRoute(options);

  const redirect = <Redirect {...matchableProps} />;
  if (!statusCode) return redirect;

  const { from, to, push, ...routeProps } = matchableProps;

  // We wrap the Redirect in Switch to reset React Router's path logic.
  // Otherwise Redirect will ignore the `from` prop.
  return (
    <RouteStatus {...routeProps} {...{ statusCode, path: from }}>
      <Switch>{redirect}</Switch>
    </RouteStatus>
  );
};

export const renderRoute = (originalRoute) => {
  const { component, onEnter, hook, routes } = originalRoute;
  if (!originalRoute.render && !component && !onEnter && !hook) {
    console.error('Detected a useless route in your configuration', originalRoute);
    return null;
  }

  let nestedRoutes;
  if (Array.isArray(routes)) nestedRoutes = renderRoutes(routes);

  const onMatch = (routeProps) => {
    // Check if it is a simple redirect first
    const redirect = typeof onEnter === 'function' && onEnter(routeProps);
    if (redirect) return renderRedirect(typeof redirect === 'string' ? { to: redirect } : redirect);

    const route = isFunction(hook) ? hook({ ...getHookProps(routeProps), route }) : originalRoute;
    const { component: RouteComponent, statusCode, props } = route;
    console.warn('render', { ...getHookProps(routeProps), route });

    // Route is to be handled here, set statusCode
    injectStatusCode(routeProps.staticContext, statusCode);

    // Attempt to render
    if (route.render) return route.render({ ...routeProps, nestedRoutes });
    if (!RouteComponent) return nestedRoutes;
    return <RouteComponent {...routeProps} {...props}>{nestedRoutes}</RouteComponent>;
  };

  return renderMatch(originalRoute, onMatch);
};

const renderItem = (route, index) => {
  const { to, key, hook } = route;
  const render = (to && !isFunction(hook)) ? renderRedirect : renderRoute;
  return render({ ...route, key: key ? `${key}${index}` : index });
};

export const renderRoutes = (routes) => {
  if (!routes || !routes.length) return null;
  return <Switch>{routes.map(renderItem)}</Switch>;
};
