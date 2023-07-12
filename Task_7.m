%% Name: Leonidas Tsigkounakis - CID: 01927913
clear all
clc
close all
%% Parameter and Signal Definitions:
% PRI xlines for plots
PRI = (1:8)*1400;

% Carrier frequency and wavelength (free space)
fc = 0.5*(12+18)*1e9; % Middle of Ku band
c_light = 3*1e8;
wavelengthc = c_light/fc;

% Clock Period & Noise Factor
Tc = 28*1e-9;

% Uniform Linear Array (ULA)
r = generate_ULA(wavelengthc);

% Detection threshold (generated in task 3 since we had only noise then).
threshold = load("threshold_value_generated_in_task_3.mat").threshold;

% Directed Lobe Gains
GTx_direct = 45;
GRx_direct = 45;

% Backscatter Data
backscatter_cell_format = load("BackscatterData.mat").BackscatterData;
%% Targets are unknown. We do a 30-150 sweep:
% Simualtion with beam sweep from 30 to 150 degrees:
theta_peak = [];
theta_covered = [];
for theta_steer = 30:150
    i = theta_steer - 29;

    theta_covered = [theta_covered, theta_steer];
    [psi_Tx, psi_Rx] = psi_steer(theta_steer, r, wavelengthc);
    
    Rx_point_Z = Rx_prep(cell2mat(backscatter_cell_format(i)), psi_Rx);
    
    % Integration of Radar Pulses - Noncoherent PRI Integration
    theta_peak = [theta_peak, max(generate_noncoherent_PRI_integration(Rx_point_Z))];
end

% Plotting the peak value after the PRI integration. If there is a target
% there must be a significant increase in Rx signal power at its angle.
f1 = figure();
p1 = plot((30:150), theta_peak, LineWidth=1);
hold on
s1 = scatter((30:150), theta_peak, 100, '.');
yline(threshold, 'red', Label=' Threshold');
xlabel('Angle during sweep');
ylabel('Peak magnitude (Volts)');
title('Peaks of Rx signal during angle sweep')
grid on
%print(f1, '-vector', ['Angle_sweep - 34 - Task 7'], '-dpng')

%% Parameter estimation (azimuth target angle):
theta_target_est = theta_covered(theta_peak == max(theta_peak));
disp(['The targets are at ', num2str(theta_target_est), ' degrees!'])

%% Matched Filter and Decision Stage: 
% This is the output of the matched filter. The SNR is best and thus noise
% is attenuated.

[psi_Tx, psi_Rx] = psi_steer(theta_target_est, r, wavelengthc);
Rx_point_Z = Rx_prep(cell2mat(backscatter_cell_format(theta_target_est-29)), psi_Rx);
MF_output = generate_MF(Rx_point_Z);

f2 = figure();
p2 = semilogy(abs(MF_output));
xline(PRI,'black');
yline(threshold, 'red', Label=' Threshold');
xlabel('Sample index');
ylabel('MF output magnitude (Volts)');
title(['Matched filter output (targets at ', num2str(theta_target_est), ' degrees) ']);
grid on
xlim([0, 11200])
%print(f2, '-vector', ['MF output - ', num2str(theta_target_est), 'deg - Task 7'], '-dpng')

%% This matched filters output is then passed to the non-coherent PRI: 
% integrator:
integrator_output = generate_noncoherent_PRI_integration(MF_output);

f3 = figure();
p3 = plot(integrator_output);
xline(PRI,'black');
yline(threshold, 'red', Label=' Threshold');
xlabel('Sample index');
ylabel('Magnitude (Volts)');
title('Non - coherent PRI integrator output');
grid on
xlim([0, 1400])
ylim([0, 3e-5]);
%print(f3, '-vector', ['Non coherent output - ', num2str(theta_target_est), 'deg - Task 7'], '-dpng')

%% Parameter Estimation for Each Target (t_echo, R, RCS): 

peaks = maxk(integrator_output, 3);
for target_i = 1:3

    % t_echo
    t_echo_index = find(integrator_output == peaks(target_i));
    t_echo_target_est = (t_echo_index-7)*Tc; % We subtract 7 because we must consider the bins corresponding to the Tx pulse.
    disp(['Target ', num2str(target_i), ' has a techo of ', num2str(t_echo_target_est*1e6), ' μ seconds!']);
    
    % R
    R_target_est = 0.5*c_light*t_echo_target_est;
    disp(['Target ', num2str(target_i), ' is ', num2str(R_target_est), ' meters away!']);

    % RCS (solve the radar equation with respect to RCS.)
    A = 150;
    avg_peak_point_Z = max(generate_noncoherent_PRI_integration(Rx_point_Z));
    RCS_target = (avg_peak_point_Z^2*((4*pi)^3)*R_target_est^4)/((A*GTx_direct*GRx_direct*wavelengthc)^2);
    % Error at peak

    disp(['Target ', num2str(target_i), ' has an RCS of ', num2str(RCS_target), ' !'])
    disp(' ')
end