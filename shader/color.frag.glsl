#version 310 es

#extension GL_GOOGLE_include_directive : enable

#if GL_ES
precision mediump float;
#endif

#define TWO_PI 6.28318530718

layout(location=0) uniform vec2 resolution;
layout(location=1) uniform float time;

layout(location=0) out vec4 fragColor;

#include "./lib/hsb.glsl"

void main() {
  vec2 st = gl_FragCoord.xy / resolution.xy;
  vec3 color = vec3(0.0);

  vec2 toCenter = (vec2(0.5) - st);
  float angle = atan(toCenter.y, toCenter.x) + time;
  float radius = length(toCenter) * 2.0;

  color = hsb2rgb(vec3(
    0.5 * cos(1.0 * angle) + 0.5,
    radius,
    1.0));

  fragColor = vec4(color, 1.0);
}