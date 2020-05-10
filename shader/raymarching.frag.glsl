#version 310 es

precision highp float;

#extension GL_GOOGLE_include_directive : enable

#include "./lib/hsb.glsl"
#include "./lib/uniforms.glsl"

layout(location = 0) out vec4 fragColor;

mat3 getCameraMatrix(in vec3 dir, in vec3 up) {
  vec3 z = normalize(dir);
  vec3 x = normalize(cross(up, dir));
  vec3 y = normalize(cross(dir, x));
  return mat3(x, y, z);
}

void main() {
  vec2 p =
      (2.0 * gl_FragCoord.xy - resolution.xy) / min(resolution.x, resolution.y);

  mat3 camera = getCameraMatrix(vec3(0.0, 0.0, -1.0), vec3(0.0, 1.0, 0.0));

  float fov = 60.0;
  vec3 ro = vec3(0.0, 0.0, 1.0);
  vec3 rd = normalize(camera * vec3(p.x, p.y, 1.0 / tan(0.5 * radians((fov)))));

  fragColor = vec4(vec3(rd.x), 1.0);
}
