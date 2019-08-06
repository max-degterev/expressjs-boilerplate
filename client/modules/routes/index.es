import React from 'react';
import Route from 'react-router/lib/Route';

export default () => {
  const routes = (
    <>
      <Route path="/" component={require('../../containers/home').default} />
      <Route path="*" component={require('../../containers/error_404').default} />
    </>
  );

  return { routes };
};
