shader_type canvas_item;

uniform float distortion_strength : hint_range(0.0, 0.2) = 0.05;
uniform float speed = 0.5;
uniform sampler2D noise_tex;

void fragment() {
    vec2 uv = UV;
    
    // Чтение шума
    vec2 noise_uv1 = uv * 2.5 + vec2(TIME * speed * 0.2, TIME * speed * 0.1);
    vec2 noise_uv2 = uv * 4.0 - vec2(TIME * speed * 0.15, TIME * speed * 0.25);

    vec2 n1 = texture(noise_tex, noise_uv1).rg * 2.0 - 1.0;
    vec2 n2 = texture(noise_tex, noise_uv2).rg * 2.0 - 1.0;

    vec2 distortion = (n1 + n2 * 0.5) * distortion_strength;

    COLOR = texture(TEXTURE, uv + distortion);
}
