function bode_plot(f_range, gains, phases, f_bp, g_bp, p_bp, ....
    f_exp, gain_exp, phase_exp, plt_name, save_dir)
%BODE_PLOT Creates theoretical gain (magnitude) and phase bode plot 
% (contained in two subplots) given array of frequencies, gains, and 
% phases. Also plots gain and phase at break frequency as well as
% experimental data on top of theoretical curve when inputted.
%
%   Inputs
%   ----------
%   f_range: array of frequencies to plot
%
%   gains: corresponding array of gains
%
%   phases: corresponding array of phase angles
%
%   f_bp: break frequency, set as numeric value if desired for plotting,
%   otherwise set as missing
%
%   g_pb: gain at break frequency, set as numeric value if desired for 
%   plotting, otherwise set as missing
%
%   p_pb: phase at break frequency, set as numeric value if desired for 
%   plotting, otherwise set as missing
%
%   f_exp: array of frequencies experimentally tested, left empty if not
%   desired for plotting
%
%   gain_exp: array of gains correspondting to f_exp, left empty if not
%   desired for plotting
%
%   phase_exp: array of phases correspondting to f_exp, left empty if not
%   desired for plotting
%
%   plt_name: title to display on overall bode plot
%
%   save_dir: directory to save figure

bode_plt = figure('units','normalized','outerposition',[0 0 0.8 1]);

% Gain
subplot(1,2,1)
loglog(f_range, gains);
title('Magnitude Plot','FontSize',50)
xlabel('$f$');
ylabel('$\textrm{Magnitude} \hspace{5pt} \frac{V_{out}}{V_{in}} \hspace{5pt} (dB)$');

y_ticks = yticks;
y_tick_labels = string(log10(y_ticks)*20);
yticklabels(y_tick_labels);

set(gca,'FontSize',20)
set(gcf,'color','w')

ylim([y_ticks(1), y_ticks(end) + 2])
xlim([f_range(1),f_range(end)])

hold on
if ~ismissing(f_bp) 
    hold on
    plot(f_bp, g_bp,'o','MarkerSize',10,'MarkerEdgeColor','b')
    text(f_bp, g_bp + 0.3,'Break Point','VerticalAlignment','bottom',...
        'HorizontalAlignment','center','interpreter','latex',...
        'FontSize',16)
end
if ~isempty(f_exp)
    nonmissing = ~ismissing(phase_exp);
    plot(f_exp(nonmissing), gain_exp(nonmissing),'o','MarkerSize',10,'MarkerEdgeColor','b')
end

% Phase
subplot(1,2,2)

plot(f_range, phases);
set(gca, 'XScale', 'log')
title('Phase Plot','FontSize',50)
xlabel('$f$');
ylabel('$\textrm{Phase} \hspace{5pt} \phi \hspace{5pt} \textrm{(degrees)}$');

set(gca,'FontSize',20)
set(gcf,'color','w')

y_ticks = yticks;
ylim([y_ticks(1), y_ticks(end) + 4])
xlim([f_range(1),f_range(end)])

hold on
if ~ismissing(f_bp)
    plot(f_bp, p_bp,'o','MarkerSize',10,'MarkerEdgeColor','b')
    text(f_bp + 38000, p_bp - 1.7,'Break Point','VerticalAlignment','bottom',...
        'HorizontalAlignment','center','interpreter','latex',...
        'FontSize',16)
end
if ~isempty(f_exp)
    nonmissing = ~ismissing(phase_exp);
    plot(f_exp(nonmissing), phase_exp(nonmissing),'o','MarkerSize',10,'MarkerEdgeColor','b')
    legend({'Theoretical','Experimental'})
end

sgtitle(plt_name, 'FontSize', 25)

export_fig([save_dir, filesep, 'Bode Plot, ', plt_name], '-png',bode_plt)
end