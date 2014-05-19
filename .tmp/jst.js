function sample_template(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;
;var locals_for_with = (locals || {});(function (JSON, env) {
var jade_indent = [];
var lorem = "Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
buf.push("\n<h2>JS templating also works!</h2><span>Helpers: " + (jade.escape((jade_interp = jade.helpers.shorten(lorem, 20)) == null ? '' : jade_interp)) + "</span>\n<pre>" + (jade.escape(null == (jade_interp = JSON.stringify(env, null, 2)) ? "" : jade_interp)) + "</pre>");}("JSON" in locals_for_with?locals_for_with.JSON:typeof JSON!=="undefined"?JSON:undefined,"env" in locals_for_with?locals_for_with.env:typeof env!=="undefined"?env:undefined));;return buf.join("");
}
function blocks/awesome(locals) {
var buf = [];
var jade_mixins = {};
var jade_interp;

var jade_indent = [];
buf.push("\n<p>wow template</p>");;return buf.join("");
}