uniform vec2 resolution, mouse;
uniform float uIntercept, time, frequency, angle, speed, waveFactor, contrast, pixelStrength, quality, brightness, colorExposer, strength, exposer, uScroll, uSection;
uniform int onMouse, mousemove, mode, modeA, modeN;
uniform bool distortion, isMulti;
uniform vec3 color;
varying vec2 vuv;
uniform sampler2D uTexture[16];
float mina(vec4 a) {
    return min(min(a.r, a.g), a.b);
}
float maxa(vec4 a) {
    return max(max(a.r, a.g), a.b);
}
vec4 minn(vec4 a, vec4 b) {
    return vec4(min(a.r, b.r), min(a.g, b.g), min(a.b, b.b), 1.0);
}
vec4 maxx(vec4 a, vec4 b) {
    return vec4(max(a.r, b.r), max(a.g, b.g), max(a.b, b.b), 1.0);
}
mat2 rotate2D(float r) {
    return mat2(cos(r), sin(r), -sin(r), cos(r));
}

#define SNOISEHOLDER

vec4 img(vec2 uv, float c) {
return mix(texture2D(uTexture[1], uv), texture2D(uTexture[0], uv), step((uScroll) - uSection, c + uv.y));
}

void main() {
float brightness = clamp(brightness, - 1.0, 25.0);
float frequency = clamp(frequency, - 999.0, 999.0);
float contrast = clamp(contrast, - 50., 50.0);
float pixelStrength = clamp(pixelStrength, - 20.0, 999.0);
float strength = clamp(strength, - 100., 100.);
float colorExposer = clamp(colorExposer, - 5., 5.);
vec2 uv = .5 * (gl_FragCoord.xy - .5 * resolution.xy) / resolution.y;
uv = mousemove != 0 ? mix(uv, .5 * (gl_FragCoord.xy - .5 * resolution.xy) / resolution.y + mouse.xy / 300., uIntercept) : uv;
float c = (sin((uv.x * 7.0 * snoise(vec3(uv, 1.0))) + (time)) / 15.0 * snoise(vec3(uv, 1.0))) + .01;
vec3 col = vec3(0);
vec2 n, q = vec2(0);
vec2 p = (uv + brightness / 10.0);
float d = dot(p, p);
float a = - (contrast / 100.0);
mat2 angle = rotate2D(angle);

for(float i = 1.;
i <= 10.0;
i ++) {
if(i > quality) break;
p, n *= angle;
if(mousemove == 0) q = p * frequency + time * speed + sin(time) * .0018 * i - pixelStrength * n;
if(mousemove == 1) q = p * frequency + time * speed + sin(time) * .0018 * i + mouse - pixelStrength * n;
if(mousemove == 2) q = p * frequency + time * speed + sin(time) * .0018 * i - pixelStrength + mouse * n;
if(mousemove == 3) q = p * frequency + time * speed + sin(time) * .0018 * i + mouse - pixelStrength + mouse * n;
if(modeA == 0) a += dot(sin(q) / frequency, vec2(strength));
else if(modeA == 1) a += dot(cos(q) / frequency, vec2(strength));
else if(modeA == 2) a += dot(tan(q) / frequency, vec2(strength));
else if(modeA == 3) a += dot(atan(q) / frequency, vec2(strength));
if(modeN == 0) n -= sin(q);
else if(modeN == 1) n -= cos(q);
else if(modeN == 2) n -= tan(q);
else if(modeN == 3) n -= atan(q);
n = mousemove != 0 ? mix(n + mouse, n, uIntercept) : n;
frequency *= waveFactor;
}
col = (color * 4.5) * (a + colorExposer) + exposer * a + a + d;
vec4 base = distortion ? img((vuv + a + contrast / 100.0), c) : img(vuv, c);
base = onMouse == 0 ? base : onMouse == 1 ? mix(img(vuv, c), base, uIntercept) : mix(base, img(vuv, c), uIntercept);
vec4 blend = vec4(col, 1.0);
vec4 final = mix(base, gl_FragColor, uIntercept);
if(mode == - 10) final = base;
else if(mode == - 1) final = minn(base, blend) - maxx(base, blend) + vec4(1.0);
else if(mode == - 9) final = (maxa(blend) == 1.0) ? blend : minn(base * base / (1.0 - blend), vec4(1.0));
else if(mode == - 8) final = base + blend - 2.0 * base * blend;
else if(mode == - 7) final = abs(base - blend);
else if(mode == - 6) final = minn(base, blend);
else if(mode == - 5) final = (mina(blend) == 0.0) ? blend : maxx((1.0 - ((1.0 - base) / blend)), vec4(0.0));
else if(mode == - 4) final = maxa(base) == 1.0 ? blend : minn(base / (1.0 - blend), vec4(1.0));
else if(mode == - 3) final = (1.0 - 2.0 * blend) * base * base + 2.0 * base * blend;
else if(mode == - 2) final = maxa(base) < 0.5 ? 2.0 * base * blend : 1.0 - 2.0 * (1.0 - base) * (1.0 - blend);
else if(mode == 0) final = base + blend;
else if(mode == 1) final = base * blend;
else if(mode == 2) final = 1.0 - (1.0 - base) * (1.0 - blend);
else if(mode == 3) final = blend - base;
else if(mode == 4) final = base / blend;
else if(mode == 5) final = maxx(base + blend - 1.0, vec4(0.0));
else if(mode == 6) final = (base + blend / base) - .55;
else if(mode == 7) final = base + blend * base;
else if(mode == 8) final = mod(base, blend);
else if(mode == 9) final = 1.0 - (base + blend / base) + .5;
else if(mode == 10) final = blend - base * blend;
else if(mode == 11) final = (base + blend / 2.0);
final = mix(final * brightness, mix(maxx(final, vec4(1.0)), final, contrast), 0.5);
final = onMouse == 0 ? final : onMouse == 1 ? mix(base, final, uIntercept) : mix(final, base, uIntercept);
gl_FragColor = final;
}