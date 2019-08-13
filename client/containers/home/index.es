import React, { PureComponent } from 'react';
import { connect } from 'react-redux';

import ErrorCatcher from '../../components/error_handler';
import ErrorBoundary from '../../components/error_boundary';

import { fetchHomeData } from './state';

class HomePage extends PureComponent {
  componentDidMount() {
    // Fetch additional information here
    console.log('Home page mounted');
  }

  render() {
    const { homeData, wrapperData } = this.props;
    return (
      <ErrorBoundary>
        <div className="HomePage">
          It works!
          <pre>{JSON.stringify({ homeData, wrapperData }, null, 2)}</pre>
          <ErrorCatcher />
        </div>
      </ErrorBoundary>
    );
  }
}

// Fetch on server side here
HomePage.resolver = ({ store }) => store.dispatch(fetchHomeData());

const mapStateToProps = ({ homeData, wrapperData }) => ({ homeData, wrapperData });
export default connect(mapStateToProps)(HomePage);
