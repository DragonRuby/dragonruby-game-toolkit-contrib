# dragonruby-bind doc

This document describes how to use `dragonruby-bind` and also covers some
implementation details that will help to build the right mental model

### Hello World

Create a simple file `bridge.c` with the following content:

```c
double square(double d) {
  return d * d;
}
```

Now, generate bindings:

```bash
dragonruby-bind bridge.c --output=bindings.c
```

The output file `bindings.c` will contain something like the following:

```c
#include <mruby.h>
#include <string.h>
#include <assert.h>
#include <mruby/string.h>
#include <mruby/data.h>
#include <dragonruby.h>
#include "bridge.c"

// MRuby `typedef`s mrb_int in the mruby/value.h
// Then `#define`s mrb_int in mruby.h
// We need to undo the macro and avoid it's usage
// FIXME: I'm surely doing something wrong
#ifdef mrb_int
#undef mrb_int
#endif

void *(*drb_symbol_lookup)(const char *sym) = NULL;

static void (*drb_free_foreign_object_f)(mrb_state *, void *);
static struct RClass *(*mrb_module_get_f)(mrb_state *, const char *);
static mrb_int (*mrb_get_args_f)(mrb_state *, mrb_args_format, ...);
static struct RClass *(*mrb_module_get_under_f)(mrb_state *, struct RClass *, const char *);
static struct RClass *(*mrb_class_get_under_f)(mrb_state *, struct RClass *, const char *);
static struct RClass *(*mrb_define_module_under_f)(mrb_state *, struct RClass *, const char *);
static void (*mrb_define_module_function_f)(mrb_state *, struct RClass *, const char *, mrb_func_t, mrb_aspec);
static struct RClass *(*mrb_define_class_under_f)(mrb_state *, struct RClass *, const char *, struct RClass *);
static void (*mrb_define_method_f)(mrb_state *, struct RClass *, const char *, mrb_func_t, mrb_aspec);
static void (*mrb_define_class_method_f)(mrb_state *, struct RClass *, const char *, mrb_func_t, mrb_aspec);
static struct RData *(*mrb_data_object_alloc_f)(mrb_state *, struct RClass *, void *, const mrb_data_type *);
static mrb_value (*mrb_str_new_cstr_f)(mrb_state *, const char *);
static void (*mrb_raise_f)(mrb_state *, struct RClass *, const char *);
static struct RClass *(*mrb_exc_get_f)(mrb_state *, const char *);
static void drb_free_foreign_object_indirect(mrb_state *state, void *pointer) {
    drb_free_foreign_object_f(state, pointer);
}
static double drb_ffi__ZTSd_FromRuby(mrb_state *state, mrb_value self) {
    return mrb_float(self);
}
static mrb_value drb_ffi__ZTSd_ToRuby(mrb_state *state, double value) {
    return mrb_float_value(state, value);
}
static mrb_value drb_ffi_square_Binding(mrb_state *state, mrb_value value) {
    mrb_value *args = 0;
    mrb_int argc = 0;
    mrb_get_args_f(state, "*", &args, &argc);
    double d_0 = drb_ffi__ZTSd_FromRuby(state, args[0]);
    double ret_val = square(d_0);
    return drb_ffi__ZTSd_ToRuby(state, ret_val);
}
static int drb_ffi_init_indirect_functions(void *(*lookup)(const char *));
DRB_FFI_EXPORT
void drb_register_c_extensions(void *(*lookup)(const char *), mrb_state *state, struct RClass *FFI) {
    if (drb_ffi_init_indirect_functions(lookup))
        return;
    struct RClass *module = mrb_define_module_under_f(state, FFI, "CExt");
    struct RClass *object_class = state->object_class;
    mrb_define_module_function_f(state, module, "square", drb_ffi_square_Binding, MRB_ARGS_REQ(1));
}
static int drb_ffi_init_indirect_functions(void *(*lookup)(const char *fnname)) {
  drb_symbol_lookup = lookup;
  if (!(drb_free_foreign_object_f = (void (*)(mrb_state *, void *)) lookup("drb_free_foreign_object"))) return -1;
  if (!(mrb_class_get_under_f = (struct RClass *(*)(mrb_state *, struct RClass *, const char *)) lookup("mrb_class_get_under"))) return -1;
  if (!(mrb_data_object_alloc_f = (struct RData *(*)(mrb_state *, struct RClass *, void *, const mrb_data_type *)) lookup("mrb_data_object_alloc"))) return -1;
  if (!(mrb_define_class_method_f = (void (*)(mrb_state *, struct RClass *, const char *, mrb_func_t, mrb_aspec)) lookup("mrb_define_class_method"))) return -1;
  if (!(mrb_define_class_under_f = (struct RClass *(*)(mrb_state *, struct RClass *, const char *, struct RClass *)) lookup("mrb_define_class_under"))) return -1;
  if (!(mrb_define_method_f = (void (*)(mrb_state *, struct RClass *, const char *, mrb_func_t, mrb_aspec)) lookup("mrb_define_method"))) return -1;
  if (!(mrb_define_module_function_f = (void (*)(mrb_state *, struct RClass *, const char *, mrb_func_t, mrb_aspec)) lookup("mrb_define_module_function"))) return -1;
  if (!(mrb_define_module_under_f = (struct RClass *(*)(mrb_state *, struct RClass *, const char *)) lookup("mrb_define_module_under"))) return -1;
  if (!(mrb_exc_get_f = (struct RClass *(*)(mrb_state *, const char *)) lookup("mrb_exc_get"))) return -1;
  if (!(mrb_get_args_f = (mrb_int (*)(mrb_state *, mrb_args_format, ...)) lookup("mrb_get_args"))) return -1;
  if (!(mrb_module_get_f = (struct RClass *(*)(mrb_state *, const char *)) lookup("mrb_module_get"))) return -1;
  if (!(mrb_module_get_under_f = (struct RClass *(*)(mrb_state *, struct RClass *, const char *)) lookup("mrb_module_get_under"))) return -1;
  if (!(mrb_raise_f = (void (*)(mrb_state *, struct RClass *, const char *)) lookup("mrb_raise"))) return -1;
  if (!(mrb_str_new_cstr_f = (mrb_value (*)(mrb_state *, const char *)) lookup("mrb_str_new_cstr"))) return -1;
  return 0;
}
```

Compile this as a shared library:

```c
# DRB_ROOT is the path to the gtk source directory
clang -shared \
  -isystem $DRB_ROOT/mruby/include/ \
  -isystem $DRB_ROOT/ \
  -o native/macos/bindings.dylib \
  bindings.c
