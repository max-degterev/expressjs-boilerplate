import React from 'react';
import Route from 'react-router/lib/Route';

import ErrorBoundary from '../../components/error_boundary';

export default () => {
  const routes = (
    <ErrorBoundary>
      <Route path="/" component={require('../../containers/home').default} />
      <Route path="*" component={require('../../containers/error_404').default} />
    </ErrorBoundary>
  );

  return { routes };
};
