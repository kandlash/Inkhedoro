shader_type spatial;
render_mode unshaded, fog_disabled;

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

void vertex() {
    POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
    vec2 uv = SCREEN_UV;

    // Slight screen distortion like old glass
    vec2 distortion = uv + (vec2(rand(uv), rand(uv.yx)) - 0.5) * distortion_strength;

    // Sample screen texture
    vec3 color = texture(SCREEN_TEXTURE, distortion).rgb;

    // Desaturate to grayscale
    float gray = dot(color, vec3(0.299, 0.587, 0.114));
    vec3 grayscale = vec3(gray);

    // Preserve bright areas (emission glow, lamps etc.)
    float brightness = dot(color, vec3(0.2126, 0.7152, 0.0722));
    float glow = smoothstep(0.6, 1.0, brightness);
    vec3 preserved = mix(grayscale, color, glow * light_preserve_strength);

    // Fade out blue (simulate deep water color loss)
    preserved.b *= blue_fade;

    // Apply grayscale
    vec3 final_color = mix(color, preserved, grayscale_strength);

    // Add slight blur (fake: sample surrounding pixels)
    vec3 blur = vec3(0.0);
    float blur_scale = 0.002 * blur_intensity;
    blur += texture(SCREEN_TEXTURE, uv + vec2( blur_scale,  blur_scale)).rgb;
    blur += texture(SCREEN_TEXTURE, uv + vec2(-blur_scale,  blur_scale)).rgb;
    blur += texture(SCREEN_TEXTURE, uv + vec2( blur_scale, -blur_scale)).rgb;
    blur += texture(SCREEN_TEXTURE, uv + vec2(-blur_scale, -blur_scale)).rgb;
    blur /= 4.0;
    final_color = mix(final_color, blur, blur_intensity);

    // Vignette (helmet lens effect)
    vec2 centered_uv = uv * 2.0 - 1.0;
    float dist = length(centered_uv);
    float vignette = smoothstep(0.5, 1.0, dist);
    final_color *= mix(1.0, 1.0 - vignette, vignette_strength);

    // Add grain/noise
    float noise = rand(uv * TIME) * 2.0 - 1.0;
    final_color += noise * noise_strength;

    ALBEDO = final_color;
}
