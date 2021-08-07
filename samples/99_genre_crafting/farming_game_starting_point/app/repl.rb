# ===============================================================
# Welcome to repl.rb
# ===============================================================
# You can experiement with code within this file. Code in this
# file is only executed when you save (and only excecuted ONCE).
# ===============================================================

# ===============================================================
# REMOVE the "x" from the word "xrepl" and save the file to RUN
# the code in between the do/end block delimiters.
# ===============================================================

# ===============================================================
# ADD the "x" to the word "repl" (make it xrepl) and save the
# file to IGNORE the code in between the do/end block delimiters.
# ===============================================================

# Remove the x from xrepl to run the code. Add the x back to ignore to code.
xrepl do
  puts "The result of 1 + 2 is: #{1 + 2}"
end

# ====================================================================================
# Ruby Crash Course:
# Strings, Numeric, Booleans, Conditionals, Looping, Enumerables, Arrays
# ====================================================================================

# ====================================================================================
#  Strings
# ====================================================================================
# Remove the x from xrepl to run the code. Add the x back to ignore to code.
xrepl do
  message = "Hello World"
  puts "The value of message is: " + message
  puts "Any value can be interpolated within a string using \#{}."
  puts "Interpolated message: #{message}."
  puts 'This #{message} is not interpolated because the string uses single quotes.'
end

# ====================================================================================
#  Numerics
# ====================================================================================
# Remove the x from xrepl to run the code. Add the x back to ignore to code.
xrepl do
  a = 10
  puts "The value of a is: #{a}"
  puts "a + 1 is: #{a + 1}"
  puts "a / 3 is: #{a / 3}"
end

# Remove the x from xrepl to run the code. Add the x back to ignore to code.
xrepl do
  b = 10.12
  puts "The value of b is: #{b}"
  puts "b + 1 is: #{b + 1}"
  puts "b as an integer is: #{b.to_i}"
  puts ''
end

# ====================================================================================
#  Booleans
# ====================================================================================
# Remove the x from xrepl to run the code. Add the x back to ignore to code.
xrepl do
  c = 30
  puts "The value of c is #{c}."

  if c
    puts "This if statement ran because c is truthy."
  end
end

# Remove the x from xrepl to run the code. Add the x back to ignore to code.
xrepl do
  d = false
  puts "The value of d is #{d}."

  if !d
    puts "This if statement ran because d is falsey, using the not operator (!) makes d evaluate to true."
  end

  e = nil
  puts "Nil is also considered falsey. The value of e is: #{e}."

  if !e
    puts "This if statement ran because e is nil (a falsey value)."
  end
end

# ====================================================================================
#  Conditionals
# ====================================================================================
# Remove the x from xrepl to run the code. Add the x back to ignore to code.
xrepl do
  i_am_true  = true
  i_am_nil   = nil
  i_am_false = false
  i_am_hi    = "hi"

  puts "======== if statement"
  i_am_one = 1
  if i_am_one
    puts "This was printed because i_am_one is truthy."
  end

  puts "======== if/else statement"
  if i_am_false
    puts "This will NOT get printed because i_am_false is false."
  else
    puts "This was printed because i_am_false is false."
  end

  puts "======== if/elsif/else statement"
  if i_am_false
    puts "This will NOT get printed because i_am_false is false."
  elsif i_am_true
    puts "This was printed because i_am_true is true."
  else
    puts "This will NOT get printed i_am_true was true."
  end

  puts "======== case statement "
  i_am_one = 1
  case i_am_one
  when 10
    puts "case equaled: 10"
  when 9
    puts "case equaled: 9"
  when 5
    puts "case equaled: 5"
  when 1
    puts "case equaled: 1"
  else
    puts "Value wasn't cased."
  end

  puts "======== different types of comparisons"
  if 4 == 4
    puts "equal (4 == 4)"
  end

  if 4 != 3
    puts "not equal (4 != 3)"
  end

  if 3 < 4
    puts "less than (3 < 4)"
  end

  if 4 > 3
    puts "greater than (4 > 3)"
  end

  if ((4 > 3) || (3 < 4) || false)
    puts "or statement ((4 > 3) || (3 < 4) || false)"
  end

  if ((4 > 3) && (3 < 4))
    puts "and statement ((4 > 3) && (3 < 4))"
  end
