shader_type canvas_item;
uniform vec2 flow_dir = vec2(1.0, 0.0);
uniform float flow_speed = 0.2;
uniform float wave_amp = 0.003;
uniform float wave_freq = 28.0;
uniform float wave_speed = 0.7;

void fragment() {
    vec2 wobble = vec2(sin(UV.y*wave_freq + TIME*wave_speed), 0.0) * wave_amp;
    vec2 uv = fract(UV + flow_dir * (TIME*flow_speed) + wobble);
    COLOR = texture(TEXTURE, uv);
}
