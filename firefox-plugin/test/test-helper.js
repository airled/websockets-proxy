var helper = require("../lib/helper.js");

exports["test if the object is empty"] = function(assert) {
  assert.ok(helper.checkEmpty({}) === true);
  assert.ok(helper.checkEmpty({a: 'hi'}) === false);
}

require("sdk/test").run(exports);
