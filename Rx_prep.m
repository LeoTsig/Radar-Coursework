%% Name: Leonidas Tsigkounakis - CID: 01927913
% This function prepares the backscattered signal (45x11200) at at the
% baseband port and converts it into as 1x11200 signal for reception (point Z). 
% We do not model carrier demodulation. The output Sig_Rx_ready
% is designed to be fed into Baseband Processing unit.
function Sig_Rx_ready = Rx_prep(backscatter, psi_steer_Rx)
    % backscatter has dimensions 45x11200.
    Sig_Rx_ready = (transpose(psi_steer_Rx))*backscatter;
end