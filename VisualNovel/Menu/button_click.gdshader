shader_type canvas_item;

uniform vec2 circle_center = vec2(0.);
uniform float time : hint_range(0.,1.) = 1.;
uniform vec2 size = vec2(64.);
uniform vec4 color :source_color = vec4(1.);
uniform vec2 margin = vec2(0.);

void fragment() {
	vec2 center = vec2(.5);
	vec2 coords = (UV - center) / vec2((size.x-margin.x*2.)/size.x,(size.y-margin.y*2.)/size.y) + center;
	vec4 edges = vec4(.0);
	if (abs(coords.x - center.x) <= .5 && abs(coords.y - center.y) <= .5) {
		edges.a = 1.0;
	}
	vec2 uv = (UV - circle_center);
	float ratio = size.x/size.y;
    uv.x *= ratio;
	float d = length(uv);
	float circle = smoothstep(d-.01,d,.25+(ratio-.25)*time-.01);
	COLOR = vec4(color.rgb,max(circle-max(time,.25),.0))*edges.a;
}