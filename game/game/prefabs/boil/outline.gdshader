shader_type canvas_item;

uniform vec2 node_size;
uniform vec3 outline_color: source_color = vec3(1.0, 0.0, 0.0);

uniform float thickness = 40.;
uniform float radius = 40.0;
uniform float pixelSize = 12.0;
uniform float softness = 10.0;

uniform float fps = 6.0;
uniform float speed = 50.0;
uniform float amplitude = 5.0;     // how strong the wobble is
uniform float freq = 0.05;   // how many wiggles per unit

float minvec2(vec2 v) {
    return min(v.x, v.y);
}

mat2 rotate2d(float theta) {
    float c = cos(theta);
    float s = sin(theta);
    return mat2(vec2(c, -s), vec2(s, c));
}

float taxicab(vec2 a, vec2 b) {
    return abs(a.x - b.x) + abs(a.y - b.y);
}

float taxicabrot(vec2 a, vec2 b) {
    return taxicab(rotate2d(PI/4.)*a, rotate2d(PI/4.)*b);
}

float minkowski(vec2 a, vec2 b, float p) {
    return pow(pow(abs(a.x - b.x), p) + pow(abs(a.y - b.y), p), 1./p);
}

float cdist(vec2 a, vec2 b) {
	return minkowski(a, b, radius);
}

float box(vec2 position, vec2 halfSize, float cornerRadius) {
   position = abs(position) - halfSize + cornerRadius;
   return length(max(position, 0.0)) + min(max(position.x, position.y), 0.0) - cornerRadius;
}

float circle(vec2 pos, float r) {
    return length(pos) - r;
}

void fragment() {
	float outline = 0.;

	float t = floor(TIME*fps)*speed;
	vec2 uv = vec2(UV.x, 1.-UV.y);
	vec2 pos = (UV - 0.5) * node_size;

    pos = floor(pos / pixelSize) * pixelSize;

    vec2 wpos = pos;
    wpos.x += sin((wpos.y + t) * freq) * amplitude;
    wpos.y += cos((wpos.x + t) * freq) * amplitude;	// pos.y
	pos = wpos;
	
    // pos = floor(pos / pixelSize) * pixelSize;
	float offset = thickness/2.+amplitude+softness;
	vec2 out_size = node_size - vec2(offset);
	vec2 in_size = node_size - vec2(thickness + offset);
	float in_rect = box(pos, in_size/2., radius)/softness;
	float out_rect = box(pos, out_size/2., radius)/softness;
	float mid_rect = clamp(in_rect, 0., 1.) - clamp(out_rect, 0., 1.);

	outline = mid_rect;

	COLOR = vec4(outline_color, outline);
}
