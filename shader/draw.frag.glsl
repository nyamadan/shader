#ifdef GL_ES
precision mediump float;
#endif

uniform vec2 resolution;
uniform float time;

void main() {
  vec2 st = gl_FragCoord.xy / resolution.xy;
  vec3 color = vec3(0.0);

  vec2 bl = step(0.1, st);
  vec2 tr = step(0.1, 1.0 - st);

  color = vec3(bl.x * bl.y * tr.x * tr.y);

  gl_FragColor = vec4(color, 1.0);
}