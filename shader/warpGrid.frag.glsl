#version 310 es

precision mediump float;

#extension GL_GOOGLE_include_directive : enable

#include "./lib/uniforms.glsl"

layout(location = 0) out vec4 fragColor;

void main() {
  vec2 coord = gl_FragCoord.xy / Resolution;
  vec3 color = vec3(0.0);

  color += sin(coord.x * cos(Time / 60.0) * 60.0) +
           sin(coord.y * cos(Time / 15.0) * 10.0);

  color += cos(coord.y * sin(Time / 30.0) * 10.0) +
           cos(coord.x * sin(Time / 20.0) * 10.0);

  color += sin(Time / 10.0) * 0.5;

  fragColor = vec4(color, 1.0);
}
