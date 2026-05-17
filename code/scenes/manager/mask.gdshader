shader_type canvas_item;

uniform float saturation : hint_range(0.0, 1.0) = 1.0; 
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
    float luma = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    vec3 grey = vec3(luma);
    
    // CORRECTION : On met 1.0 à la fin pour rendre le filtre opaque et visible
    COLOR = vec4(mix(grey, color.rgb, saturation), 1.0);
}