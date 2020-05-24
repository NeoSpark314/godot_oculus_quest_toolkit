shader_type spatial;
//render_mode unshaded;

uniform vec4 color = vec4(1.0, 0.0, 0.0, 1.0);

void fragment() {
	float v = smoothstep(1.0 - dot(NORMAL, VIEW), 0.0, 0.15);
	
	ALBEDO = vec3(0.0);
	EMISSION = color.rgb * v * 2.0;
}

