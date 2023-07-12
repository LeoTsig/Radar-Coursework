%% Name: Leonidas Tsigkounakis - CID: 01927913
% This function prepares the signal at point A (Baseband Signal Generator)
% for transmission. We do not model the carrier. The output Sig_Tx_ready
% is designed to be fed into the backscatterer function.

function Sig_Tx_ready = Tx_prep(pulse_train, psi_steer_Tx)
    % pulse train has dimensions 1x11200 where each PRI is 1400 samples.
    Sig_Tx_ready = conj(psi_steer_Tx)*pulse_train;
end