end

# ====================================================================================
# Looping
# ====================================================================================
# Remove the x from xrepl to run the code. Add the x back to ignore to code.
xrepl do
  puts "======== times block"
  3.times do |i|
    puts i
  end
  puts "======== range block exclusive"
  (0...3).each do |i|
    puts i
  end
  puts "======== range block inclusive"
  (0..3).each do |i|
    puts i
  end
end

# ====================================================================================
#  Enumerables
# ====================================================================================
# Remove the x from xrepl to run the code. Add the x back to ignore to code.
xrepl do
  puts "======== array each"
  colors = ["red", "blue", "yellow"]
  colors.each do |color|
    puts color
  end

  puts '======== array each_with_index'
  colors = ["red", "blue", "yellow"]
  colors.each_with_index do |color, i|
    puts "#{color} at index #{i}"
  end
end

# Remove the x from xrepl to run the code. Add the x back to ignore to code.
xrepl do
  puts "======== single parameter function"
  def add_one_to n
    n + 5
  end

  puts add_one_to(3)

  puts "======== function with default value"
  def function_with_default_value v = 10
    v * 10
  end

  puts "passing three: #{function_with_default_value(3)}"
  puts "passing nil: #{function_with_default_value}"

  puts "======== Or Equal (||=) operator for nil values"
  def function_with_nil_default_with_local a = nil
    result   = a
    result ||= "or equal operator was exected and set a default value"
  end

  puts "passing 'hi': #{function_with_nil_default_with_local 'hi'}"
  puts "passing nil: #{function_with_nil_default_with_local}"
end

# ====================================================================================
#  Arrays
# ====================================================================================
# Remove the x from xrepl to run the code. Add the x back to ignore to code.
xrepl do
  puts "======== Create an array with the numbers 1 to 10."
  one_to_ten = (1..10).to_a
  puts one_to_ten

  puts "======== Create a new array that only contains even numbers from the previous array."
  one_to_ten = (1..10).to_a
  evens = one_to_ten.find_all do |number|
    number % 2 == 0
  end
  puts evens

  puts "======== Create a new array that rejects odd numbers."
  one_to_ten = (1..10).to_a
  also_even = one_to_ten.reject do |number|
    number % 2 != 0
  end
  puts also_even

  puts "======== Create an array that doubles every number."
  one_to_ten = (1..10).to_a
  doubled = one_to_ten.map do |number|
    number * 2
  end
  puts doubled

  puts "======== Create an array that selects only odd numbers and then multiply those by 10."
  one_to_ten = (1..10).to_a
  odd_doubled = one_to_ten.find_all do |number|
    number % 2 != 0
  end.map do |odd_number|
    odd_number * 10
  end
  puts odd_doubled

  puts "======== All combination of numbers 1 to 10."
  one_to_ten = (1..10).to_a
  all_combinations = one_to_ten.product(one_to_ten)
  puts all_combinations

  puts "======== All uniq combinations of numbers. For example: [1, 2] is the same as [2, 1]."
  one_to_ten = (1..10).to_a
  uniq_combinations =
    one_to_ten.product(one_to_ten)
      .map do |unsorted_number|
    unsorted_number.sort
  end.uniq
  puts uniq_combinations
end

# ====================================================================================
#  Advanced Arrays
# ====================================================================================
# Remove the x from xrepl to run the code. Add the x back to ignore to code.
xrepl do
  puts "======== All unique Pythagorean Triples between 1 and 40 sorted by area of the triangle."

  one_to_hundred = (1..40).to_a
  triples =
    one_to_hundred.product(one_to_hundred).map do |width, height|
    [width, height, Math.sqrt(width ** 2 + height ** 2)]
  end.find_all do |_, _, hypotenuse|
    hypotenuse.to_i == hypotenuse
  end.map do |triangle|
    triangle.map(&:to_i)
  end.uniq do |triangle|
    triangle.sort
  end.map do |width, height, hypotenuse|
    [width, height, hypotenuse, (width * height) / 2]
  end.sort_by do |_, _, _, area|
    area
  end

  triples.each do |width, height, hypotenuse, area|
    puts "(#{width}, #{height}, #{hypotenuse}) = #{area}"
  end
end
