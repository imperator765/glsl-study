#version 300 es
precision highp float;

uniform vec2 u_resolution;
uniform float u_time;
out vec4 fragColor;

float TAU=6.28318530718;
int MAX_STEPS=100;
float EPSILON=0.001;
float ZOOM_SPEED=2.0;
float TUNNEL_LENGTH=4.0;
int ITERATIONS=8;

// 回転行列を生成する関数
mat2 rot(float a) {
    return mat2(cos(a), sin(a), -sin(a), cos(a));
}

// 周期的なパターンを生成する関数
vec2 pmod(vec2 p, float n) {
    float a = mod(atan(p.y, p.x), TAU / n) - TAU / (2.0 * n);
    return length(p) * vec2(cos(a), sin(a));
}

// SDF関数
float map(vec3 p) {
    p.z -= u_time * ZOOM_SPEED;
    p.z = mod(p.z, TUNNEL_LENGTH) - TUNNEL_LENGTH / 2.0;

    for (int i = 0; i < ITERATIONS; i++) {
        p.xy = pmod(p.xy, 8.0);
        p.y -= 2.0;
    }

    return dot(abs(p), normalize(vec3(1.0, 0.0, 1.0))) - 0.2;
}

void main() {
    vec2 uv = (gl_FragCoord.xy - 0.5 * u_resolution) / u_resolution.y;
    vec3 rd = normalize(vec3(uv, 1.0));
    vec3 ro = vec3(0.0, 0.0, -70.0);
    float d = 1.0, ix = 0.0;
    bool hit = false;

    for (int i = 0; i < MAX_STEPS; i++) {
        d = map(ro + rd * ix);
        if (d < EPSILON) {
            hit = true;
            break;
        }
        ix += d;
    }

    if (hit) {
        fragColor = vec4(5.0 / ix) + normalize(vec4(100.0, 35.0, 0.0, 0.0)) * 10.0 / ix;
    } else {
        // デバッグ用：ヒットしない場合は赤色で表示
        fragColor = vec4(1.0, 0.0, 0.0, 1.0);
    }
}
