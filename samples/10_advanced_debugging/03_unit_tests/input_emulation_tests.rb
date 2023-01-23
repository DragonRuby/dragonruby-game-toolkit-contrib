def test_keyboard args, assert
  args.inputs.keyboard.key_down.i = true
  assert.true! args.inputs.keyboard.truthy_keys.include?(:i)
end
