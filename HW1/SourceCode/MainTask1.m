%% Task 1
fprintf("---------- Task1 ----------  \n")
%%
addpath("function")
vCode1 = fctCA(1); vCode2 = fctCA(2);
vSampledCode1 = fctSampledCA(1); 
vSampledCode2 = fctSampledCA(2);
% 4) Plot ACF of C/A code PRN#1
sACF1 = fctACF(vCode1); 
% 5) Plot CCF of C/A code PRN#1 & PRN#2
sCCF1 = fctCCF(vCode1, vCode2);
% 6) Plot ACF of Sampled C/A code PRN#1
sACF2 = fctACF(vSampledCode1'); 
% 7) Plot CCF of SAmpled C/A code PRN#1 & PRN#2
sCCF2 = fctCCF(vSampledCode1, vSampledCode2);
%% Plot
figure;
subplot(1,2,1);
stem(sACF1.vLag, sACF1.vACF, 'Marker', 'none', 'LineWidth', 1.0,  'Color', 'b');
xlabel('Chips'); ylabel('Auto-Correlation')
grid on;
%title('Auto-Correlation function of C/A code PRN#1')
subplot(1,2,2);
stem(sCCF1.vLag, sCCF1.vCCF, 'Marker', 'none', 'LineWidth', 1.0, 'Color', 'b');
ylim([-1 1]);
xlabel('Chips'); ylabel('Cross-Correlation')
grid on;
%title('Cross-Correlation Function of C/A code PRN#1 & PRN#2')

figure;
subplot(1,2,1);
stem(sACF2.vLag, sACF2.vACF, 'Marker', 'none', 'LineWidth', 1.0, 'Color', 'b');
grid on;
xlabel('Chips'); ylabel('Auto-Correlation')
%title('Auto-Correlation function of Sampled C/A code PRN#1')
subplot(1,2,2);
stem(sCCF2.vLag, sCCF2.vCCF, 'Marker', 'none', 'LineWidth', 1.0, 'Color', 'b');
ylim([-1 1]);
grid on;
xlabel('Chips'); ylabel('Cross-Correlation')
%title('Cross-Correlation Function of Sampled C/A code PRN#1 & PRN#2')

%%
fprintf("===== Task1: Complete ===== \n\n")