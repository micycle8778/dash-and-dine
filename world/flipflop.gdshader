shader_type canvas_item;
render_mode unshaded;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;


void fragment() {
	vec2 v = vec2(
		distance(1., SCREEN_UV.x),
		distance(1., SCREEN_UV.y)
	);
    vec4 c = textureLod(screen_texture, v, 0.0);

    if (c.a > 0.0001) {
        c.rgb /= c.a;
    }

    COLOR *= c; //
}
