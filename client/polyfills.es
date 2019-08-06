// WARNING!
// Do not require this file in the main bundle! It is loaded separately to improve caching.

require('core-js/es/map'); // Used by React
require('core-js/es/set'); // Used by React

require('core-js/es/array/from'); // Used by Babel
require('core-js/es/symbol'); // Used by Babel
require('core-js/es/symbol/iterator'); // Used by Babel
require('core-js/es/object/assign'); // Used by Babel

require('core-js/es/object/is');

require('core-js/es/array/entries');
require('core-js/es/array/every');
require('core-js/es/array/find');
require('core-js/es/array/find-index');
require('core-js/es/array/includes');
require('core-js/es/array/keys');
require('core-js/es/array/values');

require('core-js/es/promise');
require('core-js/es/promise/finally');

require('core-js/es/number/is-finite');
require('core-js/es/number/is-nan');
require('core-js/es/number/is-integer');
require('core-js/es/number/is-safe-integer');

require('core-js/es/math/sign');

require('core-js/es/string/ends-with');
require('core-js/es/string/includes');
require('core-js/es/string/repeat');
require('core-js/es/string/starts-with');

require('fastclick')(document.body);

// Fixes glitch in Safari when HTML and JS get out of sync upon navigating back
if (global.addEventListener) {
  global.addEventListener('pageshow', (event) => { if (event.persisted) global.location.reload(); });
}
