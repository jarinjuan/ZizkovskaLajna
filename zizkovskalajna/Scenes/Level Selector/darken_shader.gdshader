shader_type canvas_item;

uniform float darkness : hint_range(0.0, 1.0) = 1.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);

    // Blend the RGB toward neutral gray (0.5, 0.5, 0.5)
    tex_color.rgb = mix(tex_color.rgb, vec3(0.2), darkness);

    COLOR = tex_color;
}
