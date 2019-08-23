export default () => {
  const routes = [
    {
      path: '*', // Needed for the fetch to work, OK to leave empty for 404s that don't load data
      component: require('../../containers/wrapper'),
      routes: [
        {
          path: '/',
          exact: true,
          component: require('../../containers/home'),
        },
        {
          path: '/prompt',
          component: require('../../containers/prompt'),
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
