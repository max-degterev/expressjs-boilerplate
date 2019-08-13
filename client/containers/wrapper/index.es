import { PureComponent } from 'react';

import { fetchWrapperData } from './state';

class Wrapper extends PureComponent {
  componentDidMount() {
    // Fetch additional information here
    console.log('Wrapper mounted');
  }

  render() {
    return this.props.children;
  }
}

// Fetch on server side here
Wrapper.resolver = ({ store }) => store.dispatch(fetchWrapperData());

export default Wrapper;
