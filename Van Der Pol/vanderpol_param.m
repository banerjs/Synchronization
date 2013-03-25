% This is a wrapper around the Van der Pol simulation and sets the
% parameters

clear all; clc;

% Set the global variable
global juggler_simulated;
juggler_simulated = 1;

% Setup the simulation parameters
xlim = 0.1; % Set the limit (amplitude for X(1))
ylim = -0.1; % Set the limit (amplitude for X(2))
x = xlim:2*xlim:xlim; % Create the limits of X(1) initial states
y = ylim:1:ylim; % Create the limits of X(2) initial states
enum = 0; % Set the orders of magnitude of E's
e = 10.^(-enum:1:enum); % Create the values of E

% This is a test of the unforced oscillations
c_amp = 200;
c_freq = 1;

% For loop for the simulation
for k = 1:size(e,2)
    for i = 1:size(x,2)
        for j = 1:size(y,2)
            c_x = x(i); c_y = y(j); c_E = e(k);
            perform_vanderpol;
            figure;
            subplot(2,1,1);
            plot(states(:,1), states(:,2));
            title(['Amplitude = ', num2str(c_amp)]);
            subplot(2,1,2);
            plot(t, states(:,1), t, c_amp.*sin(c_freq*t));
        end
    end
    reply = input('Do you want more [0/1]: ');
    if reply == 0
        break;
    end
end
% endfor

% Print the figure
% export_fig(sprintf('plots\\vanderpol\\fig_Xcu-X.png'), '-m3');