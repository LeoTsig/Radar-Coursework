%% Name: Leonidas Tsigkounakis - CID: 01927913
clear all
clc
close all
% Parameter and Signal Definitions: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PRI xlines for plots
PRI = (1:8)*1400;

% Carrier frequency and wavelength (free space)
fc = 0.5*(12+18)*1e9; % Middle of Ku band
c_light = 3*1e8;
wavelengthc = c_light/fc;

% Clock Period & Noise Factor
Tc = 28*1e-9;
NF = 3.1068;

% Uniform Linear Array (ULA)
r = generate_ULA(wavelengthc);

% Detection threshold (generated in task 3 since we had only noise then).
threshold = load("threshold_value_generated_in_task_3.mat").threshold;

% Target Parameters - Collumn Vectors
theta_target = transpose([40, 70]);
R_target = transpose([2000, 3000]);
RCS_target = transpose([1, 5]);
complexity_target = transpose([0, 1]);

% Directed Lobe Gains
GTx_direct = 45;
GRx_direct = 45;

% Assuming target is known (we take for granted that theta_steer must be 40 degrees): %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simualtion with known target params

theta_steer_known = 40;  %%%% SOS: Change the steering angle (only 40 or 70 as per figure 2) to get each plot for each target. %%%%

[psi_Tx_known, psi_Rx_known] = psi_steer(theta_steer_known, r, wavelengthc);
coded_pulse_train = generate_pulse_train();
Tx_pulse_known = Tx_prep(coded_pulse_train, psi_Tx_known);
backscatter_known = generate_backscatter(Tc, wavelengthc, theta_target, R_target, RCS_target, complexity_target, r, NF, Tx_pulse_known);
Rx_point_Z_known = Rx_prep(backscatter_known, psi_Rx_known);

% Plotting the Rx signal at point Z.
f1 = figure;
p1 = semilogy(abs(Rx_point_Z_known));
xline(PRI,'black');
xlabel('Sample index');
ylabel('Rx magnitude (Volts)');
title(['Rx signal at point Z (target at ', num2str(theta_steer_known), ' degrees) '])
grid on
xlim([0, 11200])
%print(f1, '-vector', ['Point Z - ', num2str(theta_steer_known), 'deg - Task 5'], '-dpng')

% Assuming target is not known (we can't take for granted that theta_steer is 40 degrees, that's why we do a 30-150 sweep):
% Simualtion with beam sweep from 30 to 150 degrees:
theta_peak = [];
theta_covered = [];
for theta_steer = 30:150
    
    theta_covered = [theta_covered, theta_steer];

    [psi_Tx, psi_Rx] = psi_steer(theta_steer, r, wavelengthc);
    coded_pulse_train = generate_pulse_train();
    Tx_pulse = Tx_prep(coded_pulse_train, psi_Tx);
    backscatter = generate_backscatter(Tc, wavelengthc, theta_target, R_target, RCS_target, complexity_target, r, NF, Tx_pulse);
    Rx_point_Z = Rx_prep(backscatter, psi_Rx);
    
    % Integration of Radar Pulses - Noncoherent PRI Integration
    theta_peak = [theta_peak, max(generate_noncoherent_PRI_integration(Rx_point_Z))];
end

% Plotting the peak value after the PRI integration. If there is a target
% there must be a significant increase in Rx signal power at its angle.
f2 = figure();
p2 = plot((30:150), theta_peak, LineWidth=1);
hold on
s2 = scatter((30:150), theta_peak, 100, '.');
yline(threshold, 'red', Label=' Threshold');
xlabel('Angle during sweep');
ylabel('Peak magnitude (Volts)');
title('Peaks of Rx signal during angle sweep')
grid on
%print(f2, '-vector', ['Angle_sweep - 40 and 70 deg - Task 5'], '-dpng')

% Target angles estimation after inspecting figure 2 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp(['The targets are at 40 and 50 degrees!'])

% Matched Filter and Decision Stage: %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This is the output of the matched filter. The SNR is best and thus noise
% is attenuated.
MF_output = generate_MF(Rx_point_Z_known);

f3 = figure();
p3 = semilogy(abs(MF_output));
xline(PRI,'black');
yline(threshold, 'red', Label=' Threshold');
xlabel('Sample index');
ylabel('MF output magnitude (Volts)');
title(['Matched filter output (target at ', num2str(theta_steer_known), ' degrees) ']);
grid on
xlim([0, 11200])
%print(f3, '-vector', ['MF output - ', num2str(theta_steer_known), 'deg - Task 5'], '-dpng')

% This matched filters output is then passed to the non-coherent PRI
% integrator:
integrator_output = generate_noncoherent_PRI_integration(MF_output);

f4 = figure();
p4 = plot(integrator_output);
xline(PRI,'black');
yline(threshold, 'red', Label=' Threshold');
xlabel('Sample index');
ylabel('Magnitude (Volts)');
title(['Non - coherent PRI integrator output']);
grid on
xlim([0, 1400])
ylim([0, 3e-5]);
%print(f4, '-vector', ['Non coherent output - ', num2str(theta_steer_known), 'deg - Task 5'], '-dpng')

% Parameter Estimation (t_echo, R, RCS): %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% t_echo
t_echo_index = find(integrator_output == max(integrator_output));
t_echo_target_est = (t_echo_index-7)*Tc; % We subtract 7 because we must consider the bins corresponding to the Tx pulse.

% R
R_target_est = 0.5*c_light*t_echo_target_est;
disp(['The target is ', num2str(R_target_est), ' meters away!']);

% RCS (solve the radar equation with respect to RCS.)
A = 150;
avg_peak_point_Z = max(generate_noncoherent_PRI_integration(Rx_point_Z_known));
RCS_target = (avg_peak_point_Z^2*((4*pi)^3)*R_target_est^4)/((A*GTx_direct*GRx_direct*wavelengthc)^2);
% Error at peak

disp(['The target has an RCS of ', num2str(RCS_target), ' !'])