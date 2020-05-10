#version 310 es

precision mediump float;

#extension GL_GOOGLE_include_directive : enable

#include "./lib/uniforms.glsl"

layout(location = 0) out vec4 fragColor;

void main() {
  vec2 coord = 20.0 * gl_FragCoord.xy / resolution;

  for (int n = 1; n < 8; n++) {
    float i = float(n);
    coord += vec2(0.7 / i * sin(i * coord.y + time + 0.3 * i) + 0.8,
                  0.4 / i * sin(coord.x + time + 0.3 * i) + 1.6);
  }

  coord *= vec2(0.7 / sin(coord.y + time + 0.3) + 0.8,
                0.4 / sin(coord.x + time + 0.3) + 1.6);

  vec3 color = vec3(0.5 * sin(coord.x) + 0.5, 0.5 * sin(coord.y) + 0.5,
                    sin(coord.x + coord.y));

  fragColor = vec4(color, 1.0);
}
