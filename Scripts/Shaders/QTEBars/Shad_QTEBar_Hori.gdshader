shader_type canvas_item;
uniform vec2 sectorLimits[4];

//0 is OneShot, 1 is PingPong
uniform int processMode: hint_range(0, 1, 1);
uniform float progress: hint_range(0.0, 1.0, 0.001);
uniform vec3 baseColor: source_color;
uniform vec3 tapZoneColor: source_color;
uniform vec3 progressColor: source_color;

float remap_range( float value, float leftMin, float leftMax, float rightMin, float rightMax ) {
  return rightMin + (value - leftMin) * (rightMax - rightMin) / (leftMax - leftMin);
}

vec4 draw_tap_zone_mask(vec2 uv, float lowerLimit, float upperLimit) {
	vec4 canvas = vec4(0.0);
	canvas.a = step(uv.x, upperLimit) - step(uv.x , lowerLimit);
	return canvas;
}

vec4 draw_progress(vec2 uv) {
	vec4 canvas = vec4(progressColor, 1.0);
	vec4 zone = draw_tap_zone_mask(uv, 0.0, progress);
	canvas.a *= zone.a;

	return canvas;
}

void fragment() {
	//draw base
	vec4 layer = vec4(baseColor, 1.0f);

	//draw segments
	vec4 zones = vec4(1.0);
	for (int i = 0; i < sectorLimits.length(); i++) {
		float x = sectorLimits[i].x;
		float y = sectorLimits[i].y;

		if (x == 0.0 && y == 0.0)
			continue;

		vec4 zone = draw_tap_zone_mask(UV, x, y);
		if (i == 0) {
			zones = zone;
		} else {
			zones = mix(zones, zone, zone.a);
		}
	}
	vec4 tapZones = vec4(tapZoneColor, 1.0f);
	tapZones.a *= zones.a;
	layer = mix(layer, tapZones, tapZones.a);

	//draw progress
	if (processMode == 0) {
		vec4 progressVec = draw_progress(UV);
		layer = mix(layer, progressVec, progressVec.a);
	}

	layer *= texture(TEXTURE, UV);
	COLOR = layer;
}
