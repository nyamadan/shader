#version 310 es

precision mediump float;

#extension GL_GOOGLE_include_directive : enable

#include "./lib/uniforms.glsl"

float circle(vec2 position, float radius) {
  return step(radius, length(position - vec2(0.5)));
}

mat2 scale(vec2 scale) { return mat2(scale.x, 0.0, 0.0, scale.y); }

layout(location = 0) out vec4 fragColor;

void main() {
  vec2 coord = gl_FragCoord.xy / resolution;
  vec3 color = vec3(0.0);

  coord -= vec2(0.5);
  coord = scale(vec2(sin(time) + 2.0)) * coord;
  coord += vec2(0.5);

  color = vec3(circle(coord, 0.3));

  fragColor = vec4(color, 1.0);
}
