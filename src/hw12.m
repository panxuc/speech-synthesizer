fs = 8000;
b = 1;
a = [1, -1.3789, 0.9506];
[z, p, k] = tf2zp(b, a);

p = p .* exp(1j * sign(angle(p)) * 300 * pi / fs);

[b, a] = zp2tf(z, p, k);

f = (abs(angle(p)) * fs) / (2 * pi);
