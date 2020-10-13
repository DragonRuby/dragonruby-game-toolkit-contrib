$gtk.ffi_misc.gtk_dlopen("ext")
include FFI::RE

def split_words(input)
  words = []
  last = IntPointer.new
  re = re_compile("\\w+")
  first = re_matchp(re, input, last)
  while first != -1
    words << input.slice(first, last.value)
    input = input.slice(last.value + first, input.length)
    first = re_matchp(re, input, last)
  end
  words
end

def tick args
  args.outputs.labels  << [640, 500, split_words("hello, dragonriders!").join(' '), 5, 1]
end
