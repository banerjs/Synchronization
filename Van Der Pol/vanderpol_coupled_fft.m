%%VANDERPOL_COUPLED_FFT.m
% This script tests the power spectrum of coupled van der Pol oscillators

clear all; clc;

% Set the global variable
global juggler_simulated;
juggler_simulated = 1;

% Set initial positions of both oscillators
c_X1 = [0.1; -0.1];
c_X2 = [0.1; 0.1];

% Vary the epsilons of both oscillators
e1limit = 0;
e2limit = 0;
e1 = 1; %10.^(-e1limit:1:e1limit);
e2 = 10; %10.^(-e2limit:1:e2limit);

% Vary the delta
dlimit = -0.3;
d = -10; %0:-0.1:dlimit;

% For loop for the simulation
for i = 1:size(e1,2)
    for j = 1:size(e2,2)
        for k = 1:size(d,2)
            c_E1 = e1(i); c_E2 = e2(j);
            c_delta = d(k);
            coupled_vanderpol;            
            
            % Plot the functions
            figure;
            subplot(2,3,1);
            plot(states1(:,1), states1(:,2));
            title(['Phase Portrait, Epsilon = ', num2str(c_E1)], 'FontSize', 17);
            subplot(2,3,2);
            plot(t, states1(:,1), t, states2(:,1), 'k');
            title(['Delta = ', num2str(c_delta)], 'FontSize', 17);
            xlabel('Time(t)', 'FontSize', 14);
            ylabel('Position(x1,x2)', 'FontSize', 14);
            xlim([0 100]);
            subplot(2,3,4);
            plot(states2(:,1), states2(:,2), 'k');
            title(['Phase Portrait, Epsilon = ', num2str(c_E2)], 'FontSize', 17);
            subplot(2,3,5);
            plot(states1(:,1), states2(:,1), 'r');
            title('Combined Phase portrait', 'FontSize', 17);
            xlabel('Position(x1)', 'FontSize', 14);
            ylabel('Position(x2)', 'FontSize', 14);
            
            % Perform the FFT and show the results
            [~, power1, ~] = FFTVanDerPol(tspan, t, states1);
            [farr, power2, n] = FFTVanDerPol(tspan, t, states2);
            
            subplot(2,3,3);
            plot(farr(1:n/2)*2*pi, power1(1:n/2));
            xlim([0 5]);
            title(['Power Spectrum, Epsilon = ' num2str(c_E1)], 'FontSize', 17);
            xlabel('Frequency (Rad/s)', 'FontSize', 14);
            ylabel('Power', 'FontSize', 14);
            subplot(2,3,6);
            plot(farr(1:n/2)*2*pi, power2(1:n/2), 'k');
            xlim([0 5]);
            title(['Power Spectrum, Epsilon = ', num2str(c_E2)], 'FontSize', 17);
            xlabel('Frequency (Rad/s)', 'FontSize', 14);
            ylabel('Power', 'FontSize', 14);
            
            disp(strcat('Oscillator 1: ', num2str([farr(power1 > 1000)*2*pi; power1(power1 > 1000)'])));
            disp(strcat('Oscillator 2: ', num2str([farr(power2 > 1000)*2*pi; power2(power2 > 1000)'])));
        end
    end
end
% endfor