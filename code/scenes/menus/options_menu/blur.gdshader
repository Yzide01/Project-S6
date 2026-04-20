shader_type canvas_item;

uniform float lod: hint_range(0.0, 5.0) = 2.0;
uniform vec4 tint_color: source_color = vec4(0.0, 0.0, 0.0, 0.4);
uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear_mipmap;

void fragment(){
	vec4 color = textureLod(screen_texture, SCREEN_UV, lod);
	COLOR = mix(color, tint_color, tint_color.a);
}
