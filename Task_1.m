%% Name: Leonidas Tsigkounakis - CID: 01927913
clear all
clc
close all
%% Parameter definitions (Units in S.I.):
% Carrier frequency and wavelength (free space)
fc = 0.5*(12+18)*1e9; % Middle of Ku band
c_light = 3*1e8;
wavelengthc = c_light/fc;

% Uniform Linear Array (ULA)
r = generate_ULA(wavelengthc);

% Manifold vector given steering direction
theta_main = 40; % Steer azimuth angle (This is what we change to get the different pattern plots)
phi_main = 0;
k = 2*pi/wavelengthc;
u_main = transpose([cosd(theta_main)*cosd(phi_main), sind(theta_main)*cosd(phi_main), sind(phi_main)]);
k_vec_main = k*u_main;

S_Tx_main = exp(+1i.*transpose(r)*k_vec_main); % Tx manifold vector
S_Rx_main = conj(S_Tx_main); % Rx manifold vector (eq. applies for monsotatic)

[psi_Tx, psi_Rx] = psi_steer(theta_main, r, wavelengthc);
angles_Rx = -1*angle(S_Rx_main)*180/pi;
angles_Rx(abs(angles_Rx) < 1e-10) = 0;
angles_Tx = -angles_Rx;

% Array Pattern
S_pattern = [];
phi = 0;
for theta_pattern = (1:0.2:360) % from 1 to 360 with 0.2 step
    u_pattern = transpose([cosd(theta_pattern)*cosd(phi), sind(theta_pattern)*cosd(phi), sind(phi)]);
    S_pattern = [S_pattern, exp(-1i.*transpose(r)*(k*u_pattern))];
end
S_Rx_main_hermitian = transpose(conj(S_Rx_main));
g = abs(S_Rx_main_hermitian*S_pattern); % Array Pattern in polar co-ordinates

%% Plotting the Polar Patterns for each steering angle:
theta_polar = (1:0.2:360)*pi/180;
f1 = figure();
p1 = polarplot(theta_polar, g, LineWidth=1);
title(['ULA pattern for ', num2str(theta_main),  ' degrees (azimuth)'])
thetaticks(0:10:360)
%print(f1, '-vector', [num2str(theta_main), 'deg'], '-dpng')

f2 = figure();
p2 = plot(theta_polar*180/pi, g);
xlim([0,180]);
xlabel('Azimuth angle (deg)')
ylabel('Array gain')
title(['ULA gain for ', num2str(theta_main), ' degrees (azimuth)'])
grid on
grid minor
%print(f2, '-vector', [num2str(theta_main), 'deg - linear'], '-dpng')