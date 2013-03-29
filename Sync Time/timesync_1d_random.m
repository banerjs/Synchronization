%%TIMESYNC_1D_RANDOM.m
% This script runs the time synchronization problem. There are 2 basic
% behaviors of this program - 1) There is no fixed time-keeper and 2) There
% is a fixed time-keeper. The 2 behaviours are triggered based on the
% variable TIME_KEEPER

clear all; clc;

%% Definitions of parameters
TIME_KEEPER = 1; % 0->there is no time-keeper. 1->there are time-keepers
NUM_KEEPERS = 100; % The number of time-keepers in the simulation
DISCRETE_TIME = 0; % Parameter for if time is discretized

POPULATION = 1000;  % Number of people
CORRECT_TIME = 20;  % Correct time of the simulation
DEVIATION_TIME = 5; % Std. Dev. of time in population
NORMAL_DISTRIBUTION = 1; % Choose if normal distribution of noise

CHANGE_FUNC = {@(x,y) ([mean([x,y]), mean([x,y])]); % Normal interact
               @(time,y) ([time, time]);            % Timer interact
               @(x,y) (round(mean([x,y])*[1,1]))};  % Discretized interact
               
SIMULATION_TIME = 100; % Number of timesteps to be simulated for

%% Definition of simulation behavior
THRESHOLD_DEVIATION = 0.01;
BREAK_ON_DEVIATION = 1;
SHOW_SIMULATION = 1;
SHOW_RESULTS = 1;

%% Creation of variables
if NORMAL_DISTRIBUTION == 1
    people = CORRECT_TIME + DEVIATION_TIME.*randn(1,POPULATION); % Times of
                                                                 % people
else
    people = (rand(1,POPULATION).*2.*DEVIATION_TIME) + (CORRECT_TIME-DEVIATION_TIME);
end

if TIME_KEEPER == 1
    keeper = zeros(1,NUM_KEEPERS);
    for i = 1:NUM_KEEPERS
        keeper(i) = randi(POPULATION);
        people(keeper(i)) = CORRECT_TIME; % Make person 1 the time-keeper
    end
end

ymax = 25;%max(people); % MAX and MIN for the axes
ymin = 15;%min(people);

%% Simulation of setup
for i = 1:SIMULATION_TIME
    if BREAK_ON_DEVIATION == 1 && std(people) < THRESHOLD_DEVIATION
        break;
    end
    
    if SHOW_SIMULATION == 1
        plot(1:POPULATION, people, 1:POPULATION, CORRECT_TIME);
        axis([0, POPULATION, ymin, ymax]);
        drawnow; pause(0.1);
    end
    
    num_interact = randi(floor(POPULATION/2)); % Number of interactions
    
    for j = 1:num_interact                     % Simulate interations
        meeters = sort(randi(POPULATION,1,2)); % Select "meeters"
        if TIME_KEEPER == 1
            if any(meeters(1) == keeper)
                new_times = CHANGE_FUNC{2}(people(meeters(1)), people(meeters(2)));
            elseif any(meeters(2) == keeper)
                new_times = CHANGE_FUNC{2}(people(meeters(2)), people(meeters(1)));
            else
                if DISCRETE_TIME == 1
                    new_times = CHANGE_FUNC{3}(people(meeters(1)), people(meeters(2)));
                else
                    new_times = CHANGE_FUNC{1}(people(meeters(1)), people(meeters(2)));
                end
            end
        else
            if DISCRETE_TIME == 1
                new_times = CHANGE_FUNC{3}(people(meeters(1)), people(meeters(2)));
            else
                new_times = CHANGE_FUNC{1}(people(meeters(1)), people(meeters(2)));
            end
        end
        people(meeters(1)) = new_times(1);
        people(meeters(2)) = new_times(2);
    end
end
% endfor

if SHOW_RESULTS == 1
    plot(1:POPULATION, people, 1:POPULATION, CORRECT_TIME);
    axis([0, POPULATION, ymin, ymax]);
    title(['Population Time Range = [', num2str(min(people)), ' , ', num2str(max(people)), ']']);
    text(POPULATION/2,ymax-0.5,strcat('Number of simulation steps = ', num2str(i)));
end