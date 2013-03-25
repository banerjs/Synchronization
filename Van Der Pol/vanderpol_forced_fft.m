%%VANDERPOL_FORCED_FFT.m
% This program performs a frequency analysis of the forced van der Pol
% oscillator

clear all; clc;

% Set the global variable 
global juggler_simulated;
juggler_simulated = 1;

% Parameters for the oscillator
c_E = 1; % Keep E constant. We need to check the variance on A and f
c_x = 0.1;
c_y = -0.1;

% Parameters for forcing
c_amp = 10; % Use constant amplitudes for now
flimit = 3; % Set the limit of frequencies that are used
f = 3:0.5:flimit; % Create the range of frequencies to test

% Set FFT Constants
THRESHOLD = 300;

% For loop for the simulation
for i = 1:size(f,2)
    c_freq = f(i);
    perform_vanderpol;
    [farr, power, n] = FFTVanDerPol(tspan, t, states);
    
    figure;
    subplot(2,2,1);
    plot(states(:,1), states(:,2));
    %title('Unforced Oscillator', 'FontSize', 20);
    title(['amplitude = ', num2str(c_amp), ', freq = ', num2str(c_freq)], 'FontSize', 20);
    xlabel('Position(x)', 'FontSize', 16);
    ylabel('Velocity(dx/dt)', 'FontSize', 16);
    subplot(2,2,3);
    plot(t, states(:,1));%, t, c_amp*sin(c_freq*t));
    xlabel('Time(t)', 'FontSize', 16);
    ylabel('Position(x)', 'FontSize', 16);
    xlim([0 100]);
    subplot(1,2,2);
    plot(farr(1:floor(n/2))*2*pi, power(1:floor(n/2)));
    xlim([0 5]);
    title('Power Spectrum', 'FontSize', 20);
    xlabel('Frequency (Rad/s)', 'FontSize', 16);
    ylabel('Power', 'FontSize', 16);
    
    farr = farr(power > THRESHOLD)*2*pi;
    power = power(power > THRESHOLD)';
    disp(strcat('A = ', num2str(c_amp), ', f = ', num2str(f(i)), ': ', ...
                num2str([farr(1:end/2); power(1:end/2)])));
end
% endfor
