function vCode = fctCA(iPRN)
    %% Generate the 1023 chips C/A Gold code sequence for PRNs 1-32.
    %% PRN - Code Phase Selection Mapping
    mPSnum = [ ...
         2 6;  3 7;  4 8;  5 9;  1 9;  2 10; 1 8;  2 9;  ...
         3 10; 2 3;  3 4;  5 6;  6 7;  7 8;  8 9;  9 10; ...
         1 4;  2 5;  3 6;  4 7;  5 8;  6 9;  1 3;  4 6;  ...
         5 7;  6 8;  7 9;  8 10; 1 6;  2 7;  3 8;  4 9];
        
    %%
    vG1 = ones(1,10); % G1 Register
    vG2 = ones(1,10); % G2 Register
    vCode = zeros(1, 1023); % Output C/A code

    for i = 1:1023
        dG2PS = xor(vG2(mPSnum(iPRN, 1)), vG2(mPSnum(iPRN, 2))); % Phase Selector
        vCode(i) = xor(vG1(end), dG2PS);

        dG1fb = xor(vG1(3), vG1(10)); % G1 Register Feeback 
        dG2fb = mod(sum(vG2([2 3 6 8 9 10]), 2), 2); % G2 Register Feedback
        vG1 = [dG1fb, vG1(1 : end-1)]; % Shift G1 Register
        vG2 = [dG2fb, vG2(1 : end-1)]; % Shift G2 Register
    end
    vCode = (2 * double(vCode) - 1)';
end