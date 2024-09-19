fs = 8000;

f_200 = 200;
N_200 = floor(fs / f_200);
NS_200 = fs;
x_200 = zeros(1, NS_200);
for i = 0:NS_200-1
    if mod(i, N_200) == 0
        x_200(i+1) = 1;
    end
end

sound(x_200, fs);

f_300 = 300;
N_300 = floor(fs / f_300);
NS_300 = fs;
x_300 = zeros(1, NS_300);
for i = 0:NS_300-1
    if mod(i, N_300) == 0
        x_300(i+1) = 1;
    end
end

sound(x_300, fs);
