#version 310 es

precision mediump float;

#extension GL_GOOGLE_include_directive : enable

#include "./lib/uniforms.glsl"

layout(location=0) out vec4 fragColor;

void main(){
  vec2 coord = gl_FragCoord.xy / min(Resolution.x, Resolution.y);
  float color = 0.0;

  color += sin(coord.x * 6.0 * sin(Time + coord.y * 90.0 + cos(coord.x * 30.0 + Time * 2.0))) * 0.5;

  fragColor = vec4(color + coord.x, color + coord.x, color, 1.0);
}