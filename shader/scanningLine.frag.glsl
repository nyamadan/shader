#version 310 es

precision mediump float;

#extension GL_GOOGLE_include_directive : enable

#include "./lib/_uniforms.glsl"

layout(location = 0) out vec4 fragColor;

void main() {
  vec2 coord = gl_FragCoord.xy / resolution;
  vec3 color = vec3(1.0);

  float size = 12.0;

  float alpha = sin(floor(coord.x * size) + time * 4.0);

  fragColor = vec4(color, alpha);
}