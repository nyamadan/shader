#ifdef GL_ES
precision mediump float;
#endif

// clang-format off
#pragma glslify: noise = require('glsl-noise/simplex/2d')
// clang-format on

uniform vec2 resolution;

void main() {
  vec2 position = 2.0 * ((gl_FragCoord.xy / resolution.xy) - 0.5) *
                  vec2(resolution.x / resolution.y, 1.0);
  vec3 color = vec3(noise(position * 25.0));
  gl_FragColor = vec4(color, 1);
}
