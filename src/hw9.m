PT = zeros(1, 100);
for m = 1:100
    PT(m) = 80 + 5 * mod(m-1, 50);
end

fs = 8000;
x = zeros(1, fs);
n = 1;
while n <= fs
    x(n) = 1;
    n = n + PT(ceil(n/80));
end

b = 1;
a = [1, -1.3789, 0.9506];
s = filter(b, a, x);
sound(s, fs);

subplot(2, 1, 1);
plot(s);
title('$s(n)$', 'Interpreter', 'latex');
subplot(2, 1, 2);
S = fft(s);
plot(abs(S));
title('$S(f)$', 'Interpreter', 'latex');
exportgraphics(gcf, 'hw9.png');
