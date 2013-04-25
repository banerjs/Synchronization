%%TIMESYNC_2D_RAND_NEIGHBOURS.m
% The number of neighbours is randomized based on location.

clear all; clc;

%% Set simulation parameters
POPULATION = 100; % Number of people in the simulation
FIELD = 100; % Set a field for POPULATION people
RADIUS = 10; % Number of surrounding people to consider

DISCRETE_TIME = 1; % Parameter for if time is discretized
CORRECT_TIME = 20; % Correct time for the population
DEVIATION_TIME = 5; % Std. Dev. of time in population
NORMAL_DISTRIBUTION = 1; % Choose if normal distribution of noise

BREAK_ON_DEVIATION = 1;
THRESHOLD_DEVIATION = 0.01;
SHOW_SIMULATION = 1;
SHOW_RESULTS = 1;

SIMULATION_TIME = 100; % Number of timesteps to simulate

%% Create simulation variables
if NORMAL_DISTRIBUTION == 1
    times = CORRECT_TIME + DEVIATION_TIME.*randn(1,POPULATION); % Times of people
else
    times = (rand(1,POPULATION).*2.*DEVIATION_TIME) + (CORRECT_TIME-DEVIATION_TIME);
end
if DISCRETE_TIME == 1 % Discretize time if required
    times = round(times);
end

%% Perform the simulation
positions = round(rand(2,POPULATION).*FIELD); % Generate the positions of people
otimes = times + 1; % Init in order to get at least 1 iteration

for i = 1:SIMULATION_TIME
    if all(BREAK_ON_DEVIATION == 1 & otimes == times)
       break;
   end
%     if BREAK_ON_DEVIATION == 1 && std(times) < THRESHOLD_DEVIATION
%         break;
%     end
    
    if SHOW_SIMULATION == 1
        subplot(2,1,1);
        plot(1:POPULATION, times, 1:POPULATION, CORRECT_TIME);
        ylim([CORRECT_TIME-DEVIATION_TIME, CORRECT_TIME+DEVIATION_TIME]);
        subplot(2,1,2);
        plot(positions(1,:), positions(2,:), 'o');
        axis([0 FIELD 0 FIELD]);
        drawnow; pause(0.1);
    end
    
    otimes = times;
    
    % Check for neighbours and update time
    for j = 1:POPULATION
        x = positions(1,j); y = positions(2,j);
        neighbours = otimes((abs(x-positions(1,:)) < RADIUS) & (abs(y-positions(2,:)) < RADIUS));

        % Update the time at location
        times(j) = mean(neighbours);
        if DISCRETE_TIME == 1 % Discretize time if required
            times = round(times);
        end
    end
    
    % Shuffle people around
    positions = round(rand(2,POPULATION).*FIELD); % Generate the positions of people
end