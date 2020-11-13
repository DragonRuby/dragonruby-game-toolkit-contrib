Please see samples/12_c_extensions/01_basics for the overview of C extensions.

This sample reproduces the same program from
samples/07_advanced_rendering/06_pixel_arrays, but moves the creation of the
pixel array to C code.

This particular use-case doesn't need heavier processing power, so you are
only risking problems and portability loss by moving into native code, but
for more computationally demanding jobs, this can be quite helpful: not only
can C crunch numbers and access memory faster, but you can also hand your
pixel array to the renderer without having to convert it to a Ruby array
first (which the engine would then just convert it right back again anyhow).

