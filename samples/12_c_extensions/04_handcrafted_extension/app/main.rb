$gtk.ffi_misc.gtk_dlopen("ext")
include FFI::CExt

puts Adder.new.add_all(1, 2, 3, [4, 5, 6.0])

def tick args
end
