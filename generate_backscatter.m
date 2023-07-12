%% Name: Leonidas Tsigkounakis - CID: 01927913
% This function refers to Task 2 of the coursework.
function [output_baseband] = generate_backscatter( ...
    clk_period, wavelengthc, ...       % Clock period = Tc and wavelength λc.
    theta_deg, R, RCS, complexity, ... % Collumn vectors for each target parameter as shown on table 2 of the coursework specifications
    r, ...                         % Antenna array geometry (cartesian co-ordinates)
    NF, ...                        % Noise Factor for path defined by the antennas until the baseband ports.
    input)                         % Input signal -> 45x11200 matrix generated by the Tx_prep function.                        

    % Carrier Parameters
    c_light = 3*1e8;
    fc = c_light/wavelengthc;

    % Number of targets
    M = length(theta_deg);

    % Gain Parameters - Each element in the antenna array is isotropic.
    GTx = 1;
    GRx = 1;

    % Noise Parameters
    k_boltzman = 1.28*1e-23;
    To = 290;
    B = 1/clk_period;

    % Output Definition
    clean_sig = zeros(size(input));

    for i = 1:M
        % Manifolds
        [psi_tx, psi_rx] = psi_steer(theta_deg(i, 1), r, wavelengthc); % complex exponentials exp(-+jψ)
        S_Tx = psi_rx;
        S_Rx = psi_tx;
        
        % Intermediate signal:
        input_intermediate = transpose(conj(S_Tx))*input;

        % Implementation of delay due to convolution with δ(t-techo)
        techo = 2*R(i, 1)/c_light;
        delay= ceil(techo/clk_period); % convertion from time delay to sample dealy
        input_delayed = [zeros(1,delay),input_intermediate(1:end-delay)];

        % A = sqrt(RCS) models 
        if complexity(i, 1) == 0        % Constant RCS
            A = ones(1, 1400*8);

        elseif complexity(i, 1) == 1    % Class 1
            A = repelem(fSwerling12rnd(RCS(i, 1), 8, 'Amplitude'), 1400); % Every pulse out of the 8 sent does not see the same RCS.

        elseif complexity(i, 1) == 2    % Class 2
            A = repelem(fSwerling34rnd(RCS(i, 1), 8, 'Amplitude'), 1400);
        end
        
        % Random Phase Component ψ ~ U(0, 2π)
        psi_rand = repelem((2*pi*rand(1,8)), 1400);
        
        % Evaluation of β (complex)
        b_complex= sqrt((GTx*GRx)/(4*pi)^3) *(wavelengthc/(R(i, 1)^2)).*A.*exp(-1i*2*pi*fc*(2*R(i, 1)/c_light)).*exp(1i*psi_rand);

        % Output Before Noise 
        clean_sig = clean_sig + b_complex.*(S_Rx*input_delayed); % The output has size 45x11200
    end

    % AWGN matrix definition:
    noise_power = k_boltzman*To*NF*B;
    AWGN = sqrt(noise_power/2)*(randn(size(input)) + 1i*randn(size(input))); % AWGN amtrix 45x11200

    % Output at Baseband Port
    if M == 0
        output = AWGN;
    else
        output = clean_sig + AWGN;
    end
    for col = 0:7
        output(1:45,(1+col*1400):(7+col*1400)) = 0;
    end
    output_baseband = output;

end