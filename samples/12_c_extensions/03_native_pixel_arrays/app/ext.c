#include <dragonruby.h>

static drb_api_t *drb_api;

DRB_FFI
mrb_value update_scanner_texture(mrb_state *state, mrb_value value)
{
    #define dimension 10

    static int pos = 0;
    static int posinc = 1;

    // Set up our "scanner" pixel array and fill it with black pixels.

    // You could make this faster by making this array static (which will
    //  initialize it all to zero at startup), and then blanking the previous
    //  line and drawing the next, and not touching the rest.
    uint32_t pixels[dimension * dimension];
    for (int i = 0; i < (dimension * dimension); i++) {
        pixels[i] = 0xFF000000;  // full alpha, full black
    }

    // Draw a green line that bounces up and down the sprite.
    uint32_t *line = pixels + (pos * dimension);
    for (int i = 0; i < dimension; i++) {
        line[i] = 0xFF00FF00;   // full alpha, full green
    }

    // Adjust position for next frame.
    pos += posinc;
    if ((posinc > 0) && (pos >= dimension)) {
        posinc = -1;
        pos = dimension - 1;
    } else if ((posinc < 0) && (pos < 0)) {
        posinc = 1;
        pos = 1;
    }

    // Send it to the renderer to create/update a sprite.
    drb_api->drb_upload_pixel_array("scanner", dimension, dimension, pixels);
    return mrb_nil_value();
}

DRB_FFI_EXPORT
void drb_register_c_extensions_with_api(mrb_state *state, struct drb_api_t *api) {
  drb_api = api;
  struct RClass *FFI = drb_api->mrb_module_get(state, "FFI");
  struct RClass *module = drb_api->mrb_define_module_under(state, FFI, "CExt");
  drb_api->mrb_define_module_function(state, module, "update_scanner_texture", update_scanner_texture, MRB_ARGS_REQ(0));
}
