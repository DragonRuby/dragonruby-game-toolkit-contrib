$gtk.ffi_misc.gtk_dlopen("./samples/12_c_extensions/01_basics/build.dir/ext.lib")
include FFI::CExt

def tick args
  args.outputs.labels << [460, 600, "square(42) = #{square(42)}"]
end

