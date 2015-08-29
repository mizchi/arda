// for node.js environment
module.exports = function(React) {
  global.React = React;
  var Arda = require('./lib/index');
  return Arda;
}
