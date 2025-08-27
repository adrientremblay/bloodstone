shader_type canvas_item;

uniform sampler2D screen_texture:hint_screen_texture,repeat_disable,filter_nearest;
uniform float intensity : hint_range(0.0, 1.0) = 0.0;

//void vertex() {
	//// Called for every vertex the material is visible on.
//}

void fragment() {
	vec3 color = texture(screen_texture, SCREEN_UV).rgb;
	color.g *= (1.0 - intensity);
	color.b *= (1.0 - intensity);
	COLOR.rgb = color;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
