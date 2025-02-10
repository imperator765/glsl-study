#version 300 es
precision highp float;
uniform vec2 u_resolution;
uniform float u_time;
out vec4 fragColor;
const float TAU = 6.2831853;

#define rot(a) mat2(cos(a),sin(a),-sin(a),cos(a))

vec2 pmod(vec2 p, float n)
{
  float a=mod(atan(p.y, p.x),TAU/n)-.5 *TAU/n;
  return length(p)*vec2(sin(a),cos(a));
}

float map(vec3 p)
{
    p.z-=-u_time*2.;
    p.z=mod(p.z,2.)-1.0;
    for(int i=0;i<8;i++)
    {
        p.xy=pmod(p.xy,8.);
        p.y-=2.;
    }
    p.yz = pmod(p.yz, 8.);    
    return dot(abs(p),normalize(vec3(7,3,6)))-.7;
}

void main(){
    vec2 uv=(gl_FragCoord.xy-.5*u_resolution)/u_resolution.y;
    vec3 rd=normalize(vec3(uv,1));
    vec3 p=vec3(0,0,-3);
    float d=1.,i;
    for(;++i<99.&&d>.001;)p+=rd*(d=map(p));
    if(d<.001)fragColor+=3./i;
}