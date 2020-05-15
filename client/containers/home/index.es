import React, { PureComponent } from 'react';
import { connect } from 'react-redux';

import { Link } from 'react-router-dom';
import { renderRedirect } from '../../modules/manager';

import ErrorCatcher from '../../components/error_handler';
import ErrorBoundary from '../../components/error_boundary';

import { fetchHomeData } from './state';

class HomePage extends PureComponent {
  constructor(props) {
    super(props);
    this.state = { redirect: false };
    this.handleUpdate = this.handleUpdate.bind(this);
  }

  componentDidMount() {
    // Fetch additional information here
    console.log('Home page mounted');
  }

  handleUpdate({ target: { checked } }) {
    this.setState({ redirect: checked });
  }

  render() {
    const { homeData, wrapperData } = this.props;
    const { redirect } = this.state;

    if (redirect) return renderRedirect({ to: '/prompt', statusCode: 307 });

    return (
      <ErrorBoundary>
        <div className="HomePage">
          It works! <Link to="/prompt">Prompt?</Link>
          <pre>{JSON.stringify({ homeData, wrapperData }, null, 2)}</pre>
          <label>
            <input
              type="checkbox"
              checked={redirect} onChange={this.handleUpdate}
            />
            Delayed redirect
          </label>
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
