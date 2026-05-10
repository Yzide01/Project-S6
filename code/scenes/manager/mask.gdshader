shader_type canvas_item;

// Ceci crée une jauge dans l'inspecteur et une variable pour nos scripts
uniform float saturation : hint_range(0.0, 1.0) = 1.0; 
// Ceci capture tout ce qui est dessiné "derrière" ce ColorRect
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    // 1. On lit la couleur d'origine de l'écran à cet endroit
    vec4 color = texture(SCREEN_TEXTURE, SCREEN_UV);
    
    // 2. On calcule sa valeur en noir et blanc (Luma) selon les standards optiques
    float luma = dot(color.rgb, vec3(0.299, 0.587, 0.114));
    vec3 grey = vec3(luma);
    
    // 3. On mixe le gris et la vraie couleur en fonction de notre variable "saturation"
    COLOR = vec4(mix(grey, color.rgb, saturation), color.a);
}