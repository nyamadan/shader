#ifndef DISTANCE_FUNCTIONS
#define DISTANCE_FUNCTIONS
float sdSphere(in vec3 pos, in float radius) { return length(pos) - radius; }
float sdBox(vec3 p, vec3 b) {
  vec3 q = abs(p) - b;
  return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}
float sdPlane(vec3 p, vec4 n) {
  // n must be normalized
  return dot(p, n.xyz) + n.w;
}
#endif
