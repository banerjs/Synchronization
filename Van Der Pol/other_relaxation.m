%%OTHER_RELAXATION.m
% This script simulates the other relaxation oscillators that can be
% considered.

% Set the global variable
global juggler_simulated;
if isempty(juggler_simulated) || juggler_simulated == 0
    clear all; clc;
    c_x = 0;
    c_y = 0.0;
    c_E = 1;
    juggler_simulated = 0;
end

% Set the timing parameters
T = 300; % Set the total time for the simulation
tspan = [0, T]; % Set the span for the simulation

% Set the initial conditions
X = [c_x; c_y]; % State of the equation
E = c_E; % Epsilon

% Define the van der Pol differential equation
osc = @(t,y) ([y(2); -((y(1)^4+4*y(1)^2-1)/(y(1)^4+2*y(1)^2+2))*y(2)-y(1)]);

% or1: [y(2); -((y(1)^4+4*y(1)^2-1)/(y(1)^4+2*y(1)^2+2))*y(2)-y(1)]
% or2: [y(2); -(1.6*y(1)^4-4*y(1)^2+0.8)*y(2)-y(1)]

% Use built in solvers to solve the ODE
[t,states] = ode15s(osc, tspan, X);

% Plot the graphs if not the subordinate
if juggler_simulated == 0
    figure;
    subplot(2,1,1);
    plot(states(:,1), states(:,2));
    title(['Phase Portrait, Epsilon = ', num2str(E)]);
    subplot(2,1,2);
    plot(t, states(:,1));
end