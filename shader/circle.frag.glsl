#ifdef GL_ES
precision mediump float;
#endif

#ifndef GLSLIFY
#define GLSLIFY 1
#endif

uniform vec2 resolution;

float circle(in vec2 _st, in float _radius) {
  vec2 dist = _st - vec2(0.0);
  return 1.0 - smoothstep(_radius - (_radius * 0.01),
                          _radius + (_radius * 0.01), dot(dist, dist) * 4.0);
}

void main() {
  vec2 st = (gl_FragCoord.xy / resolution - vec2(0.5)) *
            vec2(resolution.x / resolution.y, 1.0);
  vec3 color = vec3(circle(st, 0.9));
  gl_FragColor = vec4(color, 1.0);
}