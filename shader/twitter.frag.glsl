#version 310 es

precision mediump float;

#extension GL_GOOGLE_include_directive : enable

#include "./lib/uniforms.glsl"

layout(location = 0) out vec4 fragColor;

const float PI = 3.1415926535;

void main() {
  vec2 coord = gl_FragCoord.xy / Resolution;

  float color = 0.0;

  for (int i = 1; i <= 3; i++) {
    float f = float(i);
    color -= 0.1 *
             (0.5 * sin(20.0 * coord.y + 0.2 * cos(coord.x * 40.0) + f + Time) +
              0.5) /
             f;
    color += 0.2 *
             (0.5 * cos(1.0 * coord.x + 0.4 * sin(coord.y * 10.0) + f + Time) +
              0.5) /
             f;
    color += 0.1 *
             (0.5 * sin(5.0 * coord.x + 0.1 * cos(coord.y * 20.0) + f + Time) +
              0.5) /
             f;
  }

  fragColor = vec4(color * coord.x, color * coord.y, color, 1.0);
}