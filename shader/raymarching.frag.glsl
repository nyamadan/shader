#version 310 es

precision highp float;

#extension GL_GOOGLE_include_directive : enable

layout(location = 0) uniform vec2 resolution;
layout(location = 1) uniform float time;

layout(location = 2) uniform mat4 mat_mv;
layout(location = 3) uniform mat4 mat_mv_t;
layout(location = 4) uniform mat4 mat_mv_it;

layout(location = 0) out vec4 fragColor;

#include "./lib/_distance_functions.glsl"
#include "./lib/_raymarching.glsl"

// materials
const int MATERIAL_EMPTY = 0;
const int MATERIAL_SPHERE = 1;

HitResult map(in vec3 pos) {
  HitResult res = HitResult(MATERIAL_EMPTY, 1e+10);
  res = opU(res, HitResult(MATERIAL_SPHERE, sdBox(pos, vec3(0.5))));

  /*
  res = opU(res, HitResult(MATERIAL_SPHERE,
                           sdSphere(pos - vec3(0.0, 1.0, 0.0), 0.5)));
  res = opU(
      res, HitResult(MATERIAL_SPHERE, sdPlane(pos - vec3(0.0, -1.0, 0.0),
                                              vec4(vec3(0.0, 1.0, 0.0), 0.0))));
  */
  return res;
}

void main() {
  const int MAX_STEP = 100;
  const float EPS = 1e-6;
  const float FOV = 30.0;

  vec2 p =
      (2.0 * gl_FragCoord.xy - resolution.xy) / min(resolution.x, resolution.y);

  vec3 ro = transpose(mat_mv_it)[3].xyz;
  vec3 rd = getRay(p, mat3(mat_mv_t), FOV);
  vec3 color = vec3(0.0);

  float depth = 0.0;
  for (int i = 1; i <= MAX_STEP; i++) {
    vec3 pos = depth * rd + ro;

    HitResult res = map(pos);

    if (res.d >= EPS) {
      depth += res.d;
      continue;;
    }

    if (res.m == MATERIAL_SPHERE) {
      vec3 nor = calcNormal(pos);
      vec3 lightDir = normalize(vec3(1.0, 2.0, 3.0));
      float diff = max(dot(lightDir, nor), 0.0);
      color = vec3(0.5 * diff * diff + 0.5);
      break;
    }
  }

  fragColor = vec4(color, 1.0);
}
