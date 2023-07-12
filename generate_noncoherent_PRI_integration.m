%% Name: Leonidas Tsigkounakis - CID: 01927913
% This function takes as input a 1x11200 input signal for non-coherent PRI
% integration (once for each angle from 30 to 150) as shown in 
% slide 42 of chapter 5 from the lectures.
function [coherent] = generate_noncoherent_PRI_integration(input)
    magnitudes = abs(input);
    vertical = [];
    for i = 0:7
        vertical = vertcat(vertical, magnitudes(1, (1+i*1400):(1400+i*1400)));
    end
    coherent = mean(vertical, 1);
end