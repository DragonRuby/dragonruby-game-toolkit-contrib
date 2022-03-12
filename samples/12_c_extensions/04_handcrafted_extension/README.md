# Handcrafted C extension

This sample app shows how to build a simple C extension by hands without using
drabonruby-bind.
You'll need a Pro License which can be purchased at http://dragonruby.org.
The sample app is provided in the Standard license for those that are curious
as to what implementing C Extensions looks like.

## The extension

The source code of the extension can be found at `app/extension.c`.
The entry point to the extension is the `drb_register_c_extensions_with_api`
function.
It gives you immediate access to the VM state (`mrb_state`) and gives a handle
to all the APIs exposed via `drb_api_t` object.
It is recommended to save the API object into a global variable so that you can
get access to it later, outside the `drb_register_c_extensions_with_api` function.

The list of exposed APIs can be found at `dragonruby.h`, see the `drb_api_t`
struct.

