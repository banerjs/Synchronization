%%VANDERPOL_PHASE_GAME.m
% This simulation tries to synchronize 2 van der pol oscillators based on
% phase difference between the two.

clear all; clc;

% Set the timing parameters
T = 2000; % Set the total time for the simulation
dT = 0.1; % Timestep value
tspan = [0, T]; % Set the span for the simulation

% Set initial conditions
INIT_POS = rand(2,1); % Pick random initial conditions
E = 1; % Epsilon
tdelay = 100; % Initial phase difference

% Define the van der Pol differential equation
fvdp = @(t,y) ([y(2); E*(1-y(1)^2)*y(2)-y(1)]);

% Create the first independent oscillator
[t, s] = ode15s(fvdp, tspan, INIT_POS);
states1 = interp1(t, s, tspan(1):dT:tspan(2), 'spline'); % Interpolated states

% Do the simulation
t2span = tspan + [tdelay, 0];
[t, s] = ode15s(fvdp, t2span, INIT_POS);
states2 = interp1(t, s, t2span(1):dT:t2span(2), 'spline');
counter = 1; % Counter to calculate phase delay
for i = 1:size(tspan(1):dT:tspan(2),2)
    if counter == tdelay % Time to check the phase difference
        ahead = find(states2(counter,:) == states1(tdelay:end, :),1,'first');
        
    end
    counter = counter + 1;
end