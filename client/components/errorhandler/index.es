import React from 'react';
import { connect } from 'react-redux';

const ErrorCatcher = ({ error }) => {
  if (!error) return null;
  return <pre className="ErrorCatcher">{JSON.stringify(error, null, 2)}</pre>;
};

const mapStateToProps = ({ error }) => ({ error });
export default connect(mapStateToProps)(ErrorCatcher);
