%% Setup
addpath(genpath('Helper Scripts'))
addpath(genpath('General Code'))
save_dir = 'Lab 3 — Filters';

%% Figure settings
set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');
set(groot,'defaultAxesTickLabelInterpreter','latex'); 

%% Set parameters
% Frequencies tested in experiment
f_exp = [10, 100, 300, 10^3, 2*10^3, 5*10^3, 20*10^3, 50*10^3, 100*10^3];
% Frequencies for plotting
f_range = logspace(-2,10,100);

%% Experimental values
passive_low_mag_exp = [1.00, 0.995, 0.961, 0.741, 0.513, 0.277, 0.0698, 0.0309, 0.0208];
passive_low_phase_exp = [-1.02, -5.72, -15.4, -42.3, -62.0, -80.1, -85.5, -90.2, -91.1];

high_mag_exp = [0.0544, 0.0970, 0.258, 0.690, 0.884, 0.979, 0.995, 1.00, 1.00];
high_phase_exp = [90.5, 87.2, 76.9, 49.6, 30.8, 14.1, 3.84, 3.21, 1.01];

active_low_mag_exp = [1.00, 0.997, 0.939, 0.700, 0.422, 0.186, 0.0662, 0.0536, 0.0112];
active_low_phase_exp = [180, 178, 172, 128, 123, 116, 91.3, 89.9, 90.2];

active_combo_mag_exp = [1.98, 1.95, 1.83, 1.06, 0.468, 0.114, 0.0128, 0.000384, 0.00495];
active_combo_phase_exp = [-1.22, -11.4, -33.2, -86.2, -122, ...
    missing, missing, missing, missing];
%% Passive low pass
R = 10 * 10^3;
C = 1.591 * 10^(-8);
V_in = 354 * 10^(-3);

disp('Passive low pass')
for i = 1:length(f_exp)
    [V_out, gain, phase] = passive_low_pass(f_exp(i), R, C, V_in, true);
end

gains = zeros(1, length(f_range));
phases = zeros(1, length(f_range));
for i = 1:length(f_range)
    [~, gain, phase] = passive_low_pass(f_range(i), R, C, V_in, false);
    gains(i) = gain;
    phases(i) = phase;
end

% Break point
% f_bp = 1/(2 * pi * R * C);
% [~, g_bp, p_bp] = passive_low_pass(f_bp, R, C, V_in, false);

bode_plot(f_range, gains, phases, missing, missing, missing, ...
    f_exp, passive_low_mag_exp, passive_low_phase_exp, ...
    'Passive Low Pass Filter', save_dir);
%% High pass
R = 100 * 10^3;
C = 1.591 * 10^(-9);
V_in = 354 * 10^(-3);

disp('High pass')
for i = 1:length(f_exp)
    [V_out, gain, phase] = high_pass(f_exp(i), R, C, V_in, true);
end

gains = zeros(1, length(f_range));
phases = zeros(1, length(f_range));
for i = 1:length(f_range)
    [~, gain, phase] = high_pass(f_range(i), R, C, V_in, false);
    gains(i) = gain;
    phases(i) = phase;
end

% Break point
% f_bp = 1/(2 * pi * R * C);
% [~, g_bp, p_bp] = high_pass(f_bp, R, C, V_in, false);

bode_plot(f_range, gains, phases, missing, missing, missing, ...
    f_exp, high_mag_exp, high_phase_exp, 'High Pass Filter', save_dir);
%% Active low pass
Ri = 10 * 10^3;
Rf = 10 * 10^3;
Cf = 1.591 * 10^(-8);
V_in = 354 * 10^(-3);

disp('Active low pass')
for i = 1:length(f_exp)
    [V_out, gain, phase] = active_low_pass(f_exp(i), Ri, Rf, Cf, V_in, true);
end

gains = zeros(1, length(f_range));
phases = zeros(1, length(f_range));
for i = 1:length(f_range)
    [~, gain, phase] = active_low_pass(f_range(i), Ri, Rf, Cf, V_in, false);
    gains(i) = gain;
    phases(i) = phase;
end

