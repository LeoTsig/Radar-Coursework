%% Name: Leonidas Tsigkounakis - CID: 01927913
% This function takes as input the received signal (1x11200) at point z and
% performs mathced filtering with the pulse compression sequence.
function [MF_output] = generate_MF(Rx_signal)
    copmression_flipped = [-1, -1, +1, +1, -1, -1, -1];
    MF_output = (1/7)*conv(Rx_signal, copmression_flipped);
    MF_output = MF_output(1:end-6);
end