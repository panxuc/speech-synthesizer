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

sound(x, fs);

subplot(2, 1, 1);
plot(x);
title('$e(n)$', 'Interpreter', 'latex');
subplot(2, 1, 2);
X = fft(x);
plot(abs(X));
title('$E(f)$', 'Interpreter', 'latex');
exportgraphics(gcf, 'hw8.png');
