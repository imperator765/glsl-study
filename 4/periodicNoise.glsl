#version 300 es
precision highp int;
precision highp float;
uniform vec2 u_resolution;
uniform float u_time;
out vec4 fragColor;
int channel;
const float PI = 3.1415926;

uvec3 k=uvec3(0x456789abu, 0x6789ab45u, 0x89ab4567u);
uvec3 u=uvec3(1, 2, 3);
const uint UINT_MAX=0xffffffffu;

float atan2(float y, float x){
    if(x==0.0){
        return sign(y)*PI/2.0;
    }else{
        return atan(y, x);
    }
}

vec2 xy2pol(vec2 xy){
    return vec2(atan2(xy.y, xy.x), length(xy));
}

uvec2 uhash22(uvec2 n){
    n^=(n.yx << u.xy);
    n^=(n.yx >> u.xy);
    n*=k.xy;
    n^=(n.yx<<u.xy);
    return n*k.xy;
}

uvec3 uhash33(uvec3 n){
    n^=(n.yzx << u);
    n^=(n.yzx >> u);
    n*=k;
    n^=(n.yzx<<u);
    return n*k;
}

float gtable2(vec2 lattice, vec2 p){
    uvec2 n=floatBitsToUint(lattice);
    uint ind=uhash22(n).x>>28;
    float u=0.92387953*(ind<4u?p.x:p.y);
    float v=0.38268343*(ind<4u?p.y:p.x);
    return ((ind&1u)==0u?u:-u)+((ind&2u)==0u?v:-v);
}

float gtable3(vec3 lattice, vec3 p){
    uvec3 n=floatBitsToUint(lattice);
    uint ind=uhash33(n).x>>28;
    float u=ind<8u?p.x:p.y;
    float v=ind<4u?p.y:ind==12u||ind==14u?p.x:p.z;
    return ((ind&1u)==0u?u:-u+((ind&2u)==0u?v:-v));
}

float periodicNoise21(vec2 p, float period){
    vec2 n=floor(p);
    vec2 f=fract(p);
    float[4] v;
    for(int i=0; i<2; i++){
        for(int j=0; j<2; j++){
            v[i+2*j]=gtable2(mod(n+vec2(i, j), period), f-vec2(i, j));
        }
    }
    f=f*f*f*(10.0-15.0*f+6.0*f*f);
    return 0.5*mix(mix(v[0], v[1], f[0]), mix(v[2], v[3], f[0]), f[1])+0.5;
}

float periodicNoise31(vec3 p, float period){
    vec3 n=floor(p);
    vec3 f=fract(p);
    float[8] v;
    for(int i=0; i<2; i++){
        for(int j=0; j<2; j++){
            for(int k=0; k<2; k++){
                v[i+2*j+4*k]=gtable3(mod(n+vec3(i, j, k), period), f-vec3(i, j, k));
            }
        }
    }

    f=f*f*f*(10.0-15.0*f+6.0*f*f);
    float[2] w;
    for(int i=0; i<2; i++){
        w[i]=mix(mix(v[4*i], v[4*i+1], f[0]), mix(v[4*i+2], v[4*i+3], f[0]), f[1]);
    }

    return 0.5*mix(w[0], w[1], f[2])+0.5;
}

void main(){
    vec2 pos=gl_FragCoord.xy/u_resolution.xy;
    channel=int(gl_FragCoord.x*2.0/u_resolution.x);
    pos=2.0*pos-vec2(1.0);
    pos=xy2pol(pos);
    pos=vec2(5.0/PI,5.0)*pos + u_time;
    fragColor.xyz=vec3(periodicNoise31(vec3(pos, u_time), 10.0));
    fragColor.a=1.0;
}