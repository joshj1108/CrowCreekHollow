shader_type canvas_item;

// A full-screen pass over the world: a little more contrast and colour, warm highlights,
// cool shadows, a soft vignette at the edges, and a fine grain so flat areas feel lived in.
uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform float saturation = 1.08;
uniform float contrast = 1.06;
uniform float warmth = 0.035;
uniform float vignette = 0.32;
uniform float grain = 0.025;

void fragment() {
	vec4 c = texture(screen_tex, SCREEN_UV);
	float l = dot(c.rgb, vec3(0.299, 0.587, 0.114));
	c.rgb = mix(vec3(l), c.rgb, saturation);
	c.rgb = (c.rgb - 0.5) * contrast + 0.5;
	c.rgb += vec3(warmth, warmth * 0.35, -warmth * 0.6) * smoothstep(0.4, 0.9, l);
	c.rgb += vec3(-0.012, 0.0, 0.02) * (1.0 - smoothstep(0.0, 0.5, l));
	float d = length((SCREEN_UV - 0.5) * vec2(1.0, 1.15));
	c.rgb *= 1.0 - smoothstep(0.42, 0.95, d) * vignette;
	float n = fract(sin(dot(SCREEN_UV * vec2(1280.0, 720.0) + vec2(TIME * 37.0, TIME * 11.0), vec2(12.9898, 78.233))) * 43758.5453);
	c.rgb += (n - 0.5) * grain;
	COLOR = vec4(clamp(c.rgb, 0.0, 1.0), 1.0);
}
