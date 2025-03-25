shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;

void fragment() {
	vec4 c = textureLod(screen_texture, SCREEN_UV, 0.);
	float dist = distance(UV, vec2(.5));
	
	float t = 1. - smoothstep(.1, .12, dist);
	t *= smoothstep(.08, .095, dist);
	c.xyz = mix(c.xyz, vec3(1.) - c.xyz, t);
	
	COLOR *= c;
}
