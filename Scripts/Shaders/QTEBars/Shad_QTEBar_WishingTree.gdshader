shader_type canvas_item;

uniform sampler2D fill;
uniform vec4 baseColor: source_color;
uniform vec4 l1Color: source_color;
uniform vec4 l2Color: source_color;

uniform vec2 l1Limits;
uniform vec2 l2Limits;

vec4 draw_tap_zone_mask(vec2 uv, float lowerLimit, float upperLimit) {
	vec4 canvas = vec4(1.0);
	canvas.a = step(uv.x, upperLimit) - step(uv.x, lowerLimit);
	return canvas;
}

void fragment() {
	vec4 layer = baseColor;

	vec4 l1 = draw_tap_zone_mask(UV, l1Limits.x, l1Limits.y) * l1Color;
	layer = mix(layer, l1, l1.a);

	vec4 l2 = draw_tap_zone_mask(UV, l2Limits.x, l2Limits.y) * l2Color;
	layer = mix(layer, l2, l2.a);

	vec4 fillColor = texture(fill,UV);
	COLOR = mix(fillColor, layer, COLOR.a);
}
