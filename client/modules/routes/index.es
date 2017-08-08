import React from 'react';
import Route from 'react-router/lib/Route';

export default () => {
  const routes = (
    <div>
      <Route path="/" component={require('../../containers/home').default} />
      <Route path="*" component={require('../../containers/error_404').default} />
    </div>
  );

  return { routes };
};
