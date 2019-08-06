import React from 'react';
import ErrorCatcher from '../../components/error_handler';
import ErrorBoundary from '../../components/error_boundary';


const HomePage = () => (
  <ErrorBoundary>
    <div className="HomePage">
      It works!
      <ErrorCatcher />
    </div>
  </ErrorBoundary>
);

export default HomePage;
