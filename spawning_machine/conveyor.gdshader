shader_type spatial;

uniform float speed = 1.;

void fragment() {
	ROUGHNESS = 1.;
	ALBEDO = vec3(.7, .7, .5);

	vec4 v = inverse(MODEL_MATRIX) * INV_VIEW_MATRIX * vec4(VERTEX, 1.);
	float t = step(0.01, v.x) > 0. ? TIME : -TIME;
	float x = mod(v.z * 1.5 + t * 1.25 * speed, 1.);
	ALBEDO *= 1. - step(.07, x);
	ALBEDO *= vec3(smoothstep(2.5, 2.35, abs(v.z)));
}
