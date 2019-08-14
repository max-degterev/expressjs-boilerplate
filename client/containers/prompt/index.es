import React, { PureComponent } from 'react';
import { Link } from 'react-router-dom';

import ErrorBoundary from '../../components/error_boundary';


class PromptPage extends PureComponent {
  constructor(props) {
    super(props);
    this.state = { checked: true };

    this.handleNavigate = this.handleNavigate.bind(this);
    this.handleUpdate = this.handleUpdate.bind(this);
  }

  componentDidMount() {
    // Fetch additional information here
    console.log('Prompt page mounted');
    this.unblock = this.props.history.block(this.handleNavigate);
  }

  componentWillUnmount() {
    this.unblock();
  }

  handleNavigate(location) {
    console.warn(`Attempting to navigate to ${location.pathname}`);
    return !this.state.checked;
  }

  handleUpdate({ target: { checked } }) {
    this.setState({ checked });
  }

  handleMessage(location) {
    return `Are you sure you want to go to ${location.pathname}?`;
  }

  render() {
    const { checked } = this.state;
    return (
      <ErrorBoundary>
        <div className="PromptPage">
          Try navigating away, I dare you!
          <label>
            <input
              type="checkbox"
              checked={checked} onChange={this.handleUpdate}
            />
            Prevent navigation?
          </label>
          <Link to="/">Home page</Link>
        </div>
      </ErrorBoundary>
    );
  }
}

export default PromptPage;
