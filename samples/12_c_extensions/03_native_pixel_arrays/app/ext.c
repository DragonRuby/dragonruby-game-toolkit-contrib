#ifndef NULL
#define NULL 0
#endif
typedef unsigned int Uint32;

extern void *(*drb_symbol_lookup)(const char *sym);
typedef void (*drb_upload_pixel_array_fn)(const char *name, const int w, const int h, const Uint32 *pixels);

void update_scanner_texture(void)
{
    #define dimension 10

    static drb_upload_pixel_array_fn drb_upload_pixel_array = NULL;
    static int pos = 0;
    static int posinc = 1;

    if (!drb_upload_pixel_array) {
        drb_upload_pixel_array = drb_symbol_lookup("drb_upload_pixel_array");
        if (!drb_upload_pixel_array) {
            return;  // oh well.
        }
    }


    // Set up our "scanner" pixel array and fill it with black pixels.

    // You could make this faster by making this array static (which will
    //  initialize it all to zero at startup), and then blanking the previous
    //  line and drawing the next, and not touching the rest.
    Uint32 pixels[dimension * dimension];
    for (int i = 0; i < (dimension * dimension); i++) {
        pixels[i] = 0xFF000000;  // full alpha, full black
    }

    // Draw a green line that bounces up and down the sprite.
    Uint32 *line = pixels + (pos * dimension);
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
    drb_upload_pixel_array("scanner", dimension, dimension, pixels);
}

