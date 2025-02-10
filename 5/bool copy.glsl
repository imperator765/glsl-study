#version 300 es
precision highp int;
precision highp float;
uniform vec2 u_resolution;
uniform float u_time;
out vec4 fragColor;
const float PI = 3.1415926;
const float TAU = 6.2831853;

uvec3 k=uvec3(0x456789abu, 0x6789ab45u, 0x89ab4567u);
uvec3 u=uvec3(1, 2, 3);
const uint UINT_MAX=0xffffffffu;

uvec2 uhash22(uvec2 n){
    n^=(n.yx << u.xy);
    n^=(n.yx >> u.xy);
    n*=k.xy;
    n^=(n.yx << u.xy);
    return n * k.xy;
}

uvec3 uhash33(uvec3 n){
    n ^= (n.yzx << u);
    n ^= (n.yzx >> u);
    n *= k;
    n ^= (n.yzx<<u);
    return n * k;
}

vec2 hash22(vec2 p){
    uvec2 n = floatBitsToUint(p);
    return vec2(uhash22(n)) / vec2(UINT_MAX);
}

vec3 hash33(vec3 p){
    uvec3 n = floatBitsToUint(p);
    return vec3(uhash33(n)) / vec3(UINT_MAX);
}

float hash21(vec2 p){
    uvec2 n = floatBitsToUint(p);
    return float(uhash22(n).x) / float(UINT_MAX);
}

float hash31(vec3 p){
    uvec3 n = floatBitsToUint(p);
    return float(uhash33(n).x) / float(UINT_MAX);
}


float gtable2(vec2 lattice, vec2 p){
    uvec2 n = floatBitsToUint(lattice);
    uint ind = uhash22(n).x >> 28;
    float u = 0.92387953 * (ind < 4u ? p.x : p.y);
    float v = 0.38268343 * (ind < 4u ? p.y : p.x);
    return ((ind&1u) == 0u ? u : -u) + ((ind&2u) == 0u ? v : -v);
}

float pnoise21(vec2 p){
    vec2 n = floor(p);
    vec2 f = fract(p);
    float[4] v;
    for(int i = 0; i < 2; i++){
        for(int j = 0; j < 2; j++){
            v[i + 2 * j] = gtable2(n + vec2(i, j), f - vec2(i, j));
        }
    }
    f = f * f * f * (10.0-15.0 * f+6.0 * f * f);
    return 0.5 * mix(mix(v[0], v[1], f[0]), mix(v[2], v[3], f[0]), f[1])+0.5;
}

float fbm21(vec2 p, float g){
    float val = 0.0;
    float amp = 1.0;
    float freq = 1.0;
    for(int i = 0; i < 4; i++){
        val += amp * (pnoise21(freq * p) - 0.5);
        amp *= g;
        freq *= 2.01;
    }
    return 0.5 * val + 0.5;
}

float warp21(vec2 p, float g){
    float val = 0.0;
    for(int i = 0; i < 4; i++){
        val = fbm21(p + g * vec2(cos(TAU * val), sin(TAU * val)), 0.5);
    }
    return val;
}

void main() {
    vec2 pos = gl_FragCoord.xy / min(u_resolution.x, u_resolution.y);
    pos = 10.0 * pos + u_time;
    vec3 f = vec3(warp21(pos, 1.0), warp21(pos + 10.0, 0.7), warp21(pos + 20.0, 0.7));
    f = step(f - 0.5, vec3(0.0));

    vec4 color;

    if (f == vec3(1, 1, 1)) color = vec4(123, 144, 140, 255);
    else if (f == vec3(1, 1, 0)) color = vec4(48, 66, 65, 255);
    else if (f == vec3(1, 0, 1)) color = vec4(235, 183, 128, 255);
    else if (f == vec3(1, 0, 0)) color = vec4(215, 144, 140, 255);
    else if (f == vec3(0, 1, 1)) color = vec4(140, 43, 42, 255);
    else if (f == vec3(0, 1, 0)) color = vec4(123, 144, 140, 120);
    else if (f == vec3(0, 0, 1)) color = vec4(215, 144, 140, 120);
    else if (f == vec3(0, 0, 0)) color = vec4(140, 43, 42, 120);

    color /= vec4(255);
    fragColor = color;
}