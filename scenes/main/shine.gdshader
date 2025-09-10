shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec4 screen_color = texture(SCREEN_TEXTURE, SCREEN_UV);
    vec4 rect_color = COLOR; // this is your tweened ColorRect color

    // Respect alpha properly
    COLOR = mix(screen_color, rect_color, rect_color.a);
}
