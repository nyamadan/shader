#ifndef __UNIFORMS__
#define __UNIFORMS__
#if defined(GLSL_SANDBOX)
#define Time time
#define Resolution resolution
#define Mouse mouse
#elif defined(SHADER_TOY)
#define Time time
#define Resolution resolution
#define Mouse mouse
#else
#define Time u_time
#define Resolution u_resolution
#define Mouse u_mouse
#endif
layout(location = 0) uniform float Time;
layout(location = 1) uniform vec2 Resolution;
layout(location = 2) uniform vec2 Mouse;
#endif