```

Now, somewhere within `main.rb` do the following:

```rb
# Teach DRGTK about the bindings
$gtk.ffi_misc.dlopen("bindings")
# Use the `square` function seamlessly
puts FFI::CExt::square(42)
# yeilds: 1764.0
```

This is the bare minimum that is needed to start using the C extensions.

Now, more complex parts.

### DRB FFI

It is a good idea to include `dragonruby.h` into the C bridging file. It comes with
a number of helpful macros. As an example, you can specify for which functions
to generate bindings or change the name under which the function is available from
DRGTK:

```c
#include <dragonruby.h>

/// Binding for this function won't be generated
void something_useless() {
  /// ....
}

/// This one is accessible from Ruby as `square`
DRB_FFI
double square(double d) {
  return d * d;
}

/// This one is accessible from Ruby as `sqr_int`
DRB_FFI_NAME("sqr_int")
int ffi_square_int(int d) {
  return d * d;
}
```

_Note: It is always a good idea to mark your functions with `DRB_FFI` or
`DRB_FFI_NAME` explicitly. Support for unannotated functions is meant for
third-party libraries._

### Structs

It is possible to use C structs from DRGTK. Here is a C example and its
corresponding usage from Ruby.

```c
#include <dragonruby.h>

typedef struct Point {
  int x;
  int y;
} Point;

DRB_FFI
void printPoint(Point p) {
  printf("Point(%d, %d)\n", p.x, p.y);
}

DRB_FFI
Point fourtyPoint() {
  Point p;
  p.x = 42;
  p.y = 42;
  return p;
}
```

Here is how to use it in the Ruby code:

```ruby
$gtk.ffi_misc.gtk_dlopen("bindings")
include FFI::CExt
p = Point.new
p.x = 15
p.y = 22
printPoint(p)

p2 = fourtyPoint()
puts "Point(#{p2.x}, #{p2.y}) (from Ruby)"
p2.x = 152
puts "Point(#{p2.x}, #{p2.y}) (from Ruby)"
```

The output will be:

```
Point(15, 22)
Point(42, 42) (from Ruby)
Point(152, 42) (from Ruby)
```

### Pointers

Here is how to use pointers:

```c
#include <dragonruby.h>

DRB_FFI
int *createInts(int size) {
  int *ints = calloc(size, sizeof(int));
  return ints;
}

DRB_FFI
void printInts(int *ints, int size) {
  printf("int array: ");
  for (int i = 0; i < size; i++) {
    printf("%d ", ints[i]);
  }
  printf("\n");
}

