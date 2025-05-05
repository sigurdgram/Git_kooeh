shader_type canvas_item;

varying flat vec4 modulate;
global uniform vec4 highlightColor;
uniform bool useCustomColor;
uniform vec4 customColor: source_color;
uniform float line_thickness : hint_range(0.0f, 1.0f) = 0.04f;
uniform float uvRescale: hint_range(0.1f, 10.0f) = 1.0f;
uniform float vertexRescale: hint_range(1.0f, 10.0f) = 1.0f;
uniform vec2 vertexOffset;
uniform int resolution = 9;
uniform bool enabled = true;

void vertex() {
	modulate = COLOR;
	if (enabled && resolution > 0 && line_thickness > 0.0f) {
		VERTEX *= vertexRescale + vertexOffset;
	}
}

vec2 scale(vec2 uv, float x, float y) {
	mat2 scale = mat2(vec2(x, 0.0f), vec2(0.0f, y));

	uv -= 0.5f;
	uv = uv * scale;
	uv += 0.5f;
	return uv;
}

vec4 texture_sample(sampler2D tex, vec2 uv) {
	vec4 image = texture(tex, uv);
	image *= step(uv.x, 1.0f) - step(uv.x, 0.0f);
	image *= step(uv.y, 1.0f) - step(uv.y, 0.0f);
	return image;
}

void fragment() {
	if (enabled) {
		vec2 uv = scale(UV, vertexRescale * uvRescale, vertexRescale * uvRescale) + vertexOffset;
		float outline = 0.0f;
		vec4 image = texture_sample(TEXTURE, uv) * modulate;

		if (resolution <= 0 || line_thickness <= 0.0f) {
			COLOR = image;
		} else {
			float sector = 360.0f / float(resolution);
			for (int i = 0; i < resolution; i ++) {
				float angle = sector * float(i);
				float x = sin(angle) * line_thickness;
				float y = cos(angle) * line_thickness;
				outline += texture_sample(TEXTURE, uv + vec2(x, y)).a;
			}
			outline = min(outline, 1.0f);

			vec4 color = useCustomColor ? customColor : highlightColor;
			COLOR = mix(image, color, outline - image.a);
		}
	}
}