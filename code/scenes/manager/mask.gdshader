shader_type canvas_item;

uniform float saturation : hint_range(0.0, 1.0) = 1.0; 

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    vec4 color = tex_color * COLOR;
    float luma = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    vec3 grey = vec3(luma);
    
    COLOR = vec4(mix(grey, color.rgb, saturation), color.a);
}