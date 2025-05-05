shader_type canvas_item;

uniform vec2 size;
uniform vec2 position;
uniform float aa = 0.001;

vec2 scale(vec2 uv, float x, float y) {
	mat2 scale = mat2(vec2(x, 0.0f), vec2(0.0f, y));
	
	//uv -= 0.5f;
	uv = uv * scale;
	//uv += 0.5f;
	return uv;
}

float rect_rounded(vec2 uv, float width, float height, float radius) {
   float rw = radius * width;
   float rh = radius * height;
   
   vec2 abs_uv = abs(uv.xy) - vec2(rw, rh);
   vec2 dist = vec2(max(abs_uv.xy, 0.0));
   
   float xedge = width - rw;
   float xsquare = 1.0 - smoothstep(xedge, xedge + aa, length(dist));
   
   float yedge = height - rh;
   float ysquare = 1.0 - smoothstep(yedge, yedge + aa, length(dist));
   
   float ss = xsquare * ysquare;
   
   return ss;
}

void fragment() {
	vec4 layer = vec4(vec3(0.0f), 0.75f);
	vec2 s3 = vec2(0.267f, 0.237f) * 0.5f;
	float roundedRect = rect_rounded(UV - size - position, size.x, size.y, 0.9f);
	
	layer.a *= 1.0 - roundedRect;
	COLOR = layer;
}
