shader_type canvas_item;

uniform float time_speed : hint_range(0.1, 5.0) = 1.0;
uniform float noise_intensity : hint_range(0.0, 1.0) = 0.3;
uniform float line_thickness : hint_range(0.0, 0.05) = 0.02;
uniform float glitch_strength : hint_range(0.0, 0.2) = 0.05;

uniform sampler2D screen_texture : hint_screen_texture;

float random(float x) {
    return fract(sin(x) * 43758.5453);
}

void fragment() {
    vec2 uv = UV;

    float scanline = sin(uv.y * 500.0 + TIME * time_speed) * line_thickness;

    float glitch = step(0.9, random(TIME + uv.y * 100.0)) * glitch_strength;
    float noise = random(uv.y + TIME * time_speed) * noise_intensity;
    vec3 color = texture(screen_texture, uv + vec2(glitch, 0.0)).rgb;

    color += scanline;
    color += noise;

    COLOR = vec4(color, 1.0);
}
