// Wicker Cove's fog (CCH-WICKER-COVE-ALPHA-001): a drifting grey over the village, thin round the farmer and
// thicker with distance and toward the sea, so near doors, counters and prompts stay readable while the far
// houses and the harbour soften. Drawn on a ColorRect that covers the view, in world space, on the art-pixel
// grid. The canvas tint darkens it at night like everything else, and the warm lights show through it.
shader_type canvas_item;

uniform vec2 view_origin;            // world px of the rect's top-left
uniform vec2 player_world;
uniform float sea_y = 1056.0;        // world y where the quay meets the water
uniform float tile = 48.0;
uniform vec4 fog_col : source_color = vec4(0.82, 0.85, 0.87, 1.0);
uniform float near_tiles = 3.0;      // clear round the farmer
uniform float far_tiles = 10.0;      // full density from here
uniform float near_a = 0.03;
uniform float far_a = 0.36;
uniform float sea_a = 0.28;          // added over the water
uniform float max_a = 0.72;

varying vec2 world;

void vertex() {
	world = view_origin + VERTEX;
}

float hash(vec2 p) {
	return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
	vec2 i = floor(p);
	vec2 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(hash(i), hash(i + vec2(1.0, 0.0)), f.x), mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), f.x), f.y);
}

void fragment() {
	vec2 w = floor(world / 3.0) * 3.0;                     // one art pixel
	vec2 t = w / tile;
	float n = noise(t * 0.32 + vec2(TIME * 0.045, TIME * 0.018)) * 0.6
		+ noise(t * 0.85 - vec2(TIME * 0.07, -TIME * 0.02)) * 0.4;
	float d = distance(w, player_world) / tile;
	float a = mix(near_a, far_a, smoothstep(near_tiles, far_tiles, d));
	a += smoothstep(sea_y - tile, sea_y + tile * 5.0, w.y) * sea_a;
	a *= 0.7 + 0.6 * n;
	// Stepped, with a 4x4 ordered dither between the steps, like the game's lights.
	int bx = int(mod(w.x / 3.0, 4.0));
	int by = int(mod(w.y / 3.0, 4.0));
	int idx = by * 4 + bx;
	float bayer[16] = float[16](0.0, 8.0, 2.0, 10.0, 12.0, 4.0, 14.0, 6.0, 3.0, 11.0, 1.0, 9.0, 15.0, 7.0, 13.0, 5.0);
	a = floor(a * 10.0 + (bayer[idx] + 0.5) / 16.0) / 10.0;
	COLOR = vec4(fog_col.rgb, clamp(a, 0.0, max_a));
}
