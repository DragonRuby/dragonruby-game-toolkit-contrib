def test_solids args, assert
  game = YouSoBasicGorillas.new
  game.outputs = args.outputs
  game.grid = args.grid
  game.state = args.state
  game.inputs = args.inputs
  game.tick
  assert.true! args.state.stage_generated, "stage wasn't generated but it should have been"
  game.tick
  assert.true! args.outputs.static_solids.length > 0, "stage wasn't rendered"
  number_of_building_components = (args.state.buildings.map { |b| 2 + b.solids[2].length }.inject do |sum, v| (sum || 0) + v end)
  the_only_background = 1
  static_solids = args.outputs.static_solids.length
  assert.true! static_solids == the_only_background.+(number_of_building_components), "not all parts of the buildings and background were rendered"
end
