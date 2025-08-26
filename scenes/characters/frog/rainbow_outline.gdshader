shader_type canvas_item;

uniform int outline_size : hint_range(0, 5) = 1;
uniform float speed : hint_range(0.1, 5.0) = 1.0;

// HSV → RGB helper
vec3 hsv2rgb(vec3 c) {
    vec3 rgb = clamp(abs(mod(c.x*6.0 + vec3(0.0,4.0,2.0), 6.0)-3.0)-1.0,0.0,1.0);
    rgb = rgb * rgb * (3.0 - 2.0 * rgb);
    return c.z * mix(vec3(1.0), rgb, c.y);
}

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    vec4 final_color = vec4(0.0);

    if (tex_color.a > 0.1) {
        // Draw original sprite
        final_color = tex_color;
    } else {
        float alpha = 0.0;

        // Check 8 directions around pixel
        for (int x = -outline_size; x <= outline_size; x++) {
            for (int y = -outline_size; y <= outline_size; y++) {
                if (x == 0 && y == 0) continue;

                vec2 offset = vec2(float(x), float(y)) * TEXTURE_PIXEL_SIZE;
                vec2 safe_uv = clamp(UV + offset, vec2(0.0), vec2(1.0));
                alpha = max(alpha, texture(TEXTURE, safe_uv).a);
            }
        }

        if (alpha > 0.1) {
            // Distance from center controls rainbow hue
            vec2 center = vec2(0.5, 0.5);
            float dist = length(UV - center);

            // Add time so it "radiates outward"
            float hue = mod(dist * 1.5 - TIME * speed, 1.0);

            vec3 rgb = hsv2rgb(vec3(hue, 1.0, 1.0));
            final_color = vec4(rgb, 1.0);
        }
    }

    COLOR = final_color;
}
