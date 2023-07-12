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
NF = 3.1068;

% Uniform Linear Array (ULA)
r = generate_ULA(wavelengthc);

% Target Parameters - Collumn Vectors
theta_target = [];
R_target = [];
RCS_target = [];
complexity_target = [];

% Simulation
[psi_Tx, psi_Rx] = psi_steer(30, r, wavelengthc); % random angle since it does not play a role as there are no targets.
coded_pulse_train = generate_pulse_train();
Tx_pulse = Tx_prep(coded_pulse_train, psi_Tx);
backscatter = generate_backscatter(Tc, wavelengthc, theta_target, R_target, RCS_target, complexity_target, r, NF, Tx_pulse);
Rx_point_Z = Rx_prep(backscatter, psi_Rx);

% Choose random antenna for noise magnitude plot
antenna_idx = 28;
Backscatter_single = backscatter(antenna_idx, :);
%% Plotting the noise snapshots for antenna 28: 
close all

f1 = figure;
p1 = semilogy(abs(Backscatter_single));
xline(PRI,'black');
xlabel('Sample index');
ylabel('Noise magnitude (Volts)');
title('Noise signal at the 28^{th} antenna for 8 PRIs (dwell time)')
grid on
xlim([0, 11200])
%print(f1, '-vector', '28th antenna - noise', '-dpng')

%% Plotting the noise snapshots at point Z: 
f2 = figure;
p2 = semilogy(abs(Rx_point_Z));
xline(PRI,'black');
xlabel('Sample index');
ylabel('Noise magnitude (Volts)');
title('Noise signal at point Z for 8 PRIs (dwell time)')
grid on
xlim([0, 11200])
%print(f2, '-vector', 'Point Z - noise', '-dpng')

%% Theoretical and Estimated noise pdfs for antenna 28: 
noise_power_est_cmplx = (1/11200)*(Backscatter_single)*transpose(conj((Backscatter_single)));
noise_power_est = real(noise_power_est_cmplx); %Taking real power and discarding reactive power.

f3 = figure;
[N, edges] = histcounts(abs(Backscatter_single), 50, 'Normalization', 'pdf');
x = (edges(1):(edges(end)-edges(1))/100:edges(end));
h3 = histogram(abs(Backscatter_single), 50,'Normalization','pdf');
xlabel('Noise magnitude (Volts)'); 
ylabel('Probability density'); 
title('Noise pdf estimation for the 28^{th} antenna');
hold on;
pdf = raylpdf(x, sqrt(noise_power_est/2)); % Rayleigh distribution 
p3 = plot(x, pdf,'color','r', LineWidth=2);
legend('Estimated pdf','Theoretical pdf');
grid on
grid minor
%print(f3, '-vector', '28th antenna - noise pdf', '-dpng')
hold off;

%% Theoretical and Estimated noise pdfs at point Z: 
noise_power_est_cmplx_Z = (1/11200)*(Rx_point_Z)*transpose(conj((Rx_point_Z)));
noise_power_est_Z = real(noise_power_est_cmplx_Z);

f4 = figure;
[N, edges] = histcounts(abs(Rx_point_Z), 50, 'Normalization', 'pdf');
x = (edges(1):(edges(end)-edges(1))/100:edges(end));
h4 = histogram(abs(Rx_point_Z), 50,'Normalization','pdf');
xlabel('Noise magnitude (Volts)'); 
ylabel('Probability density'); 
title('Noise pdf estimation at point Z');
hold on;
pdf_Z = raylpdf(x, sqrt(noise_power_est_Z/2)); % Rayleigh distribution 
p4 = plot(x, pdf_Z,'color','r', LineWidth=2);
legend('Estimated pdf','Theoretical pdf');
grid on
grid minor
%print(f4, '-vector', 'Point Z - noise pdf', '-dpng')
hold off;

%% This section is for later tasks where we need the threshold value for decision making:

% A threshold .mat file with the value has already been added to the files so its not necessary
% to run again

%threshold = generate_threshold(Rx_point_Z, 0.001);