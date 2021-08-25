def test_benchmark_api args, assert
  result = args.gtk.benchmark iterations: 100,
                              only_one: -> () {
                                r = 0
                                (1..100).each do |i|
                                  r += 1
                                end
                              }

  assert.equal! result.first_place.name, :only_one

  result = args.gtk.benchmark iterations: 100,
                              iterations_100: -> () {
                                r = 0
                                (1..100).each do |i|
                                  r += 1
                                end
                              },
                              iterations_50: -> () {
                                r = 0
                                (1..50).each do |i|
                                  r += 1
                                end
                              }

  assert.equal! result.first_place.name, :iterations_50

  result = args.gtk.benchmark iterations: 1,
                              iterations_100: -> () {
                                r = 0
                                (1..100).each do |i|
                                  r += 1
                                end
                              },
                              iterations_50: -> () {
                                r = 0
                                (1..50).each do |i|
                                  r += 1
                                end
                              }

  assert.equal! result.too_small_to_measure, true
end
