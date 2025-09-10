shader_type canvas_item;

uniform float percentage : hint_range(0.0, 1.0) = 1.0;
uniform float wave_freq = 8.0;
uniform float wave_amp = 0.03;
uniform float wave_speed = 2.0;

void fragment() {
    vec2 uv = UV;

    // Base fill cutoff (flat top based on percentage)
    float cutoff = 1.0 - percentage;

    // Add wave only to the cutoff line
    float wave = sin(uv.x * wave_freq + TIME * wave_speed) * wave_amp;
    float surface = cutoff + wave;

    if (uv.y >= surface) {
        // Show texture normally below the surface
        COLOR = texture(TEXTURE, uv) * COLOR;
    } else {
        // Hide pixels above surface
        discard;
    }
}
