%% Name: Leonidas Tsigkounakis - CID: 01927913
% This function generates the Uniform Linear Array (ULA)
function ULA = generate_ULA(wavelengthc)
    d =  wavelengthc/2;
    N_arr = 45;
    rx = [];
    for i = 1:N_arr
        rx = [rx, (i-23)*d];
    end
    ry = transpose(zeros(N_arr, 1));
    rz = ry;
    ULA = vertcat(rx, ry, rz); % Array orientation matrix (cartesian)
end
