import React from 'react';
import Error404 from '../../containers/error_404';


export default () => {
  const routes = [
    {
      path: '/',
      exact: true,
      component: require('../../containers/home'),
    },
    {
      from: '/redirect',
      to: '/',
    },
    {
      render: ({ staticContext }) => {
        if (staticContext) staticContext.statusCode = 404;
        return <Error404 />;
      },
    },
  ];

  return { routes };
};
