#version 310 es

precision mediump float;

#extension GL_GOOGLE_include_directive : enable

#include "./lib/uniforms.glsl"
#include "./lib/hsb.glsl"

layout(location = 0) out vec4 fragColor;

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