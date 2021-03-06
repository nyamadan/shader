#ifndef RAYMARCHING
#define RAYMARCHING

struct HitResult {
  int m;
  float d;
};

HitResult map(in vec3);

HitResult opU(HitResult r1, HitResult r2) { return (r1.d < r2.d) ? r1 : r2; }

// http://iquilezles.org/www/articles/normalsSDF/normalsSDF.htm
vec3 calcNormal(in vec3 pos) {
  vec2 e = vec2(1.0, -1.0) * 0.5773 * 0.0005;
  return normalize(e.xyy * map(pos + e.xyy).d + e.yyx * map(pos + e.yyx).d +
                   e.yxy * map(pos + e.yxy).d + e.xxx * map(pos + e.xxx).d);
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
  vec3 f = normalize(center - eye);
  vec3 s = normalize(cross(f, up));
  vec3 u = cross(s, f);

  mat4 m;
  m[0][0] = s.x;
  m[1][0] = s.y;
  m[2][0] = s.z;
  m[0][1] = u.x;
  m[1][1] = u.y;
  m[2][1] = u.z;
  m[0][2] = -f.x;
  m[1][2] = -f.y;
  m[2][2] = -f.z;
  m[3][0] = -dot(s, eye);
  m[3][1] = -dot(u, eye);
  m[3][2] = dot(f, eye);
  return m;
}

vec3 getRay(in vec2 p, in mat3 m, in float fov) {
  float f = 1.0 / tan(radians(0.5 * fov));
  return normalize(m * vec3(p.x, p.y, -f));
}

#endif