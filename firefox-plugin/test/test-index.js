var main = require("../index.js");

exports["test if the object is empty"] = function(assert) {
  assert.ok(main.isEmpty({}) === true);
  assert.ok(main.isEmpty({a: 'hi'}) === false);
}

require("sdk/test").run(exports);
