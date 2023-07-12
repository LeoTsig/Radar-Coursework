%% Name: Leonidas Tsigkounakis - CID: 01927913
% This function provides the 45x1 complex exponential phase-shifter vectors for the steering of the main lobe
% during Tx and Rx. Weights are assumed to be 1 as per the instructions so
% they are omitted.
function [psi_steer_Tx, psi_steer_Rx] = psi_steer(theta_steer_deg, r, wavelengthc)
    phi_steer = 0;
    k = 2*pi/wavelengthc;
    u_main = transpose([cosd(theta_steer_deg)*cosd(phi_steer), sind(theta_steer_deg)*cosd(phi_steer), sind(phi_steer)]);
    k_vec_main = k*u_main;
    
    psi_steer_Rx = exp(1i*transpose(r)*k_vec_main); % 45x3 x 3x1 => 45x1
    psi_steer_Tx = conj(psi_steer_Rx);
end