def H opts
  opts
end

def A *opts
  opts
end

def assert_format args, assert, hash, expected
  actual = args.fn.pretty_format hash
  assert.are_equal! actual, expected
end

def test_pretty_print args, assert
  # =============================
  # hash with single value
  # =============================
  input = (H first_name: "John")
  expected = <<-S
{:first_name "John"}
S
  (assert_format args, assert, input, expected)

  # =============================
  # hash with two values
  # =============================
  input = (H first_name: "John", last_name: "Smith")
  expected = <<-S
{:first_name "John"
 :last_name "Smith"}
S

  (assert_format args, assert, input, expected)

  # =============================
  # hash with inner hash
  # =============================
  input = (H first_name: "John",
             last_name: "Smith",
             middle_initial: "I",
             so: (H first_name: "Pocahontas",
                    last_name: "Tsenacommacah"),
             friends: (A (H first_name: "Side", last_name: "Kick"),
                         (H first_name: "Tim", last_name: "Wizard")))
  expected = <<-S
{:first_name "John"
 :last_name "Smith"
 :middle_initial "I"
 :so {:first_name "Pocahontas"
      :last_name "Tsenacommacah"}
 :friends [{:first_name "Side"
            :last_name "Kick"}
           {:first_name "Tim"
            :last_name "Wizard"}]}
S

  (assert_format args, assert, input, expected)

  # =============================
  # array with one value
  # =============================
  input = (A 1)
  expected = <<-S
[1]
S
  (assert_format args, assert, input, expected)

  # =============================
  # array with multiple values
  # =============================
  input = (A 1, 2, 3)
  expected = <<-S
[1
 2
 3]
S
  (assert_format args, assert, input, expected)

  # =============================
  # array with multiple values hashes
  # =============================
  input = (A (H first_name: "Side", last_name: "Kick"),
             (H first_name: "Tim", last_name: "Wizard"))
  expected = <<-S
[{:first_name "Side"
  :last_name "Kick"}
 {:first_name "Tim"
  :last_name "Wizard"}]
S

  (assert_format args, assert, input, expected)
end

def test_nested_nested args, assert
  # =============================
  # nested array in nested hash
  # =============================
  input = (H type: :root,
             text: "Root",
             children: (A (H level: 1,
                             text: "Level 1",
                             children: (A (H level: 2,
                                             text: "Level 2",
                                             children: [])))))

  expected = <<-S
{:type :root
 :text "Root"
 :children [{:level 1
             :text "Level 1"
             :children [{:level 2
                         :text "Level 2"
                         :children []}]}]}

S

  (assert_format args, assert, input, expected)
end

def test_scene args, assert
  script = <<-S
* Scene 1
** Narrator
They say happy endings don't exist.
** Narrator
They say true love is a lie.
S
  input = parse_org args, script
  puts (args.fn.pretty_format input)
end
