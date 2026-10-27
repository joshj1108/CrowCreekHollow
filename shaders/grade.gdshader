shader_type canvas_item;

// A full-screen pass over the world, for a grim, overcast mood: colour pulled well down, the whole scene
// a little darker, a touch more contrast, faint warmth in the highlights, cold blue-grey shadows, a heavy
// vignette at the edges, and a fine grain so flat areas feel lived in.
uniform sampler2D screen_tex : hint_screen_texture, filter_linear_mipmap;
uniform float saturation = 0.62;
uniform float exposure = 0.84;
uniform float contrast = 1.1;
uniform float warmth = 0.02;
uniform float shadow_cool = 0.035;
uniform float vignette = 0.55;
uniform float grain = 0.025;

void fragment() {
	vec4 c = texture(screen_tex, SCREEN_UV);
	float l = dot(c.rgb, vec3(0.299, 0.587, 0.114));
	c.rgb = mix(vec3(l), c.rgb, saturation);
	c.rgb *= exposure;
	c.rgb = (c.rgb - 0.5) * contrast + 0.5;
	c.rgb += vec3(warmth, warmth * 0.35, -warmth * 0.6) * smoothstep(0.45, 0.9, l);
	c.rgb += vec3(-shadow_cool * 0.6, 0.0, shadow_cool) * (1.0 - smoothstep(0.0, 0.5, l));
	float d = length((SCREEN_UV - 0.5) * vec2(1.0, 1.15));
	c.rgb *= 1.0 - smoothstep(0.32, 0.9, d) * vignette;
	float n = fract(sin(dot(SCREEN_UV * vec2(1280.0, 720.0) + vec2(TIME * 37.0, TIME * 11.0), vec2(12.9898, 78.233))) * 43758.5453);
	c.rgb += (n - 0.5) * grain;
	COLOR = vec4(clamp(c.rgb, 0.0, 1.0), 1.0);
}
