#version 310 es

precision mediump float;

layout(location = 0) uniform float time;
layout(location = 1) uniform vec2 resolution;
layout(location = 2) uniform vec2 mouse;

layout(location = 0) out vec4 fragColor;

float circleshape(vec2 position, float radius) {
  return step(radius, length(position - vec2(0.5)));
}

void main() {
  vec2 coord = gl_FragCoord.xy / resolution;
  vec3 color = vec3(0.0);

  float circle = circleshape(coord, 0.3);

  color = vec3(circle);

  fragColor = vec4(color, 1.0);
}
