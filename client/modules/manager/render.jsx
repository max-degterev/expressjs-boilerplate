/* eslint no-use-before-define: "off" */

import React from 'react';
import { Switch, Route, Redirect } from 'react-router';
import { isNumber, isFunction, getMatchableRoute } from './utils';

const getRouteProps = ({ component, statusCode, props, routes, intercept, ...cleanProps }) => (
  cleanProps
);

const getRequestProps = ({ location, match }, route) => ({ location, match, route });

const isActionableRoute = ({ render, component, intercept }) => (
  isFunction(render) || component || isFunction(intercept)
);

export const injectStatusCode = (context = {}, statusCode) => {
  if (isNumber(statusCode)) context.statusCode = statusCode;
};

export const RouteStatus = ({ statusCode, children, ...props }) => {
  const render = ({ staticContext }) => {
    injectStatusCode(staticContext, statusCode);
    return children;
  };

  return <Route {...getMatchableRoute(props)} render={render} />;
};

export const renderRedirect = (route) => {
  const { statusCode, ...props } = route;

  const redirect = <Redirect {...getMatchableRoute(props)} />;
  if (!statusCode) return redirect;

  const { from, to, push, ...routeProps } = props;

  // We wrap the Redirect in Switch to reset React Router's path logic.
  // Otherwise Redirect will ignore the `from` prop.
  return (
    <RouteStatus {...routeProps} {...{ statusCode, path: from }}>
      <Switch>{redirect}</Switch>
    </RouteStatus>
  );
};

export const renderRoute = (originalRoute) => {
  if (!isActionableRoute(originalRoute)) {
    console.error('Detected a useless route in your configuration', originalRoute);
    return null;
  }

  const renderProp = (routeProps) => {
    const { intercept } = originalRoute;
    const request = getRequestProps(routeProps, originalRoute);

    const route = isFunction(intercept) ? intercept(request) : originalRoute;
    if (route.to) return renderRedirect(route);

    const { component: RouteComponent, statusCode, props, routes, render } = route;

    // Route is to be handled here, set statusCode
    injectStatusCode(routeProps.staticContext, statusCode);

    const nestedRoutes = Array.isArray(routes) ? renderRoutes(routes) : null;

    // Attempt to render
    if (isFunction(render)) return render({ ...routeProps, nestedRoutes });
    if (!RouteComponent) return nestedRoutes;
    return <RouteComponent {...routeProps} {...props}>{nestedRoutes}</RouteComponent>;
  };

  return <Route {...getMatchableRoute(getRouteProps(originalRoute))} render={renderProp} />;
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
