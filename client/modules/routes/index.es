import React from 'react';
import TestRoute from '../../containers/testroute';

export default () => {
  const routes = [
    {
      path: '*', // Needed for the fetch to work, OK to leave empty for routes that don't load data
      component: require('../../containers/wrapper'),
      routes: [
        {
          path: '/',
          exact: true,
          component: require('../../containers/home'),
        },
        {
          path: '/testroute/:id(\\d+)',
          exact: false,
          component: TestRoute,
          routes: [
            {
              path: '/testroute/:id(\\d+)/:name',
              component: TestRoute,
            },
            {
              to: '/youfailed',
            },
          ],
        },
        {
          path: '/prompt',
          component: require('../../containers/prompt'),
        },
        {
          from: '/redirect',
          to: '/',
          statusCode: 307,
        },
        {
          path: '/onenter',
          component: TestRoute,
          intercept() {
            return { statusCode: 307, to: '/redirectedfromonenter' };
          },
          render() {
            return 'AwesomeRoute!';
          },
        },
        {
          path: '/conditional',
          intercept(props) {
            const isTrue = true;
            console.log(props);
            const component = isTrue ? require('../../containers/home') : TestRoute;
            return { component, statusCode: 201 };
          },
        },
        {
          component: require('../../containers/error_404'),
          statusCode: 404,
        },
      ],
    },
  ];

  return { routes };
};
