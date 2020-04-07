#version 310 es

precision mediump float;

#extension GL_GOOGLE_include_directive : enable

#include "./lib/uniforms.glsl"

layout(location = 0) out vec4 fragColor;

void main() {
  vec2 coord = gl_FragCoord.xy / Resolution;
  float color = 0.0;

  color += sin(coord.x * 50.0 + cos(Time + coord.y * 10.0) +
               sin(coord.x * 50.0 + Time * 2.0)) *
           2.0;
  color += cos(coord.x * 20.0 + sin(Time + coord.y * 10.0) +
               cos(coord.x * 50.0 + Time * 2.0)) *
           2.0;
  color += cos(coord.x * 30.0 + sin(Time + coord.y * 10.0) +
               cos(coord.x * 50.0 + Time * 2.0)) *
           2.0;
  color += sin(coord.x * 10.0 + cos(Time + coord.y * 10.0) +
               sin(coord.x * 50.0 + Time * 2.0)) *
           2.0;

  fragColor = vec4(vec3(color + coord.y, color + coord.x, color), 1.0);
}
