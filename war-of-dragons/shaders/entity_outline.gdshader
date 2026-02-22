shader_type spatial;
render_mode unshaded, cull_front, depth_draw_always;

uniform vec4 outline_color : source_color = vec4(1.0, 0.0, 0.0, 1.0);
uniform float outline_size = 0.05;

void vertex() {
	// Called for every vertex the material is visible on.
	VERTEX += NORMAL * outline_size;
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = outline_color.rgb;
    ALPHA = outline_color.a;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
