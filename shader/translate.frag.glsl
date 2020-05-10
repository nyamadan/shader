#version 310 es

precision mediump float;

#extension GL_GOOGLE_include_directive : enable

#include "./lib/uniforms.glsl"

layout(location = 0) out vec4 fragColor;

float circleshape(vec2 position, float radius) {
  return step(radius, length(position - vec2(0.5)));
}

void main() {
  vec2 coord = gl_FragCoord.xy / resolution.xy;
  vec3 color = vec3(0.0);

  vec2 translate = vec2(sin(time / 10.0), cos(time));

  coord -= translate * 0.5;

  color = vec3(circleshape(coord, 0.3));

  fragColor = vec4(color, 1.0);
}