import React from 'react';
import TestRoute from '../../containers/testroute';

const Demo = () => <p>DemoRoute</p>;

const myvar = 'test';

export default () => {
  const routes = [
    {
      path: '*', // Needed for the fetch to work, OK to leave empty for routes that don't load data
      component: require('../../containers/wrapper'),
      routes: [
        { from: '/', to: '/home' },
        {
          path: '/home',
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
          to: '/home',
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
          intercept() {
            const component = myvar === 'test' ? Demo : TestRoute;
            return { component, statusCode: 201 };
          },
        },
        {
          path: '*',
          intercept: () => {
            if (myvar === 'test') {
              return {
                component: require('../../containers/error_404'),
                statusCode: 404,
              };
            }

            return { to: '/' };
          },
        },
      ],
    },
  ];

  return { routes };
};
