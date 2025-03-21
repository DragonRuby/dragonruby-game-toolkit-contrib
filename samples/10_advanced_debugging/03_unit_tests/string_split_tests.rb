def assert_string_split args, assert, entry
  desc = []
  desc << ""
  desc << "* Desc"
  desc << "  contents: #{entry.contents.inspect}"

  if entry.key?(:sep)
    desc << "  sep: #{entry.sep.inspect}"
  else
    desc << "  sep: not given"
  end

  if entry.key?(:limit)
    desc << "  limit: #{entry.limit.inspect}"
  else
    desc << "  limit: not given"
  end

  desc << "* Results"
  if entry.key?(:sep) && entry.key?(:limit)
    expected = entry.contents.split(entry.sep, entry.limit)
    actual = String.split(entry.contents, entry.sep, entry.limit)
    desc << "  String#split (baseline): #{expected}"
    desc << "  String::split (redone):  #{actual}"
    assert.equal! expected, actual, desc.join("\n")
  elsif entry.key?(:sep)
    expected = entry.contents.split(entry.sep)
    actual = String.split(entry.contents, entry.sep)
    desc << "  String#split (baseline): #{expected}"
    desc << "  String::split (redone):  #{actual}"
    assert.equal! expected, actual, desc.join("\n")
  else
    expected = entry.contents.split
    actual = String.split(entry.contents)
    desc << "  String#split (baseline): #{expected}"
    desc << "  String::split (redone):  #{actual}"
    assert.equal! expected, actual, desc.join("\n")
  end
end

def test_string_split_empty_entries args, assert
  [
    {
      contents: ",",
      sep: ","
    },
    {
      contents: "aaaaa,,aa,,,a",
      sep: ","
    },
    {
      contents: ",a",
      sep: ","
    },
    {
      contents: ",aaaa",
      sep: ","
    },
    {
      contents: ",a",
      sep: ",",
      limit: 2
    },
    {
      contents: "aaa,",
      sep: ",",
      limit: 1
    },
    {
      contents: ",,,,",
      sep: ","
    },
    {
      contents: "a,,b",
      sep: ",",
      limit: 2
    },
    {
      contents: ",a",
      sep: ",",
      limit: 2
    },
    {
      contents: "a,",
      sep: ",",
      limit: 1
    },
    {
      contents: "a,,,",
      sep: ",",
      limit: 2
    },
    {
      contents: ",,,,",
      sep: ",",
      limit: 2
    },
    {
      contents: "Flippy Flap,,,Start,Quit",
      sep: ",",
    },
  ].each do |h|
    assert_string_split args, assert, h
  end
end

def test_string_split args, assert
  [
    {
      contents: "Hello Beautiful World",
    },
    {
      contents: "one,two,three",
      sep: ","
    },
    {
      contents: "Hello Beautiful World",
      sep: " ",
      limit: 2
    },
    {
      contents: "one,,three",
      sep: ","
    },
    {
      contents: "hello",
      sep: ""
    },
    {
      contents: "1,2,3,4,5",
      sep: ",",
      limit: 3
    },
    {
      contents: "1,2,3,4,5",
      sep: ",",
      limit: 1
    },
    {
      contents: "1,2,3,4,5",
      sep: ",",
      limit: 0
    },
    {
      contents: "1,2,3,4,5",
      sep: ",",
      limit: -1
    },
    {
      contents: "",
      sep: ","
    },
    {
      contents: "846,360,25,50,orange,1,sprites/bricks/orange_brick.png,v",
      sep: ","
    },
    {
      contents: "hello",
    },
    {
      contents: "hello",
      sep: ","
    },
    {
      contents: "hello",
      sep: ""
    },
    {
      contents: "a,,b",
      sep: ","
    },
    {
      contents: "a,",
      sep: ","
    },
    {
      contents: "aaa,",
      sep: ",",
      limit: 2
    },
    {
      contents: "aaa,",
      sep: ",",
      limit: 0
    },
    {
      contents: "",
      sep: ",",
      limit: 2
    },
    {
      contents: "846,360,25,50,orange,1,sprites/bricks/orange_brick.png,v",
      sep: ",",
      limit: 2
    },
    {
      contents: "hello",
      sep: ",",
      limit: 2
    },
    {
      contents: "hello",
      sep: "",
      limit: 2
    },
    {
      contents: "aa",
      sep: "",
      limit: 2
    },
    {
      contents: ",",
      sep: ",",
      limit: 0
    },
    {
      contents: ",",
      sep: ",",
      limit: 1
    },
    {
      contents: ",",
      sep: ",",
      limit: 2
    },
    {
      contents: ",",
      sep: ",",
      limit: 3
    },
  ].each do |h|
    assert_string_split args, assert, h
  end
end

# def test_string_split_benchmark args, assert
#   contents = "846,360,25,50,orange,1,sprites/bricks/orange_brick.png,v"

#   GTK.benchmark seconds: 1, # number of seconds to run each experiment
#                             # label for experiment
#                 split: -> () {
#                   # experiment body
#                   contents.split ","
#                 },
#                 # label for experiment
#                 split_new: -> () {
#                   # experiment body
#                   String.split(contents, ",")
#                 }

#   assert.ok!
# end
