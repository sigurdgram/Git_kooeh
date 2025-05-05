shader_type canvas_item;
uniform vec2 sectorLimits[4];

//0 is OneShot, 1 is PingPong
uniform int processMode: hint_range(0, 1, 1);
uniform float progress: hint_range(0.0, 1.0, 0.01);
uniform vec3 tapZoneColor: source_color;
uniform vec3 borderColor: source_color = vec3(1.0);
uniform vec3 progressColor: source_color;
uniform vec3 baseColor: source_color;

vec4 draw_progress(vec2 uv, float angleNormalized) {
	vec4 canvas = vec4(progressColor, 1.0f);
	float polar = (atan(-uv.x, uv.y) + PI) * 0.5;
	float dist = length(uv);

	angleNormalized *= PI;

	float dmin = polar - angleNormalized;
	dmin = mod(dmin + PI, TAU) - PI;
	float dmax = polar - angleNormalized;
	dmax = mod(dmax + PI, TAU) - PI;

	float b = max(0.0, step(0.0, dmax * dist));
	canvas *= vec4(borderColor, 1.0 - b);
	return canvas;
}

vec4 draw_tap_zones(vec2 uv, float angleMin, float angleMax) {
	vec4 canvas = vec4(tapZoneColor, 1.0f);
	float polar = (atan(-uv.x, uv.y) + PI) * 0.5;
	float dist = length(uv);

	angleMin = angleMin / 360.0f * PI;
	angleMax = angleMax / 360.0f * PI;

	float dmin = polar - angleMin;
	dmin = mod(dmin + PI, TAU) - PI;

	float dmax = polar - angleMax;
	dmax = mod(dmax + PI, TAU) - PI;

	float b = max(step(dmin * dist, 0.0), step(0.0, dmax * dist));
	canvas.a *= 1.0 - b;
	return canvas;
}

void fragment() {
	vec2 uv = UV - 0.5;
	float angle = atan(-uv.x, -uv.y);
	float mask = 1.0;
	float d = length(uv);

	vec4 layer = vec4(baseColor, 1.0);

	//Segments
	vec4 zones = vec4(0.0);
	for (int i = 0; i < sectorLimits.length(); i ++)
	{
		float x = sectorLimits[i].x;
		float y = sectorLimits[i].y;

		if (x == 0.0 && y == 0.0) {
			continue;
		}

		vec4 zone = draw_tap_zones(uv, x, y);
		zones = mix(zones, zone, zone.a);
	}

	layer = mix(layer, zones, zones.a);

	//Progress
	if (processMode == 0) {
		float progressAngle = smoothstep(0.0, TAU, progress);
		vec4 progressVec = draw_progress(uv, progress);
		layer = mix(layer, progressVec, progressVec.a);
	}

	layer *= texture(TEXTURE, UV);
	COLOR = layer;
}
