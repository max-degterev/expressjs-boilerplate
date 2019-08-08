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
    const { homeData } = this.props;
    return (
      <ErrorBoundary>
        <div className="HomePage">
          It works! Times data was loaded: {homeData.loadedTimes || 0}.
          <ErrorCatcher />
        </div>
      </ErrorBoundary>
    );
  }
}

// Fetch on server side here
HomePage.resolver = ({ store }) => store.dispatch(fetchHomeData());

const mapStateToProps = ({ homeData }) => ({ homeData });
export default connect(mapStateToProps)(HomePage);
