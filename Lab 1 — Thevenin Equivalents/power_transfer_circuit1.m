%% Setup
addpath(genpath('Helper Scripts'))
save_dir = 'Lab 1 — Thevenin Equivalents';

%% Figure settings
set(groot,'defaulttextinterpreter','latex');
set(groot,'defaultLegendInterpreter','latex');
set(groot,'defaultAxesTickLabelInterpreter','latex'); 

%% Set parameters

V_s = 1; 
R_1 = 200;
R_2 = 200;
R_3 = 200;

%% Solve for/find important values

% Solve for V_T
syms V_T
eqn = cell(1,5);
eqn{1} = (V_s - V_T)/R_1 == V_T/R_2;

sol = solve(eqn, V_T);
V_T = sol;
disp(['V_T = ', num2str(double(V_T))])

% Find R_T
R_T = (R_1*R_2)/(R_1 + R_2) + R_3;
disp(['R_T = ', num2str(double(R_T))])

% Find I_sc
I_sc = V_T/R_T;
disp(['I_sc = ', num2str(double(I_sc))])

% Solve for V_L, I_L, and P_L
syms V_L I_L P_L R_L
eqn = cell(1,3);
eqn{1} = V_T == I_L * (R_T + R_L);
eqn{2} = V_L == I_L * R_L;
eqn{3} = P_L == I_L * V_L;

sol = solve(eqn, [V_L, I_L, P_L]);
V_L = matlabFunction(sol.V_L);
I_L = matlabFunction(sol.I_L);
P_L = matlabFunction(sol.P_L);

disp(['V_L @ R_L = R_T: ', num2str(double(V_L(R_T)))])
disp(['I_L @ R_L = R_T: ', num2str(double(I_L(R_T)))])
disp(['P_L @ R_L = R_T: ', num2str(double(P_L(R_T)))])

%% Set range of R_L

R_L = 0:10:1010;

%% Plot the power
x = R_L;
y = P_L(R_L);
[x_scaled, new_x_order, x_order_label, ~] = scientific_rescale(x);
[y_scaled, new_y_order, y_order_label, ~] = scientific_rescale(y);

figure('units','normalized','outerposition',[0 0 0.6 0.9]);
plot(x_scaled, y_scaled);
title('$\textbf{Power Transfer}$','FontSize',50)
xlabel(['Resistor Load (', x_order_label,'$\Omega$)']);
ylabel(['Power to the Load (', y_order_label,'W)']);

set(gca,'FontSize',20)
set(gcf,'color','w')

P_max = max(y_scaled);
yline(P_max,'--','Max Power Transfer','interpreter','latex','FontSize',20)

%% Plot points associated with experimental setup
R_test = [200, 300];
x1 = R_test;
y1 = zeros(1,length(x1));
labels = cell(1,length(x1));
for i=1:length(x1)
    y1(i) = change_order_mag(P_L(x1(i)), get_order(P_L(x1(i)))-new_y_order);
    labels{i} = ['$R_L =$ ', num2str(x1(i)), ' ',...
        x_order_label, '$\Omega$'];
end

hold on
plot(x1,y1,'o','MarkerSize',10,'MarkerEdgeColor','b')

x1(1) = x1(1) - 120;
y1(1) = y1(1) - 5;
y1(2) = y1(2) + 3;

xlim([x(1)-60, x(end)])
ylim([y_scaled(1), y_scaled(end) + 80])

text(x1,y1,labels,'VerticalAlignment','bottom',...
    'HorizontalAlignment','center','interpreter','latex',...
    'FontSize',20)

export_fig([save_dir, filesep, 'Power Transfer Circuit 1'], '-png')
%% Calculate percent error between experimental and theoretical values
% For points given in x1

percent_err = @(act_val, exp_val) abs((exp_val - act_val)./act_val) * 100;

V_T_exp = 486.5 * 10^-3;
I_sc_exp = 1.67 * 10^-3;
R_T_exp = 306.02;

vars = {'V_T', 'I_sc', 'R_T'};
for v = 1:length(vars)
    pe = eval(['percent_err(double(',vars{v},'), double(', vars{v},'_exp));']);
    disp(['Percent Error:', newline, vars{v}, ': ', num2str(double(pe))])
end

V_L_exp = zeros(1, length(R_test));
I_L_exp = zeros(1, length(R_test));
P_L_exp = zeros(1, length(R_test));

V_L_exp(1) = 198.1 * 10^-3;
V_L_exp(2) = 248.2 * 10^-3;

I_L_exp(1) = 0.899 * 10^-3;
I_L_exp(2) = 0.82 * 10^-3;

P_L_exp(1) = 0.1781 * 10^-3;
P_L_exp(2) = 0.2035 * 10^-3;

vars = {'V_L', 'I_L', 'P_L'};
for v = 1:length(vars)
    for i = 1:length(R_test)
        pe = eval(['percent_err(double(',vars{v},'(R_test(i))), double(', vars{v},'_exp(i)));']);
        disp(['Percent Error, R = ', num2str(R_test(i)), ':', newline,...
            vars{v}, ': ', num2str(double(pe))])
    end
end