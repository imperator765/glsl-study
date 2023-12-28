#version 300 es
precision highp float;
const float PI = 3.1415926;
out vec4 fragColor;
uniform vec2 u_resolution;

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

vec2 pol2xy(vec2 pol){
    return pol.y*vec2(cos(pol.x), sin(pol.x));
}

void main(){

    vec2 pos = gl_FragCoord.xy / u_resolution.xy;
    fragColor = vec4(1.0, pos, 1.0);
}