$gtk.ffi_misc.gtk_dlopen("ext")
include FFI::RURE

def split_words(input)
  matches = Rure_matchPointer.new
  words = []
  re = rure_compile_must("\\w+")
  while rure_find(re, input, input.length, 0, matches) == 1
    words << input.slice(matches[0].start...matches[0].end)
    input = input.slice(matches[0].end, input.length)
  end
  words
end

def tick args
  input = "<<Hello, DragonRiders!>>"
  args.outputs.labels  << [640, 500, split_words(input).join(' '), 5, 1]
end
