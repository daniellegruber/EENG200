%%
R1 = 20 * 10^3;
R2 = 3.84 * 10^3;
RE = 220;
RC = 1.2 * 10^3;
RL = 45;
C1 = 10^(-6);
C2 = 10^(-9);
CE = 10^(-6);
Rb = 1 * 10^3;
r_pi = 1.2 * 10^3;
beta = 169;
ib = 28 * 10^(-6);

[Vi, Vo, A] = small_signal_model(w, R1, R2, RE, RC, RL, C1, C2, CE, Rb, r_pi, beta, ib);

frq_lst = [100, 300, 10^3, 2*10^3, 5*10^3, 10*10^3];

for f = 1:length(frq_lst)
    frq = frq_lst(f);
    [frq_scaled, ~, ~, label] = scientific_rescale(frq);
    disp([newline, 'Frequency = ', num2str(frq_scaled), ' ', label, 'Hz']);
    disp(['Vi = ' num2str(double(Vi(frq)))])
    disp(['Vo = ' num2str(double(Vo(frq)))])
    disp(['A = ' num2str(double(A(frq)))])
end

function [Vi, Vo, A] = small_signal_model(w, R1, R2, RE, RC, RL, C1, C2, CE, Rb, r_pi, beta, ib)

syms w

ic = beta * ib;

ZC1 = 1/(1j * w * C1);
ZC2 = 1/(1j * w * C2);
ZCE = 1/(1j * w * CE);

Zi = Z_parallel([ZC1, R1, R2]) + Rb;
Ze = Z_parallel([ZCE, RE]);
Zo = Z_parallel([ZC2 + RL, RC]);

Vi = ib * (Zi + r_pi) - (ib + ic) * Ze;
Vo = ic * Zo;
A = Vo / Vi; 

Vi = matlabFunction(Vi);
Vo = matlabFunction(Vo);
A = matlabFunction(A);

end

function Zeq = Z_parallel(z)
Zeq = 1/sum(1./z); 
end

function Zeq = Z_series(z)
Zeq = sum(z); 
end