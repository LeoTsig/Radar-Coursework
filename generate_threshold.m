%% Name: Leonidas Tsigkounakis - CID: 01927913
% This function takes as input the estimated pdf of the noise signal  (1x11200). 
% Given a probabiltiy of false alarm in the specification sheet we
% can estimate the voltage threshold fro target detection (Newman-Pearson
% method).
function [threshold] = generate_threshold(noise_signal, P_FA)
    
    % Define noise power estimate to then use for pdf estimation
    noise_power_est_cmplx_Z = (1/11200)*(noise_signal)*transpose(conj((noise_signal)));
    noise_power_est = real(noise_power_est_cmplx_Z);

    % Noise magnitude signal:
    noise = abs(noise_signal);
    
    % we use histcounts in order to extract the x-axis for the pdf.
    [N,edges]= histcounts(noise,'Normalization','pdf');
    voltage_range= min(noise):(edges(2)-edges(1)):max(noise);
    pdf = raylpdf(noise, sqrt(noise_power_est/2));

    % The detection threshold is found by integrating the pdf until the
    % probability reaches 0.999 i.e. 1 - P_FA, where P_FA is 0.001
    threshold_idx = find(cumtrapz(pdf)*(edges(2)-edges(1)) < (1-P_FA));
    threshold = voltage_range(threshold_idx(end));
    end