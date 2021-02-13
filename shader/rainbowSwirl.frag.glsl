#version 310 es

precision mediump float;

#extension GL_GOOGLE_include_directive : enable

#include "./lib/_uniforms.glsl"

layout(location=0) out vec4 fragColor;

void main(){
  vec2 coord = gl_FragCoord.xy / resolution;
  vec3 color = vec3(0.0);
  float angle = atan(-coord.y + 0.25, coord.x - 0.5) * 0.1;
  float len = length(coord - vec2(0.5, 0.25));
  color.r += sin(len * 40.0 + angle * 40.0 + time);
  color.g += cos(len * 30.0 + angle * 40.0 - time);
  color.b += sin(len * 50.0 + angle * 40.0 + 3.0);
  fragColor = vec4(color, 1.0);
}