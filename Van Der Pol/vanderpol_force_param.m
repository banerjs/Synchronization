% This is a wrapper around the forced Van der Pol simulation and sets the
% parameters for the forcing function

clear all; clc;

% Set the global variable
global juggler_simulated;
juggler_simulated = 1;

% Parameters for the oscillator
enum = 0; % Set the orders of magnitude of E's
e = 10.^(-enum:1:enum); % Create the values of E
c_x = 0.1;
c_y = -0.1;

% Parameters for forcing
c_amp = 2; % Paper says that low voltages are needed
flimit = 5; % Set the limit of frequencies that are used
f = 0.2:0.2:flimit; % Create the range of frequencies to test

% For loop for the simulation
for k = 1:size(e,2)
    for i = 1:size(f,2)
        c_freq = f(i); c_E = e(k);
        perform_vanderpol;
        figure;
        subplot(2,1,1);
        plot(states(:,1), states(:,2));
        title(['epsilon = ', num2str(c_E), ', freq = ', num2str(c_freq)]);
        subplot(2,1,2);
        plot(t, states(:,1), t, c_amp*sin(c_freq*t));
    end
    reply = input('Do you want more [0/1]: ');
    if reply == 0
        break;
    end
end
% endfor
