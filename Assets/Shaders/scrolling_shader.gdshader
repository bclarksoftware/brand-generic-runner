shader_type canvas_item;

uniform float speed = 0.1; // Adjust for scrolling speed
uniform float time_offset = 0.0;

void fragment() {
    vec2 uv_offset = UV + vec2(0.0, -(TIME + time_offset) * speed * 0.1); // Negative to reverse direction
    COLOR = texture(TEXTURE, fract(uv_offset));
}
