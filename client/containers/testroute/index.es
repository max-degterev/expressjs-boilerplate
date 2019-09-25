import React, { PureComponent } from 'react';
import ErrorCatcher from '../../components/error_handler';
import ErrorBoundary from '../../components/error_boundary';


class TestRoute extends PureComponent {
  componentDidMount() {
    // Fetch additional information here
    console.log('TestRoute page mounted');
  }

  render() {
    console.warn('TestRoute render', this.props);
    return (
      <ErrorBoundary>
        <div className="TestRoute">
          This is testroute {this.props.match.params.name}
        </div>
        {this.props.children}
        <ErrorCatcher />
      </ErrorBoundary>
    );
  }
}

// Fetch on server side here
TestRoute.resolver = ({ match }) => {
  console.warn('Resolver in TestRoute', match);
  return Promise.resolve();
};

export default TestRoute;
