#version 300 es
precision highp int;
precision highp float;
uniform vec2 u_resolution;
uniform float u_time;
out vec4 fragColor;
const float TAU = 6.2831853;



vec2 pmod(vec2 p, float n)
{
  float a=mod(atan(p.y, p.x),TAU/n)-.5 *TAU/n;
  return length(p)*vec2(sin(a),cos(a));
}

float map(vec3 p)
{
    p.z-=u_time*2.;
    p.z=mod(p.z,2.)-1.0;
    for(int i=0;i<8;i++)
    {
        p.xy=pmod(p.xy,8.);
        p.y-=2.;
    }
    p.yz = pmod(p.yz, 8.);    
    return dot(p,normalize(vec3(0,0,1))*0.8)-.7;
}

// レイマーチングのメイン関数
vec3 raymarch(vec3 ro, vec3 rd) {
    float depth = 0.0;
    for (float i = 0.; i < 100.; i++) {
        vec3 p = ro + depth * rd;
        float d = map(p);
            if (d < 0.001) {
        vec3 color = vec3(1.0, 1.0, 1.0);
        return color/i*16.; // ヒットした場合の色
    }
        
        depth += d;
        if (depth >= 100.0) break;
    }
    return vec3(1.0, 1.0, 0.0); // ヒットしなかった場合の背景色（オレンジ）
}

void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution.xy) / u_resolution.y;
    vec3 ro = vec3(0.0, 0.0,4.0); // カメラの位置
    vec3 rd = normalize(vec3(uv, -1)); // レイの方向

    vec3 color = raymarch(ro, rd);

    fragColor = vec4(color, 1.0);
}