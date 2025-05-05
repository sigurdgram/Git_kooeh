shader_type canvas_item;

uniform vec4 tint: source_color = vec4(1.0);
uniform float strength: hint_range(0.0, 5.0) = 0.0;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV, strength);
	COLOR = color * tint;
}
