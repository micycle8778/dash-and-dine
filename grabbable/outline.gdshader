shader_type spatial;
render_mode cull_front, unshaded;

uniform bool enabled = false;

uniform float x_expand: hint_range(1., 2.) = 1.05;
uniform float y_expand: hint_range(1., 2.) = 1.05;
uniform float z_expand: hint_range(1., 2.) = 1.05;

void vertex() {
	VERTEX.x *= x_expand;
	VERTEX.y *= y_expand;
	VERTEX.z *= z_expand;
}

void fragment() {
	if (!enabled) discard;
	float t = TIME / 1.5;
	float x = mod(SCREEN_UV.x + t, 1.);
	ALBEDO = mix(vec3(0.), vec3(0.4, 0.4, 0.3), distance(x, 0.5) * 2.);
}