#ifdef GL_ES
precision highp float;
#endif

uniform float time;
uniform vec2 mouse;
uniform vec2 resolution;

// clang-format off
#pragma glslify: PI = require(glsl-pi)
#pragma glslify: rotateX = require(glsl-y-rotate/rotateX)
#pragma glslify: rotateY = require(glsl-y-rotate/rotateY)
#pragma glslify: rotateZ = require(glsl-y-rotate/rotateZ)
#pragma glslify: import('../lib/sdf.glsl')
// clang-format on

const int MaxSteps = 200;
const int ShadowSteps = 100;

struct HitResult {
  bool hit;
  int mat;
  vec3 nor;
  vec3 pos;
  int steps;
};

// https://www.iquilezles.org/www/articles/menger/menger.htm
float sdMenger(in vec3 p) {
  const int Iterations = 3;
  float d = sdBox(p, vec3(1.0));
  float s = 1.0;
  for (int i = 0; i < Iterations; i++) {
    vec3 a = mod(p * s, 2.0) - 1.0;
    s *= 3.0;
    vec3 r = abs(1.0 - 3.0 * abs(a));

    float da = max(r.x, r.y);
    float db = max(r.y, r.z);
    float dc = max(r.z, r.x);
    float c = (min(da, min(db, dc)) - 1.0) / s;

    d = max(d, c);
  }

  float displacement = sin(20.0 * p.x) * sin(20.0 * p.y) * sin(20.0 * p.z);

  return d + 0.08 * displacement;
}

HitInfo map(in vec3 p) {
  HitInfo plane;
  plane.mat = 1;
  plane.d = sdPlane(p, vec4(0.0, 1.0, 0.0, 0.0));

  vec3 q = (0.75 * p - vec3(0.0, 1.5, 0.0));

  HitInfo menger;
  menger.mat = 1;
  menger.d = sdMenger(q);

  HitInfo result = opU(plane, menger);

  return result;
}

float detailedAO(vec3 hitPos, vec3 hitNormal, float k) {
  float ao = 0.0;
  for (int i = 1; i <= 5; i++) {
    float d1 = k * float(i) / float(5);
    vec3 p = hitPos + d1 * hitNormal;

    ao += 1.0 / pow(2.0, float(i)) * abs(d1 - map(p).d);
  }

  return 1.0 - clamp(ao, 0.0, 1.0);
}

vec3 computeNormal(vec3 p) {
  const float eps = 0.00001;

  return normalize(
      vec3(map(p + vec3(eps, 0, 0)).d - map(p + vec3(-eps, 0, 0)).d,
           map(p + vec3(0, eps, 0)).d - map(p + vec3(0, -eps, 0)).d,
           map(p + vec3(0, 0, eps)).d - map(p + vec3(0, 0, -eps)).d));
}

HitResult trace(vec3 ro, vec3 rd) {
  const float eps = 0.00001;
  HitResult result;

  float t = 0.0;
  for (int i = 0; i < MaxSteps; i++) {
    vec3 p = ro + t * rd;

    HitInfo hitInfo = map(p);
    if (hitInfo.d < eps) {
      result.hit = true;
      result.mat = hitInfo.mat;
      result.pos = p;
      result.nor = computeNormal(p);
      result.steps = i;
      return result;
    }

    t += hitInfo.d;
  }

  result.hit = false;
  return result;
}

mat3 lookAt(vec3 eye, vec3 up, vec3 target, float aspect, float fov) {
  vec3 z = normalize(target - eye);
  vec3 x = normalize(cross(normalize(up), z));
  vec3 y = normalize(cross(z, x));
  return mat3(x * aspect, y, z / tan(radians(fov * 0.5)));
}

float softShadow(vec3 hitPos, vec3 lightPos, float k) {
  const float eps = 0.00001;
  vec3 rayDir = normalize(lightPos - hitPos);
  float t = 0.1;
  float ss = 100.0;

  for (int i = 0; i < ShadowSteps; i++) {
    vec3 p = hitPos + t * rayDir;
    float d = map(p).d;
    ss = min(ss, k * d / t);
    if (d < eps) {
      break;
    }

    t += d;
  }

  ss = clamp(ss, 0.0, 1.0);

  return ss;
}

void main(void) {
  vec3 p = vec3(2.0 * gl_FragCoord.xy / resolution.xy - 1.0, 1.0);
  float aspect = resolution.x / resolution.y;

  vec3 eye = vec3(10.0 * (mouse.x - 0.5), 5.0, 4.0);
  vec3 up = vec3(0.0, 1.0, 0.0);
  vec3 target = vec3(0.0, 0.0, 0.0);
  float fov = 90.0;
  mat3 camera = lookAt(eye, up, target, aspect, fov);

  vec3 ro = eye;
  vec3 rd = normalize(camera * p);

  HitResult hr = trace(ro, rd);

  vec3 color = vec3(0.0, 0.0, 0.0);
  if (hr.hit) {
    vec3 lightPos = vec3(10.0, 10.0, -10.0);

    vec3 lightDir = normalize(lightPos - hr.pos);
    float diffuse = max(dot(hr.nor, lightDir), 0.0);
    float specular = pow(max(dot(-rd, reflect(-lightDir, hr.nor)), 0.0), 8.0);

    float ss = softShadow(hr.pos, lightPos, 2.0);
    float stepAO = 1.0 - float(hr.steps) / float(MaxSteps);
    float dAO = detailedAO(hr.pos, hr.nor, 2.0);
    color = dAO * vec3(1.0);
    // color = stepAO * vec3(1.0);
    // color = ss * dAO * vec3(1.0);
    // color = 0.5 * diffuse * vec3(1.0) + 0.5 + 0.5 * specular * vec3(1.0);
  } else {
    color = p;
  }

  gl_FragColor = vec4(color, 1.0);
}
