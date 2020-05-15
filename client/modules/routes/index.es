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
          onEnter() {
            return { statusCode: 307, to: '/redirectedfromonenter' };
          },
          render() {
            return 'AwesomeRoute!';
          },
        },
        {
          path: '/conditional',
          render(props) {
            const isTrue = true;
            return isTrue ? 'AwesomeRoute!' : <TestRoute {...props} />;
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
