const DataLoader = ({ children }) => children;
DataLoader.resolver = () => {
  console.log('Nested routes worked properly.');
  return Promise.resolve();
};

export default () => {
  const routes = [
    {
      path: '*', // Needed for the fetch to work, OK to leave empty for 404s that don't load data
      component: DataLoader,
      routes: [
        {
          path: '/',
          exact: true,
          component: require('../../containers/home'),
        },
        {
          from: '/redirect',
          to: '/',
          statusCode: 302,
        },
        {
          path: '/onenter',
          onEnter() {
            if (Math.random() > .5) return { statusCode: 302, to: '/redirectedfromonenter' };
          },
          render() {
            return 'AwesomeRoute!';
          },
        },
        {
          component: require('../../containers/error_404'),
          statusCode: 404,
        },
      ],
    },
  ];

  return { routes };
};
