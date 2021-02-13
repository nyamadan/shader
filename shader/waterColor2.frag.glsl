#version 310 es

precision mediump float;

#extension GL_GOOGLE_include_directive : enable

#include "./lib/_uniforms.glsl"

layout(location = 0) out vec4 fragColor;

const int AMOUNT = 12;

void main() {
  vec2 coord = 20.0 * (gl_FragCoord.xy - resolution / 2.0) /
               min(resolution.x, resolution.y);

  float len;
  for (int i = 0; i < AMOUNT; i++) {
    len = length(vec2(coord.x, coord.y));
    coord.x = coord.x - cos(coord.y + sin(len)) + cos(time / 9.0);
    coord.y = coord.y + sin(coord.x + cos(len)) + sin(time / 12.0);
  }
  fragColor = vec4(cos(len * 2.0), cos(len * 3.0), cos(len * 1.0), 1.0);
}