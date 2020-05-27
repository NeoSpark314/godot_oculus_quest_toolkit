shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D stereo_image;

const float M_PI = 3.1415926535897932384626433832795;

void fragment() {
	vec2 uv_interp = FRAGCOORD.xy / VIEWPORT_SIZE * 2.0 - vec2(1.0);
	vec4 asym_proj = vec4(PROJECTION_MATRIX[2][0], PROJECTION_MATRIX[0][0], PROJECTION_MATRIX[2][1], PROJECTION_MATRIX[1][1]);
	
	vec3 dir = vec3(0.0, 0.0, 1.0);
	dir.x = ((-uv_interp.x - asym_proj.x)) / asym_proj.y;
	dir.y = ((-uv_interp.y - asym_proj.z)) / asym_proj.a;
	
	dir = mat3(CAMERA_MATRIX) * normalize(-dir);
	
	float x = (atan(dir.z, dir.x) + M_PI)  / (2.0 * M_PI);
	float y = (acos(dir.y)) / (M_PI); 
	
	y *= 0.5;
	
	vec2 uv = vec2(x, y);
	
	vec3 color = vec3(0.0, 0.0, 0.0);
	vec3 v = abs(dir);
	if (v.x > v.y && v.x > v.z) color = vec3(1.0, 0.0, 0.0);
	if (v.y > v.x && v.y > v.z) color = vec3(0.0, 1.0, 0.0);
	if (v.z > v.x && v.z > v.y) color = vec3(0.0, 0.0, 1.0);
	
	//vec3 color = dir;
	color = texture(stereo_image, uv).xyz;
	
	//color = vec3(x, 0.0, 0.0);
	
	
	ALBEDO = color; //vec3(uv_interp.x, uv_interp.y, 0.0);
	
}