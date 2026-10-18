function vSampledCode = fctSampledCA(iPRN, dTs)
    %% Generate Sampled C/A code Sequence
    %% Sampling Interval of ADC (Given)
    if nargin < 2
        dTs = 1 / 5.714e6; % [sec]
    end
    vCode = fctCA(iPRN);
    %% Sampling Parameter
    dTc = 1e-3 / length(vCode) ; % Chip duration; 1 ms / 1023
    dNsc = dTc / dTs; % Number of Chip per Sample
    
    %% 한 Chip 당 Sampling 되는 수 계산
    % 1) 0:1:1023 vector 생성
    % 2) component마다 dNsc만큼 곱
    % 3) ceil: 요소별 정수 올림
    % 4) 앞뒤 요소간 차 => vNsc
    vNsc = diff(ceil((0 : length(vCode)) * dNsc)); 

    %% Sampling (Repeat the C/A code with dNsc)
    vSampledCode = repelem(vCode, vNsc, 1);
    vSampledCode = vSampledCode';
end