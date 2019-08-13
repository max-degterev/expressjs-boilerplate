import React, { PureComponent } from 'react';
import { Link, Prompt } from 'react-router-dom';

import ErrorBoundary from '../../components/error_boundary';


class PromptPage extends PureComponent {
  constructor(props) {
    super(props);
    this.state = { checked: true };
    this.handleUpdate = this.handleUpdate.bind(this);
  }

  componentDidMount() {
    // Fetch additional information here
    console.log('Prompt page mounted');
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
          <Prompt
            when={checked}
            message={this.handleMessage}
          />
        </div>
      </ErrorBoundary>
    );
  }
}

export default PromptPage;
