shader_type canvas_item;

// ART-OVERHAUL-002 E5: the farm's baked ground by season. The grass (green, saturated pixels) takes a hue shift and
// a saturation and value scale, then a frost mix in winter, and a patchy dusting of snow on snowy days. Paths, stone,
// water and soil (other hues, or unsaturated) are untouched. tools/aoh2_e5.py applies the same numbers to the trek
// grounds (SEASON_GRASS). All zeros and ones leave the ground as baked.
uniform float hue_shift = 0.0;
uniform float sat_scale = 1.0;
uniform float val_scale = 1.0;
uniform float frost = 0.0;
uniform vec3 frost_color = vec3(0.62, 0.66, 0.70);
uniform float snow = 0.0;
uniform vec3 snow_color = vec3(0.86, 0.89, 0.93);
// The baked autumn leaf litter (bright red and orange, saturated) takes this colour by brightness out of autumn:
// grass green in spring and summer, a dull brown in winter. 0 keeps the litter.
uniform float litter = 0.0;
uniform vec3 litter_color = vec3(0.24, 0.34, 0.18);

varying vec4 tint;

vec3 rgb2hsv(vec3 c) {
	vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
	vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
	vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
	float d = q.x - min(q.w, q.y);
	float e = 1.0e-10;
	return vec3(abs(q.z + (q.w - q.y) / (6.0 * d + e)), d / (q.x + e), q.x);
}

vec3 hsv2rgb(vec3 c) {
	vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
	vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
	return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

float grass_weight(vec3 hsv) {
	float ks = clamp((hsv.y - 0.12) / 0.1, 0.0, 1.0);
	float h = hsv.x;
	float w = (h >= 0.18 && h <= 0.42) ? 1.0 : 0.0;
	if (h >= 0.14 && h < 0.18) w = (h - 0.14) / 0.04;
	if (h > 0.42 && h <= 0.48) w = (0.48 - h) / 0.06;
	return w * ks;
}

void vertex() {
	tint = COLOR;
}

void fragment() {
	vec4 t = texture(TEXTURE, UV);
	vec3 hsv = rgb2hsv(t.rgb);
	float w = grass_weight(hsv);
	vec3 c = t.rgb;
	float leaf = ((hsv.x < 0.12 || hsv.x > 0.95) && hsv.y > 0.55 && hsv.z > 0.4) ? litter : 0.0;
	if (leaf > 0.0) {
		c = mix(c, litter_color * (0.55 + 0.9 * hsv.z), leaf);
	}
	if (w > 0.0) {
		vec3 s = vec3(fract(hsv.x + hue_shift * w), min(1.0, hsv.y * (1.0 + (sat_scale - 1.0) * w)), min(1.0, hsv.z * (1.0 + (val_scale - 1.0) * w)));
		c = hsv2rgb(s);
		c = mix(c, frost_color, frost * w);
		if (snow > 0.0) {
			// Patchy by art pixel: brighter grass catches more snow, so it reads as drifts on the tufts.
			vec2 px = floor(UV / TEXTURE_PIXEL_SIZE);
			float n = fract(sin(dot(floor(px / 2.0), vec2(12.9898, 78.233))) * 43758.5453);
			float cover = clamp(snow * (0.55 + 0.6 * hsv.z + 0.35 * n), 0.0, 0.9);
			c = mix(c, snow_color * (0.85 + 0.15 * hsv.z), cover * w);
		}
	}
	COLOR = vec4(c, t.a) * tint;
}
