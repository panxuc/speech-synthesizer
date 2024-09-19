fs = 8000;
b = 1;
a = [1, -1.3789, 0.9506];
[~, p, ~] = tf2zp(b, a);
f = (abs(angle(p)) * fs) / (2 * pi);

zplane(b, a);
exportgraphics(gcf, 'hw1_1.png');

freqz(b, a);
exportgraphics(gcf, 'hw1_2.png');

impz(b, a);
exportgraphics(gcf, 'hw1_3.png');

n = 0:390;
x = zeros(1, 391);
x(1) = 1;
y = filter(b, a, x);
stem(n, y);
xlim([0, 390]);
xlabel('n (采样)');
ylabel('振幅');
title('Impulse 响应');
exportgraphics(gcf, 'hw1_4.png');
