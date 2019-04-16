struct HitInfo {
  int mat;
  float d;
};

float maxcomp(vec2 a) {
  if (a.x > a.y) {
    return a.x;
  } else {
    return a.y;
  }
}

HitInfo opU(HitInfo a, HitInfo b) {
  if (a.d < b.d) {
    return a;
  } else {
    return b;
  }
}

HitInfo opI(HitInfo a, HitInfo b) {
  if (a.d > b.d) {
    return a;
  } else {
    return b;
  }
}

HitInfo opS(HitInfo a, HitInfo b) {
  b.d = -b.d;
  if (a.d > b.d) {
    return a;
  } else {
    return b;
  }
}

float sdPlane(vec3 p, vec4 n) { return dot(p, n.xyz) + n.w; }

float sdSphere(vec3 p, float r) { return length(p) - r; }

float sdBox(vec3 p, vec3 b) {
  vec3 d = abs(p) - b;
  return length(max(d, 0.0)) + min(max(d.x, max(d.y, d.z)), 0.0);
}