% Break point
% f_bp = 1/(2 * pi * R * C);
% [~, g_bp, p_bp] = active_low_pass(f_bp, Ri, Rf, Cf, V_in, false);

bode_plot(f_range, gains, phases, missing, missing, missing, ...
    f_list, active_low_mag_exp, active_low_phase_exp, 'Active Low Pass Filter', save_dir);

%% Active low pass combo
Ri_1 = 10 * 10^3;
Ri_2 = 5 * 10^3;
Rf = 10 * 10^3;
Cf = 1.591 * 10^(-8);
V_in = 354 * 10^(-3);

disp('Active low pass combo')
for i = 1:length(f_exp)
    [V_out, gain, phase] = active_low_pass_combo(f_exp(i), Ri_1, Ri_2, Rf, Cf, V_in, true);
end

gains = zeros(1, length(f_range));
phases = zeros(1, length(f_range));
for i = 1:length(f_range)
    [~, gain, phase] = active_low_pass_combo(f_range(i), Ri_1, Ri_2, Rf, Cf, V_in, false);
    gains(i) = gain;
    phases(i) = phase;
end

% Break point
% f_bp = 1/(2 * pi * R * C);
% [~, g_bp, p_bp] = active_low_pass(f_bp, Ri, Rf, Cf, V_in, false);

bode_plot(f_range, gains, phases, missing, missing, missing, ...
    f_list, active_combo_mag_exp, active_combo_phase_exp, 'Active Low Pass Combo', save_dir);
%% Functions
function [V_out, gain, phase] = passive_low_pass(f, R, C, V_in, print)
    XC = 1/(2 * pi * f * C);
    V_out = V_in * XC / sqrt(R^2 + XC^2);
    gain = V_out/V_in;
    phase = atand(-R / XC);
    
    if print
        [V_scaled, ~, ~, console_label] = scientific_rescale(V_out);
        disp(['V_out: ', num2str(V_scaled), console_label, 'V, gain: ', num2str(gain), ...
            ', phase: ', num2str(phase)])
    end
end

function [V_out, gain, phase] = high_pass(f, R, C, V_in, print)
    XC = 1/(2 * pi * f * C);
    V_out = V_in * R / sqrt(R^2 + XC^2);
    gain = V_out/V_in;
    phase = atand(XC / R);
    
    if print
        [V_scaled, ~, ~, console_label] = scientific_rescale(V_out);
        disp(['V_out: ', num2str(V_scaled), console_label, 'V, gain: ', num2str(gain), ...
            ', phase: ', num2str(phase)])
    end
end

function [V_out, gain, phase] = active_low_pass(f, Ri, Rf, Cf, V_in, print)
    XC = 1/(2 * pi * f * Cf);
    Zeq = Rf * XC / sqrt(Rf^2 + XC^2);
    V_out = V_in * Zeq / Ri;
    gain = V_out/V_in;
    phase = atand(-Rf/XC)+180;
    
    if print
        [V_scaled, ~, ~, console_label] = scientific_rescale(V_out);
        disp(['V_out: ', num2str(V_scaled), console_label, 'V, gain: ', num2str(gain), ...
            ', phase: ', num2str(phase)])
    end

end

function [V_out, gain, phase] = active_low_pass_combo(f, Ri_1, Ri_2, Rf, Cf, V_in, print)
    XC = 1/(2 * pi * f * Cf);
    Zeq = Rf * XC / sqrt(Rf^2 + XC^2);
    V_out = V_in * Zeq^2 / (Ri_1 * Ri_2);
    gain = V_out/V_in;
    phase = atand(2*XC*Rf/(Rf^2-XC^2));
    phase(phase>0) = phase - 180;
    
    if print
        try
            [V_scaled, ~, ~, console_label] = scientific_rescale(V_out);
            disp(['V_out: ', num2str(V_scaled), console_label, 'V, gain: ', num2str(gain), ...
                ', phase: ', num2str(phase)])
        catch
            disp(['V_out: ', num2str(V_out), 'V, gain: ', num2str(gain), ...
                ', phase: ', num2str(phase)])
        end
    end

end