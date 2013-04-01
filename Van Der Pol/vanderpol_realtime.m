%%VANDERPOL_REALTIME.m
% This is the simulation for the Van der Pol in real time

% Set the timing parameters
T = 300; % Set the total time for the simulation
dT = 0.1; % Timestep value
tspan = [0, T]; % Set the span for the simulation

% Set the initial conditions
NUM_PARTICLES = 10; % Number of particles
VARIATION = 5; % Variation in the initial states between particles
MEAN_POS = 3; % Mean position
E = 1; % Epsilon
init_states = MEAN_POS + VARIATION.*rand(2,NUM_PARTICLES);
times = cell(1,NUM_PARTICLES);
states = cell(1,NUM_PARTICLES);


% Show simulation parameters
FRAME_DIVIDE = 1; % Number of frames to skip
CM = winter(NUM_PARTICLES);
Time = tspan(1):dT:tspan(2); % Interpolated time vector
States = cell(1,NUM_PARTICLES); % Interpolated states

% Define the van der Pol differential equation
fvdp = @(t,y) ([y(2); E*(1-y(1)^2)*y(2)-y(1)]);

% Get the states of the van der pol oscillator
for i = 1:NUM_PARTICLES
    X = init_states(:,i);
    [times{i},states{i}] = ode15s(fvdp, tspan, X);
    States{i} = interp1(times{i}, states{i}, Time, 'spline');
end

for i = 1:size(Time,2)
    if mod(i-1,FRAME_DIVIDE) == 0 % If the frame is to be shown
        for j = 1:NUM_PARTICLES
            plot(States{j}(1:i,1), States{j}(1:i,2), 'color', CM(j,:));
            axis([-10 10 -10 10]);
            hold on;
        end
        for j = 1:NUM_PARTICLES
            plot(States{j}(i,1), States{j}(i,2),'r.');
            hold on
        end
        hold off;
        drawnow; pause(0.1);
    end
end