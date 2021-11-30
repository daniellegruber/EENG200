%% Setup
addpath(genpath('Helper Scripts'))
save_dir = 'Lab 5 — Transistor Amplifier';

%% Figure settings
set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');
set(groot,'defaultAxesTickLabelInterpreter','latex');

%% Set parameters

R_C = 1.2 * 10^3; % In ohms
R_E = 220; % In ohms
V_CC = 12; % In volts
beta_F = 169;

%V_BE_list = 0.66:0.02:0.72;
V_BE_list = [0.66, 0.68, 0.7, 0.71, 0.72];
V_BE_labels = cell(1, length(V_BE_list));
V_CE = -0:0.001:V_CC; % Plot until V_CC so intersect x-axis

% For plotting load line
[iC_load, plot_label] = voltage_divider_bias(beta_F, V_CC, V_CE, R_C, R_E);

% For plotting output characteristics
V_T = 0.026;
beta_R = 0.1;
I_S = 1E-14;

%%  Calculate and plot npn BJT collector characteristics using Ebers-Moll model

% Create figure 
bjt_fig = figure('units','normalized','outerposition',[0 0 0.6 1]);
hold on

for i = 1:length(V_BE_list)
    V_BE = V_BE_list(i);
    V_BE_labels{i} = ['$V_{BE} =', num2str(V_BE), '$ V'];
    [iC_char, ~] = ebers_moll(V_BE, V_CE, V_T, beta_R, I_S);
    plot(V_CE, iC_char, 'LineWidth', 1.5); % Current in mA.
end

% Load line
plot(V_CE, iC_load, 'LineWidth', 1.5);

title('BJT Output Characteristics','FontSize',50)
xlabel('$V_{CE}$ (V)');
ylabel(['$i_C$ (', plot_label, 'A)']);

set(gca,'FontSize',20)
set(gcf,'color','w')

%% Shade modes of operation
V_CE_fa = V_CE(V_CE > 0.2 & V_CE < V_CC);
V_BE_fa_min = 0.7;

ylimits = ylim;
iC_fa_range = zeros(1,2);
iC_fa_range(1) = ebers_moll(V_BE_fa_min, V_CE_fa(1), V_T, beta_R, I_S);
iC_fa_range(2) = ylimits(2);

x = V_CE_fa(1);
w = V_CE_fa(end) - V_CE_fa(1);
y = iC_fa_range(1);
h = iC_fa_range(2) - iC_fa_range(1);
pos = [x, y, w, h];

fa = rectangle('Position',pos, 'FaceColor',[0.96, 0.2, 0.5, 0.08], 'LineStyle','none');
text(x + w - 2, y + 1,'Forward Active','VerticalAlignment','bottom',...
        'HorizontalAlignment','center','interpreter','latex',...
        'FontSize',20)
    
    
%% Find and plot Q points
Q_pts = find_Q_pts(iC_load, V_BE_list, V_CE, V_T, beta_R, I_S);
scatter(Q_pts(:,1), Q_pts(:,2), 30, 'k', 'filled')

legend([V_BE_labels, {'Load Line', 'Q-Points'}]);
    
export_fig([save_dir, filesep, 'BJT Characteristics'], '-png', bjt_fig)
%% Use Ebers-Moll model to calculate iC

function [iC_char, plot_label] = ebers_moll(V_BE, V_CE, V_T, beta_R, I_S)

    V_BC = V_BE - V_CE;
    
    forward_exp = exp(V_BE / V_T) - exp(V_BC / V_T);
    reverse_exp = (exp(V_BC / V_T) - 1) / beta_R;
    
    iC = I_S * (forward_exp - reverse_exp);
    sign_iC = sign(iC);
    iC_char = (iC + sign_iC .* iC) / 2; % Zero negative vals
    [iC_char, ~, plot_label, ~] = scientific_rescale(iC_char);

end

function [iC_load, plot_label] = voltage_divider_bias(beta_F, V_CC, V_CE, R_C, R_E)
    
    alpha = beta_F / (beta_F + 1);
    iC = (V_CC - V_CE) / (R_C + R_E / alpha);
    [iC_load, ~, plot_label, ~] = scientific_rescale(iC);

end

function Q_pts = find_Q_pts(iC_load, V_BE_list, V_CE, V_T, beta_R, I_S)
    Q_pts = zeros(length(V_BE_list), 3);
    
    for i = 1:length(V_BE_list)
        V_BE = V_BE_list(i);
        [iC_char, ~] = ebers_moll(V_BE, V_CE, V_T, beta_R, I_S);
        [~, idx] = min(abs(iC_load - iC_char));
        Q_pts(i, 1) = V_CE(idx);
        Q_pts(i, 2) = iC_load(idx);
        Q_pts(i, 3) = V_BE;
    end
    
end