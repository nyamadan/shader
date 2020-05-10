#version 310 es

precision highp float;

#extension GL_GOOGLE_include_directive : enable

#include "./lib/uniforms.glsl"
#include "./lib/hsb.glsl"
#include "./lib/raymarching.glsl"
#include "./lib/distance_functions.glsl"

// materials
const int MATERIAL_EMPTY = 0;
const int MATERIAL_SPHERE = 1;

layout(location = 0) out vec4 fragColor;

HitResult map(in vec3 pos) {
  HitResult res = HitResult(MATERIAL_EMPTY, 1e+10);
  res = opU(res, HitResult(MATERIAL_SPHERE, sdSphere(pos - vec3(0.0, 1.0, 0.0), 0.5)));
  res = opU(res, HitResult(MATERIAL_SPHERE, sdBox(pos, vec3(0.5))));
  res = opU(res, HitResult(MATERIAL_SPHERE, sdPlane(pos - vec3(0.0, -1.0, 0.0), vec4(vec3(0.0, 1.0, 0.0), 0.0))));
  return res;
}

void main() {
  const int MAX_STEP = 512;
  const float EPS = 1e-6;
  float fov = 30.0;

  vec2 p =
      (2.0 * gl_FragCoord.xy - resolution.xy) / min(resolution.x, resolution.y);

  vec3 center = vec3(0.0, 0.0, 0.0);
  vec3 up = vec3(0.0, 1.0, 0.0);
  vec3 ro = vec3(0.0, 5.0, 5.0);
  vec3 rd = getRay(p, mat3(lookAt(ro, center, up)), fov);
  vec3 color = vec3(0.0);

  float depth = 0.0;
  for (int i = 1; i <= MAX_STEP; i++) {
    vec3 rayPos = depth * rd + ro;

    HitResult res = map(rayPos);

    if (res.d < EPS) {
      switch (res.m) {
      case MATERIAL_SPHERE:
        vec3 nor = calcNormal(rayPos);
        vec3 lightDir = normalize(vec3(1.0, 2.0, 3.0));
        float diff = max(dot(lightDir, nor), 0.0);
        color = vec3(0.5 * diff * diff + 0.5);
        break;
      }

      break;
    }

    depth += res.d;
  }

  fragColor = vec4(color, 1.0);
}
