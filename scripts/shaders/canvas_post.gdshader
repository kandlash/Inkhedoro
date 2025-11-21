shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

uniform float grayscale_strength : hint_range(0.0, 1.0) = 1.0;
uniform float light_preserve_strength : hint_range(0.0, 1.0) = 0.3;
uniform float vignette_strength : hint_range(0.0, 1.5) = 1.0;
uniform float blur_intensity : hint_range(0.0, 1.0) = 0.15;
uniform float blue_fade : hint_range(0.0, 1.0) = 0.7;
uniform float noise_strength : hint_range(0.0, 0.5) = 0.1;
uniform float distortion_strength : hint_range(0.0, 0.2) = 0.05;

float rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898,78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;

    // Slight screen distortion
    vec2 distortion = uv + (vec2(rand(uv), rand(uv.yx)) - 0.5) * distortion_strength;

    // Sample screen texture
    vec3 color = texture(SCREEN_TEXTURE, distortion).rgb;

    // Convert to grayscale
    float gray = dot(color, vec3(0.299, 0.587, 0.114));
    vec3 grayscale = vec3(gray);

    // Preserve bright regions
    float brightness = dot(color, vec3(0.2126, 0.7152, 0.0722));
    float glow = smoothstep(0.6, 1.0, brightness);
    vec3 preserved = mix(grayscale, color, glow * light_preserve_strength);

    // Fade out blue channel
    preserved.b *= blue_fade;

    // Mix grayscale and original
    vec3 final_color = mix(color, preserved, grayscale_strength);

    // Blur sampling
    float bs = 0.002 * blur_intensity;
    vec3 blur = vec3(0.0);
    blur += texture(SCREEN_TEXTURE, uv + vec2( bs,  bs)).rgb;
    blur += texture(SCREEN_TEXTURE, uv + vec2(-bs,  bs)).rgb;
    blur += texture(SCREEN_TEXTURE, uv + vec2( bs, -bs)).rgb;
    blur += texture(SCREEN_TEXTURE, uv + vec2(-bs, -bs)).rgb;
    blur /= 4.0;

    final_color = mix(final_color, blur, blur_intensity);

    // Vignette
    vec2 centered = uv * 2.0 - 1.0;
    float dist = length(centered);
    float vignette = smoothstep(0.5, 1.0, dist);
    final_color *= mix(1.0, 1.0 - vignette, vignette_strength);

    // Noise
    float noise = rand(uv * TIME) * 2.0 - 1.0;
    final_color += noise * noise_strength;

    COLOR = vec4(final_color, 1.0);
}
