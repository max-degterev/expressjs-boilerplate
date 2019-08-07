import React from 'react';
import { connect } from 'react-redux';

import ErrorCatcher from '../../components/error_handler';
import ErrorBoundary from '../../components/error_boundary';

import { fetchHomeData } from './state';

const HomePage = ({ homeData }) => (
  <ErrorBoundary>
    <div className="HomePage">
      It works! Times data was loaded: {homeData.loadedTimes || 0}.
      <ErrorCatcher />
    </div>
  </ErrorBoundary>
);

HomePage.resolver = ({ store }) => store.dispatch(fetchHomeData());
const mapStateToProps = ({ homeData }) => ({ homeData });
export default connect(mapStateToProps)(HomePage);
