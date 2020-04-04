#version 310 es

precision mediump float;

const float PI = 3.14159265359;

layout(location = 0) uniform float time;
layout(location = 1) uniform vec2 resolution;
layout(location = 2) uniform vec2 mouse;

layout(location = 0) out vec4 fragColor;

float polygonshape(vec2 position, float radius, float sides) {
  position = position * 2.0 - 1.0;
  float angle = atan(position.x, position.y);
  float slice = PI * 2.0 / sides;
  return step(radius, cos(floor(0.5 + angle / slice) * slice - angle) *
                          length(position));
}

void main() {
  vec2 coord = gl_FragCoord.xy;
  vec2 position = coord / resolution.xy;
  vec3 color = vec3(0.0);

  float polygon = polygonshape(position, 0.6, 6.0);

  color = vec3(polygon);

  fragColor = vec4(color, 1.0);
}