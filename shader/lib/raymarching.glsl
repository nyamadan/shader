#ifndef RAYMARCHING
#define RAYMARCHING

struct HitResult {
  int m;
  float d;
};

HitResult map(in vec3 pos);

HitResult opU(HitResult r1, HitResult r2) { return (r1.d < r2.d) ? r1 : r2; }

// http://iquilezles.org/www/articles/normalsSDF/normalsSDF.htm
vec3 calcNormal(in vec3 pos) {
  // inspired by tdhooper and klems - a way to prevent the compiler from
  // inlining map() 4 times
  vec3 n = vec3(0.0);
  for (int i = 0; i < 4; i++) {
    vec3 e = 0.5773 *
             (2.0 * vec3((((i + 3) >> 1) & 1), ((i >> 1) & 1), (i & 1)) - 1.0);
    n += e * map(pos + 0.0005 * e).d;
  }
  return normalize(n);
}

// http://iquilezles.org/www/articles/rmshadows/rmshadows.htm
float calcSoftshadow(in vec3 ro, in vec3 rd, in float mint, in float tmax) {
  const float maxHeight = 0.8;

  // bounding volume
  float tp = (maxHeight - ro.y) / rd.y;
  if (tp > 0.0)
    tmax = min(tmax, tp);

  float res = 1.0;
  float t = mint;
  for (int i = 0; i < 16; i++) {
    float h = map(ro + rd * t).d;
    float s = clamp(8.0 * h / t, 0.0, 1.0);
    res = min(res, s * s * (3.0 - 2.0 * s));
    t += clamp(h, 0.02, 0.10);
    if (res < 0.005 || t > tmax)
      break;
  }
  return clamp(res, 0.0, 1.0);
}

mat4 lookAt(in vec3 eye, in vec3 center, in vec3 up) {
  vec3 z = normalize(eye - center);
  vec3 x = normalize(cross(z, normalize(up)));
  vec3 y = normalize(cross(x, z));

  return mat4(vec4(x, 0.0), vec4(y, 0.0), vec4(-z, 0.0), vec4(-eye, 1.0));
}

vec3 getRay(in vec2 p, in mat3 mView, in float fov) {
  float f = 1.0 / tan(radians(0.5 * fov));
  return normalize(mView * vec3(-p.x, p.y, f));
}

#endif