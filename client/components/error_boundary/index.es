import React, { PureComponent } from 'react';
import PropTypes from 'prop-types';


class ErrorBoundary extends PureComponent {
  constructor(props) {
    super(props);
    this.state = { hasError: false };
  }

  static getDerivedStateFromError() {
    return { hasError: true };
  }

  componentDidCatch(error, info) {
    console.error({ error, info });
  }

  handleReload() {
    global.location.reload();
  }

  render() {
    if (!this.state.hasError) return this.props.children || null;

    return (
      <aside className="ErrorBoundary">
        There was an error rendering this application.
        <span onClick={this.handleReload}>Click to reload.</span>
      </aside>
    );
  }
}

ErrorBoundary.propTypes = {
  children: PropTypes.node,
};

export default ErrorBoundary;
