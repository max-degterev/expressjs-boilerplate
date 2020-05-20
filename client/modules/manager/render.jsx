import React from 'react';
import { Switch, Route, Redirect } from 'react-router';
import { isNumber, isFunction, getMatchableRoute } from './utils';

export const getRouteProps = ({
  intercept, props, component, render, statusCode, routes, ...cleanProps
}) => (
  cleanProps
);

export const getRequestProps = ({ location, match }, route) => ({ location, match, route });

export const isActionableRoute = ({ render, component, intercept }) => (
  Boolean(isFunction(render) || component || isFunction(intercept))
);

export const injectStatusCode = (context = {}, statusCode) => {
  if (isNumber(statusCode)) context.statusCode = statusCode;
};

export const renderRouteStatus = ({ statusCode, children, ...props }) => {
  const renderProp = ({ staticContext }) => {
    injectStatusCode(staticContext, statusCode);
    return children;
  };

  return <Route {...getMatchableRoute(props)} render={renderProp} />;
};

// These render* functions are intentionally written and used as simple functions and not React
// components. It is done so because ReactRouter breaks silently when there are any nodes
// rendered between Router/Switch/Route|Redirect components. This workaround solves that problem.
export const renderRedirect = (props) => {
  const { statusCode, ...route } = props;

  const redirect = <Redirect {...getMatchableRoute(route)} />;
  if (!statusCode) return redirect;

  const { from, to, push, ...routeProps } = route;
  const children = <Switch>{redirect}</Switch>;

  // We wrap the Redirect in Switch to reset React Router's path logic.
  // Otherwise Redirect will ignore the `from` prop.
  return renderRouteStatus({ ...routeProps, statusCode, path: from, children });
};

export const renderRoute = (props) => {
  if (!isActionableRoute(props)) {
    console.error('Detected a useless route in your configuration', props);
    return null;
  }

  const renderProp = (routeProps) => {
    const { intercept } = props;
    const request = getRequestProps(routeProps, props);
    const route = isFunction(intercept) ? intercept(request) : props;

    // Might need to bail from rendering completely
    if (!route) return null;
    if (route.to) return renderRedirect(route);

    const { statusCode, routes, render, component: RouteComponent, props: componentProps } = route;
    // Route is to be handled here, set statusCode
    injectStatusCode(routeProps.staticContext, statusCode);

    // eslint-disable-next-line no-use-before-define
    const children = Array.isArray(routes) ? renderRoutes({ routes }) : null;

    // Attempt to render
    if (isFunction(render)) return render({ ...routeProps, children });
    if (!RouteComponent) return children;
    return <RouteComponent {...routeProps} {...componentProps}>{children}</RouteComponent>;
  };

  return <Route {...getMatchableRoute(getRouteProps(props))} render={renderProp} />;
};

const renderItem = (route, index) => {
  const { to, key, intercept } = route;
  const render = (to && !isFunction(intercept)) ? renderRedirect : renderRoute;
  return render({ ...route, key: key ? `${key}${index}` : index });
};

export const renderRoutes = ({ routes }) => {
  if (!routes || !routes.length) return null;
  return <Switch>{routes.map(renderItem)}</Switch>;
};

export { renderRedirect as Redirect, renderRoute as Route, renderRoutes as default };