DRB_FFI
void free_ints(int *ints) {
  free(ints);
}
```

The usage:

```rb
$gtk.ffi_misc.gtk_dlopen("bindings")
include FFI::CExt
ints = createInts(10)
10.times do |i|
  ints[i] = i
end
printInts(ints, 10)
freeInts(ints)

p = IntPointer.new
p[0] = 15
printInts(p, 1)
puts "print int from ruby: #{p[0]}"
```

The output:

```
print ints from C: 0 1 2 3 4 5 6 7 8 9
print ints from C: 15
print int from ruby: 15
```

Important part here is the memory ownership.
In the case of `createInts` the points is allocated in the C land, and therefore
it should be deallocated in the C land. It is a responsibility of developer to
take care of this memory.

In the case of `IntPointer.new` the pointer is allocated in the Ruby land, and
therefore it will be deallocated by DRGTK, without any need to worry about the
ownership.

### C Strings

Technically, the C string is a just a pointer, i.e.: `char *`. But we provide
some convenient sugar. Here is an example:

```c
#include <dragonruby.h>

DRB_FFI
char *allocateString() {
  char *str = calloc(6, sizeof(char));
  str[0] = 'h';
  str[1] = 'e';
  str[2] = 'l';
  str[3] = 'l';
  str[4] = 'o';
  str[5] = '\n';
  return str;
}

DRB_FFI
void freeString(char *s) {
  free(s);
}

DRB_FFI
void printString(char *s) {
  printf("hello from C: %s\n", s);
}

DRB_FFI
char *getStaticString() {
  return "Some static string";
}
```

Usage:

```rb
$gtk.ffi_misc.gtk_dlopen("bindings")
include FFI::CExt
s1 = allocateString()
printString(s1)
freeString(s1)

printString("or Ruby?")

s2 = getStaticString()
printString(s2)
puts "print C string from Ruby #{s2.str}"
```

Output:

```
hello from C: hello
hello from C: or Ruby?
hello from C: Some static string
print C string from Ruby: Some static string
```

General rules are the same as with any other pointers, but there are few more
additional notes:

 - `CharPointer`s have `str` method that returns a normal Ruby string
 - Ruby strings automatically converted to `char *`, as in the `printString("or Ruby?")`

### CExt

In order to avoid clashes and name collisions all the bridging functions are put
under a separate module (or namespace) under `FFI`. By default, the name `CExt`
is used, but it can be changed to anything else via the `--ffi-module` module, e.g.:

```bash
dragonruby-bind --ffi-module=CoolStuff bridge.c
```

Then one can use `include FFI::CoolStuff` instead.

### Type checks

C extensions expect the right types in the right place!

Given the following C code:

```c
void take_int(int x) { ... }
void take_struct(struct S) { ... }
```

the next calls from the Ruby side

```ruby
take_int(15.0)
take_struct(42)
```

may not work as you would expect.
In the case of `take_int`, you'll likely see some garbage instead of "expected" `15`.
The call to `take_struct` will likely crash.

To prevent this from happening, `dragonruby-bind` emits code that does type checking:
if you use the wrong types DragonRuby will throw an exception.

If the type checking takes CPU cycles out of your game (or if you feel brave) you can
disable type checks via `--no-typecheck` CLI argument when emitting C bindings.

### Pitfalls

There is no so-called marshalling when it comes to structs. When you read or
write to a struct field you are writing to the underlying C struct, which brings
some unexpected results. The following structs can be easily used from Ruby:

```c
typedef struct Point {
  int x;
  int y;
} Point;

typedef struct Size {
  int width;
  int height;
} Size;

typedef struct Rectangle {
  Point origin;
  Size size;
} Rectangle;
```

```rb
o = Point.new
o.x = 15
o.y = 25

s = Size.new
s.width = 150
s.height = 250

r = Rectangle.new
r.origin = o
r.size = s


puts "#{r.origin.x}, #{r.origin.y}"  #1

r.origin.x = 42                      #2

puts "#{r.origin.x}, #{r.origin.y}"  #3

p = r.origin
p.x = 42
r.origin = p
puts "#{r.origin.x}, #{r.origin.y}"  #4
```

In this example `15, 25` will be printed at line `#1`, after the assignment at `#2`
the same string will be printed `15, 25` at line `#3`.
That's because each `.` in Ruby returns a new object, in this case `p.origin`
returns a copy of the original `Point`. The right way to handle this case is right
before `#4`.

### Rough edges

Currently, there are no type checks and no checks on the number of arguments.
If you call a C function that expects an integer with a double - it may give some
garbage. If you call a C function with more or fewer arguments, then it may give
some garbage, or crash. This will come in later.

