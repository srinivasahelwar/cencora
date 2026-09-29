const test = require("node:test");
const assert = require("node:assert");

test("basic arithmetic check", () => {
  assert.strictEqual(2 + 2, 4);
});