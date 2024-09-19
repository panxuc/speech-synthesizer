function speechproc()

    % 定义常数
    FL = 80;                % 帧长
    WL = 240;               % 窗长
    P = 10;                 % 预测系数个数
    s = readspeech('voice.pcm',100000);             % 载入语音s
    L = length(s);          % 读入语音长度
    FN = floor(L/FL)-2;     % 计算帧数
    % 预测和重建滤波器
    exc = zeros(L,1);       % 激励信号（预测误差）
    zi_pre = zeros(P,1);    % 预测滤波器的状态
    s_rec = zeros(L,1);     % 重建语音
    zi_rec = zeros(P,1);
    % 合成滤波器
    exc_syn = zeros(L,1);   % 合成的激励信号（脉冲串）
    s_syn = zeros(L,1);     % 合成语音
    zi_syn = zeros(P,1);
    % 变调不变速滤波器
    exc_syn_t = zeros(L,1);   % 合成的激励信号（脉冲串）
    s_syn_t = zeros(L,1);     % 合成语音
    zi_syn_t = zeros(P,1);
    % 变速不变调滤波器（假设速度减慢一倍）
    exc_syn_v = zeros(2*L,1);   % 合成的激励信号（脉冲串）
    s_syn_v = zeros(2*L,1);     % 合成语音
    zi_syn_v = zeros(P,1);

    hw = hamming(WL);       % 汉明窗

    i = 2 * FL + 1;
    i_t = 2 * FL + 1;
    i_v = 4 * FL + 1;
    
    % 依次处理每帧语音
    for n = 3:FN

        % 计算预测系数（不需要掌握）
        s_w = s(n*FL-WL+1:n*FL).*hw;    %汉明窗加权后的语音
        [A E] = lpc(s_w, P);            %用线性预测法计算P个预测系数
                                        % A是预测系数，E会被用来计算合成激励的能量

        if n == 27
        % (3) 在此位置写程序，观察预测系统的零极点图
            zplane(1, A);
        end
        
        s_f = s((n-1)*FL+1:n*FL);       % 本帧语音，下面就要对它做处理

        % (4) 在此位置写程序，用filter函数s_f计算激励，注意保持滤波器状态
        [exc((n-1)*FL+1:n*FL), zi_pre] = filter(A, 1, s_f, zi_pre);

        % (5) 在此位置写程序，用filter函数和exc重建语音，注意保持滤波器状态
        [s_rec((n-1)*FL+1:n*FL), zi_rec] = filter(1, A, exc((n-1)*FL+1:n*FL), zi_rec);

        % 注意下面只有在得到exc后才会计算正确
        s_Pitch = exc(n*FL-222:n*FL);
        PT = findpitch(s_Pitch);    % 计算基音周期PT（不要求掌握）
        G = sqrt(E*PT);           % 计算合成激励的能量G（不要求掌握）

        
        % (10) 在此位置写程序，生成合成激励，并用激励和filter函数产生合成语音
        while i <= n * FL
            exc_syn(i) = G;
            i = i + PT;
        end
        [s_syn((n-1)*FL+1:n*FL), zi_syn] = filter(1, A, exc_syn((n-1)*FL+1:n*FL), zi_syn);

        % (11) 不改变基音周期和预测系数，将合成激励的长度增加一倍，再作为filter
        % 的输入得到新的合成语音，听一听是不是速度变慢了，但音调没有变。
        while i_v <= n * 2 * FL
            exc_syn_v(i_v) = G;
            i_v = i_v + PT;
        end
        [s_syn_v((n-1)*2*FL+1:n*2*FL), zi_syn_v] = filter(1, A, exc_syn_v((n-1)*2*FL+1:n*2*FL), zi_syn_v);

        % (13) 将基音周期减小一半，将共振峰频率增加150Hz，重新合成语音，听听是啥感受～
        [z, p, k] = tf2zp(1, A);
        p = p .* exp(1j * sign(angle(p)) * 300 * pi / 8000);
        [B_t, A_t] = zp2tf(z, p, k);
        while i_t <= n * FL
            exc_syn_t(i_t) = G;
            i_t = i_t + PT;
        end
        [s_syn_t((n-1)*FL+1:n*FL), zi_syn_t] = filter(B_t, A_t, exc_syn_t((n-1)*FL+1:n*FL), zi_syn_t);
        
    end

    % (6) 在此位置写程序，听一听 s ，exc 和 s_rec 有何区别，解释这种区别
    % 后面听语音的题目也都可以在这里写，不再做特别注明

    % (6)
    % sound([s;exc;s_rec] / 32768, 8000);
    % figure;
    % subplot(4, 1, 1);
    % plot(exc);
    % title('$e(n)$', 'Interpreter', 'latex');
    % subplot(4, 1, 2);
    % plot(s);
    % title('$s(n)$', 'Interpreter', 'latex');
    % subplot(4, 1, 3);
    % plot(s_rec);
    % title('$\hat{s}(n)$', 'Interpreter', 'latex');
    % subplot(4, 1, 4);
    % delta = s - s_rec;
    % plot(delta);
    % title('$s(n)-\hat{s}(n)$', 'Interpreter', 'latex');
    % exportgraphics(gcf, 'hw6.png');
    % figure;
    % subplot(4, 1, 1);
    % exc_clip = exc(2000 : 3000);
    % plot(exc_clip);
    % title('$e(n)$', 'Interpreter', 'latex');
    % subplot(4, 1, 2);
    % s_clip = s(2000 : 3000);
    % plot(s_clip);
    % title('$s(n)$', 'Interpreter', 'latex');
    % subplot(4, 1, 3);
    % s_rec_clip = s_rec(2000 : 3000);
    % plot(s_rec_clip);
    % title('$\hat{s}(n)$', 'Interpreter', 'latex');
    % subplot(4, 1, 4);
    % delta_clip = s_clip - s_rec_clip;
    % plot(delta_clip);
    % title('$s(n)-\hat{s}(n)$', 'Interpreter', 'latex');
    % exportgraphics(gcf, 'hw6_clip.png');

    % (10)
    % sound([s;s_syn] / 32768, 8000);
    % figure;
    % subplot(2, 1, 1);
    % plot(s);
    % title('$s(n)$', 'Interpreter', 'latex');
    % subplot(2, 1, 2);
    % plot(s_syn);
    % title('$\tilde{s}(n)$', 'Interpreter', 'latex');
    % exportgraphics(gcf, 'hw10.png');

    % (11)
    % sound([s;s_syn;s_syn_v] / 32768, 8000);
    % figure;
    % subplot(3, 1, 1);
    % plot(s);
    % title('$s(n)$', 'Interpreter', 'latex');
    % subplot(3, 1, 2);
    % plot(s_syn);
    % title('$\tilde{s}(n)$', 'Interpreter', 'latex');
    % subplot(3, 1, 3);
    % plot(s_syn_v);
    % title('$\tilde{s}_v(n)$', 'Interpreter', 'latex');
    % exportgraphics(gcf, 'hw11.png');
    % figure;
    % subplot(3, 1, 1);
    % S = fft(s);
    % plot(abs(S));
    % title('$S(f)$', 'Interpreter', 'latex');
    % subplot(3, 1, 2);
    % S_syn = fft(s_syn);
    % plot(abs(S_syn));
    % title('$\tilde{S}(f)$', 'Interpreter', 'latex');
    % subplot(3, 1, 3);
    % S_syn_v = fft(s_syn_v);
    % plot(abs(S_syn_v));
    % title('$\tilde{S}_v(f)$', 'Interpreter', 'latex');
    % exportgraphics(gcf, 'hw11_fft.png');

    % (13)
    % sound([s;s_syn;s_syn_t] / 32768, 8000);
    % figure;
    % subplot(3, 1, 1);
    % plot(s);
    % title('$s(n)$', 'Interpreter', 'latex');
    % subplot(3, 1, 2);
    % plot(s_syn);
    % title('$\tilde{s}(n)$', 'Interpreter', 'latex');
    % subplot(3, 1, 3);
    % plot(s_syn_t);
    % title('$\tilde{s}_t(n)$', 'Interpreter', 'latex');
    % exportgraphics(gcf, 'hw13.png');
    % figure;
    % subplot(3, 1, 1);
    % S = fft(s);
    % plot(abs(S));
    % title('$S(f)$', 'Interpreter', 'latex');
    % subplot(3, 1, 2);
    % S_syn = fft(s_syn);
    % plot(abs(S_syn));
    % title('$\tilde{S}(f)$', 'Interpreter', 'latex');
    % subplot(3, 1, 3);
    % S_syn_t = fft(s_syn_t);
    % plot(abs(S_syn_t));
    % title('$\tilde{S}_t(f)$', 'Interpreter', 'latex');
    % exportgraphics(gcf, 'hw13_fft.png');

    % 保存所有文件
    writespeech('exc.pcm',exc);
    writespeech('rec.pcm',s_rec);
    writespeech('exc_syn.pcm',exc_syn);
    writespeech('syn.pcm',s_syn);
    writespeech('exc_syn_t.pcm',exc_syn_t);
    writespeech('syn_t.pcm',s_syn_t);
    writespeech('exc_syn_v.pcm',exc_syn_v);
    writespeech('syn_v.pcm',s_syn_v);
return

% 从PCM文件中读入语音
function s = readspeech(filename, L)
    fid = fopen(filename, 'r');
    s = fread(fid, L, 'int16');
    fclose(fid);
return

% 写语音到PCM文件中
function writespeech(filename,s)
    fid = fopen(filename,'w');
    fwrite(fid, s, 'int16');
    fclose(fid);
return

% 计算一段语音的基音周期，不要求掌握
function PT = findpitch(s)
[B, A] = butter(5, 700/4000);
s = filter(B,A,s);
R = zeros(143,1);
for k=1:143
    R(k) = s(144:223)'*s(144-k:223-k);
end
[R1,T1] = max(R(80:143));
T1 = T1 + 79;
R1 = R1/(norm(s(144-T1:223-T1))+1);
[R2,T2] = max(R(40:79));
T2 = T2 + 39;
R2 = R2/(norm(s(144-T2:223-T2))+1);
[R3,T3] = max(R(20:39));
T3 = T3 + 19;
R3 = R3/(norm(s(144-T3:223-T3))+1);
Top = T1;
Rop = R1;
if R2 >= 0.85*Rop
    Rop = R2;
    Top = T2;
end
if R3 > 0.85*Rop
    Rop = R3;
    Top = T3;
end
PT = Top;
return