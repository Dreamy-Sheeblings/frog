shader_type canvas_item;

uniform bool flash_enabled = false;
uniform float flash_speed : hint_range(0.1, 10.0) = 2.0;
uniform vec4 flash_color : source_color = vec4(1.0, 0.0, 0.0, 1.0); // default red

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    if (flash_enabled) {
        float flash_value = (sin(TIME * flash_speed) * 0.5) + 0.5;
        tex_color = mix(tex_color, vec4(flash_color.rgb, tex_color.a), flash_value);
    }

    COLOR = tex_color;
}
