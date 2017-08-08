import React from 'react';
import { connect } from 'react-redux';

const ErrorCatcher = ({ error }) => {
  if (!error) return null;
  return <pre className="ErrorCatcher">{error}</pre>;
};

const mapStateToProps = ({ error }) => ({ error });
export default connect(mapStateToProps)(ErrorCatcher);
