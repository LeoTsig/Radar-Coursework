%% Name: Leonidas Tsigkounakis - CID: 01927913
% This function generates the coded pulse train (8PRI (1 dwell) - 1x11200) signal at point A.
function pulse_train = generate_pulse_train()
    % Input Pulse Train (8 PRI)
    A = 150;
    Tx_on = [-1, -1, -1, +1, +1, -1, +1].*A;
    Rx_on = zeros([1, 1400-7]);
    pulse_dwell = cat(2, Tx_on, Rx_on);
    for i = 1:3
        pulse_dwell = cat(2, pulse_dwell, pulse_dwell); % 1x11200
    end
    pulse_train = pulse_dwell;
end
