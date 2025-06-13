shader_type canvas_item;


uniform float speed = 5;
uniform float amplitude = 0.015;


void fragment() {
    // Calculate vertical offset (hovering)
    float offset = sin(TIME * speed) * amplitude;

    // Offset the UV vertically
    vec2 uv = UV + vec2(0.0, offset);

    // Clamp UVs so we don't sample outside the texture
    uv = clamp(uv, vec2(0.0), vec2(1.0));

    COLOR = texture(TEXTURE, uv);
}
