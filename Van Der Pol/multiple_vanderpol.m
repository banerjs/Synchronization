%%MULTIPLE_VANDERPOL.m
% This script simulates mutliple van der Pol oscillators that are connected
% via some adjacency matrix.

clear all; clc;

%% Setup the simulator
% Set the timing parameters and Number of Oscillators
N = 9;
T = 300;
tspan = [0 T];

% Generate Initial Conditions for the Oscillators
i_start = -2; % Minimum limit for the initial conditions
i_end = 2; % Maximum limit for the initial conditions

% Create the states for the oscillator. 1st N vars are position, next N are
% the velocities
X = i_start + (i_end-i_start).*rand(2*N,1);
E = rand(N,1); % 10.^linspace(0,log(N),N)'% Create a vector of E's

% Create the adjacency matrix
delta = -10;
temp = ones(N)./(N-1); %rand(N);
A = eye(N) - (temp-(diag(diag(temp))));

% Create the forcing function for the oscillators
amp = 2;   % Assume a forcing of Asin(wt)
freq = 1;  % Set the frequency to some value

%% Run the simulator
% Define the ODE
mvdp = @(t,y) MultipleVanDerPol(t,y,E,A,delta,N);

% Solve the ODE using built-in MATLAB ODE solvers
[t,states] = ode15s(mvdp,tspan,X);

%% Display the results of the simulator
h1 = figure;
h2 = figure;
for i = 1:N
    figure(h1);
    subplot(3,3,i);
    plot(states(:,i),states(:,N+i));
    %axis([-3 3 -3 3]);
    title(['Starting Pos = ', num2str(X(i)), ',', num2str(X(N+i))]);
    figure(h2);
    subplot(3,3,i);
    plot(t,states(:,i));
    axis([0 T/5 -3 3]);
    title(['Epsilon = ', num2str(E(i))]);
end