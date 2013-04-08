%%VANDERPOL_PHASE_GAME.m
% This simulation tries to synchronize 2 van der pol oscillators based on
% phase difference between the two.

clear all; clc;

% Set the timing parameters
T = 300; % Set the total time for the simulation
dT = 0.1; % Timestep value
tspan = [0, T]; % Set the span for the simulation

% Set initial conditions
INIT_POS = rand(2,1); % Pick random initial conditions
E = 1; % Epsilon
delaytime = 10; % Initial phase difference 
simtime = 20; % Time to simulate for before checking
NUM_TRIES = 50; % Number of oscillators to spawn off

% Define the van der Pol differential equation
fvdp = @(t,y) ([y(2); E*(1-y(1)^2)*y(2)-y(1)]);

% Create the first independent oscillator
[t, s] = ode15s(fvdp, tspan, INIT_POS);
states = interp1(t, s, tspan(1):dT:tspan(2), 'spline'); % Interpolated states

% Do the simulation
dcount = 0; % Check timestep to start delayed transaction
diter = 0; % Number of simulators that have started counting
scount = zeros(NUM_TRIES,1); % Simulation time of all the followers

mdist = inf;
midx = 0;

for i = 1:size(states,1)
    if mod(i,10) == 0
        plot(states(1:i,1), states(1:i,2), 'k', states(i,1), states(i,2), 'ro');
        axis([-3 3 -3 3]);
        hold on;
        for j = 1:diter-1
            if midx > 0 && j == midx
                plot(states(ceil(scount(j)/dT)+1,1), states(ceil(scount(j)/dT)+1,2), 'go');
                hold on;
            else
                plot(states(ceil(scount(j)/dT)+1,1), states(ceil(scount(j)/dT)+1,2), 'b^');
                hold on;
            end
        end
        hold off;
        title(['Minimum at ', num2str(midx)]);
        drawnow; pause(0.1);
    end
    if dcount >= delaytime && diter < NUM_TRIES % Start a new simulator if available
        diter = diter + 1; % Increase the number of simulators that have started
        dcount = 0;
    end
    
    if any(ceil(scount) == simtime)
        if norm(states(simtime/dT+1,:) - states(i,:)) < mdist
            mdist = norm(states(simtime/dT+1,:) - states(i,:));
            midx = find(ceil(scount) == simtime);
        end
    end
    
    dcount = dcount+dT;
    scount(1:diter) = scount(1:diter) + dT;
end