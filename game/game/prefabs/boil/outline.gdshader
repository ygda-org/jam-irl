shader_type canvas_item;

uniform vec2 node_size;
uniform vec3 outline_color: source_color = vec3(1.0, 0.99, 0.81);
uniform vec4 bg_color: source_color = vec4(.961, .961, .863, 0.);

uniform float thickness = 40.;
uniform float radius = 40.0;
uniform float pixelSize = 12.0;
uniform float softness = 10.0;

uniform float fps = 6.0;
uniform float frameCount = 4;
uniform float speed = 50.0;
uniform float amplitude = 5.0;     // how strong the wobble is
uniform float freq = 0.05;   // how many wiggles per unit
uniform float noiseStrength = 0.;

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

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

	float t = mod(floor(TIME*fps), frameCount)*speed;
	vec2 uv = vec2(UV.x, 1.-UV.y);
	vec2 pos = (UV - 0.5) * node_size;

    pos = floor(pos / pixelSize) * pixelSize;

    vec2 wpos = pos;
    float noise_val = noise(pos * 0.1 + t * 0.01);
    wpos.x += sin((wpos.y + t) * freq) * amplitude * (0.5 + noise_val * noiseStrength)*2.f;
    wpos.y += cos((wpos.x + t) * freq) * amplitude * (0.5 + noise_val * noiseStrength)*2.f;
	pos = wpos;

    // pos = floor(pos / pixelSize) * pixelSize;
	float offset = thickness/2.+amplitude+softness;
	vec2 out_size = node_size - vec2(offset);
	vec2 in_size = node_size - vec2(thickness + offset);
	float in_rect = box(pos, in_size/2., radius)/softness;
	float out_rect = box(pos, out_size/2., radius)/softness;
	float mid_rect = clamp(in_rect, 0., 1.) - clamp(out_rect, 0., 1.);


	vec4 bg = vec4(bg_color.rgb, bg_color.a*(1.-clamp(out_rect, 0., 1.)));
	outline = mid_rect;

	COLOR = mix(bg, vec4(outline_color, outline), outline);
}
