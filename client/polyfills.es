// WARNING!
// Do not require this file in the main bundle! It is loaded separately to improve caching.

require('core-js/es6/map'); // Used by React
require('core-js/es6/set'); // Used by React

require('core-js/fn/array/from'); // Used by Babel
require('core-js/fn/symbol'); // Used by Babel
require('core-js/fn/symbol/iterator'); // Used by Babel

require('core-js/fn/object/assign');
require('core-js/fn/object/is');

require('core-js/fn/array/entries');
require('core-js/fn/array/every');
require('core-js/fn/array/find');
require('core-js/fn/array/find-index');
require('core-js/fn/array/includes');
require('core-js/fn/array/keys');
require('core-js/fn/array/values');

require('core-js/fn/promise');

require('core-js/fn/number/is-finite');
require('core-js/fn/number/is-nan');
require('core-js/fn/number/is-integer');
require('core-js/fn/number/is-safe-integer');

require('core-js/fn/math/sign');

require('core-js/fn/string/ends-with');
require('core-js/fn/string/includes');
require('core-js/fn/string/repeat');
require('core-js/fn/string/starts-with');

require('fastclick')(document.body);

// Fixes glitch in Safari when HTML and JS get out of sync upon navigating back
if (global.addEventListener) {
  global.addEventListener('pageshow', (event) => { if (event.persisted) global.location.reload(); });
}
