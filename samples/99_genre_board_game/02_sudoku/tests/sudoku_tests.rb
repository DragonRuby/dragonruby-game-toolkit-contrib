class SudokuTests
  def test_single_candidates(args, assert)
    s = Sudoku.new
    s.set_value(row: 0, col: 0, value: 1)
    s.set_value(row: 0, col: 1, value: 2)
    s.set_value(row: 0, col: 2, value: 3)
    s.set_value(row: 1, col: 0, value: 4)
    s.set_value(row: 1, col: 1, value: 5)
    s.set_value(row: 1, col: 2, value: 6)
    s.set_value(row: 2, col: 0, value: 7)
    s.set_value(row: 2, col: 1, value: 8)
    assert.equal! s.single_candidates.first, { row: 2, col: 2, value: 9 }
    assert.equal! s.single_candidates.length, 1
  end
end
