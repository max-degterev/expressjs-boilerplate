const { assert } = require('chai');

const {
  defaultGetLocals,
  getResolver,
} = require('./match');


describe('match', () => {
  it('defaultGetLocals', () => {
    const obj = { test: 1 };
    assert.equal(defaultGetLocals(obj), obj, 'returns same obj');
    assert.deepEqual(defaultGetLocals(obj), obj, 'returns same obj structure');
  });

  it('getResolver', () => {
    const resolverA = () => 1;
    const resolverB = () => 2;

    const objA = {
      route: {
        component: { resolver: resolverA },
      },
    };

    const objB = {
      route: {
        intercept: () => ({ to: '/123' }),
      },
    };

    const objC = {
      route: {
        intercept: () => ({ component: { resolver: resolverB } }),
      },
    };

    const objD = {
      route: {
        intercept: 123,
        component: { resolver: resolverA },
      },
    };

    const objE = { route: {} };

    const objF = {
      route: {
        intercept: () => ({}),
      },
    };

    const objG = {
      route: {
        intercept: () => null,
      },
    };

    const objH = {
      route: {
        component: {
          resolver: 123,
        },
      },
    };

    assert.equal(getResolver(objA), resolverA, 'finds simple resolver');
    assert.isNull(getResolver(objB), 'returns nothing on redirect');
    assert.equal(getResolver(objC), resolverB, 'intercepted');
    assert.equal(getResolver(objD), resolverA, 'incorrect interceptor');
    assert.isNull(getResolver(objE), 'no component');
    assert.isNull(getResolver(objF), 'interceptor returned no component');
    assert.isNull(getResolver(objG), 'interceptor returned null');
    assert.isNull(getResolver(objH), 'resolver is not a fn');
  });
});
