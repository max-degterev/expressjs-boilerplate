const { assert } = require('chai');

const {
  getRouteProps,
  getRequestProps,
  isActionableRoute,
  injectStatusCode,
} = require('./render');


describe('render', () => {
  it('getRouteProps', () => {
    const obj = { component: 1, statusCode: 2, props: 3, routes: 4, intercept: 5, test: 6 };
    const expected = { test: 6 };
    assert.deepEqual(getRouteProps(obj), expected, 'filters out own props');
  });

  it('getRequestProps', () => {
    const obj = { location: 1, match: 2, extraneous: 3, whatever: 4 };
    const route = { test: 3 };
    const expected = { route, location: 1, match: 2 };
    assert.deepEqual(getRequestProps(obj, route), expected, 'creates correct payload');
  });

  it('isActionableRoute', () => {
    const fn = () => {};
    const objA = {};
    const objB = { render: fn };
    const objC = { intercept: fn };
    const objD = { component: 1 };
    assert.isFalse(isActionableRoute(objA), 'empty');
    assert.isTrue(isActionableRoute(objB), 'render');
    assert.isTrue(isActionableRoute(objC), 'intercept');
    assert.isTrue(isActionableRoute(objD), 'component');
  });

  it('injectStatusCode', () => {
    const context = {};

    injectStatusCode(context, 321); // set
    injectStatusCode(context, 0); // reset to 0
    injectStatusCode(context, '123'); // string is ignored
    injectStatusCode(context, null); // null is ignored
    injectStatusCode(context); // undefined is ignored
    injectStatusCode(); // empty call doesn't crash

    assert.equal(context.statusCode, 0, 'sets context correctly');
  });
});
