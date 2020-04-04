#version 310 es

precision mediump float;

layout(location = 0) uniform float time;
layout(location = 1) uniform vec2 resolution;
layout(location = 2) uniform vec2 mouse;

layout(location = 0) out vec4 fragColor;

float rectshape(vec2 position, vec2 scale) {
  scale = vec2(0.5) - scale * 0.5;
  vec2 shaper = vec2(step(scale.x, position.x), step(scale.y, position.y));
  shaper *=
      vec2(step(scale.x, 1.0 - position.x), step(scale.y, 1.0 - position.y));
  return shaper.x * shaper.y;
}

void main() {
  vec2 position = gl_FragCoord.xy / resolution;
  vec3 color = vec3(0.0);

  float rectangle = rectshape(position, vec2(0.3));

  color = vec3(rectangle);

  fragColor = vec4(color, 1.0);
}