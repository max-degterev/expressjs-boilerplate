var jade = jade || require('jade').runtime;

this["JST"] = this["JST"] || {};

this["JST"]["sample_template"] = function template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;
var locals_ = (locals || {}),env = locals_.env;
var jade_indent = [];
var lorem = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
buf.push("\n<h2>JS templating also works!</h2><span>Helpers: " + (jade.escape((jade_interp = jade.helpers.shorten(lorem, 20)) == null ? '' : jade_interp)) + "</span>\n<pre>" + (jade.escape(null == (jade_interp = JSON.stringify(env, null, 2)) ? "" : jade_interp)) + "</pre>");;return buf.join("");
};

if (typeof exports === 'object' && exports) {module.exports = this["JST"];}