#version 310 es

precision mediump float;

#extension GL_GOOGLE_include_directive : enable

#include "./lib/uniforms.glsl"

layout(location = 0) out vec4 fragColor;

mat2 rotate(float angle) {
  return mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
}

float rectshape(vec2 position, vec2 scale) {
  scale = vec2(0.5) - scale * 0.5;
  vec2 shaper = vec2(step(scale.x, position.x), step(scale.y, position.y));
  shaper *=
      vec2(step(scale.x, 1.0 - position.x), step(scale.y, 1.0 - position.y));
  return shaper.x * shaper.y;
}

void main() {
  vec2 coord = gl_FragCoord.xy / Resolution;
  vec3 color = vec3(0.0);

  coord -= vec2(0.5);
  coord = rotate(0.3) * coord;
  coord += vec2(0.5);

  color += vec3(rectshape(coord, vec2(0.3, 0.3)));

  fragColor = vec4(color, 1.0);
}