import React, { PureComponent } from 'react';
import { Link } from 'react-router-dom';

import ErrorBoundary from '../../components/error_boundary';


class PromptPage extends PureComponent {
  constructor(props) {
    super(props);
    this.state = { prevent: true, delay: true };

    this.handleNavigate = this.handleNavigate.bind(this);
  }

  componentDidMount() {
    // Fetch additional information here
    console.log('Prompt page mounted');
    this.unblock = this.props.history.preventNavigation(this.handleNavigate);
  }

  componentWillUnmount() {
    this.unblock();
  }

  handleNavigate(location, action, callback) {
    const { prevent, delay } = this.state;
    console.warn(`Attempting to navigate to ${location.pathname}`, this.state);
    if (!delay) return !prevent;
    setTimeout(() => callback(!prevent), 1500);
  }

  handleUpdate(prop) {
    return ({ target: { checked } }) => this.setState({ [prop]: checked });
  }

  render() {
    const { prevent, delay } = this.state;
    return (
      <ErrorBoundary>
        <div className="PromptPage">
          Try navigating away, I dare you!
          <label>
            <input
              type="checkbox"
              checked={prevent} onChange={this.handleUpdate('prevent')}
            />
            Prevent navigation?
          </label>

          <label>
            <input
              type="checkbox"
              checked={delay} onChange={this.handleUpdate('delay')}
            />
            Delay?
          </label>
          <Link to="/">Home page</Link>
        </div>
      </ErrorBoundary>
    );
  }
}

export default PromptPage;
