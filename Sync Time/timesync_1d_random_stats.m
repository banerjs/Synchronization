%%TIMESYNC_1D_STATS.m
% This script collects statistics for the behavior of the timesync_1d
% script. Essentially, this script plots graphs of timesync_1d simulations

clear all; clc;

%% Definitions of parameters for the timesync_1d simulation
TIME_KEEPER = 0; % 0->there is no time-keeper. 1->there are time-keepers
MAX_NUM_KEEPERS = 100; % Number of time-keepers that are present in the simulation
DISCRETE_TIME = 0; % Parameter for if time is discretized

MAX_POPULATION = 500;  % Number of people
CORRECT_TIME = 20;  % Correct time of the simulation
DEVIATION_TIME = 5; % Std. Dev. of time in population
NORMAL_DISTRIBUTION = 1; % Decide if noise is randomly distributed

CHANGE_FUNC = {@(x,y) ([mean([x,y]), mean([x,y])]); % Normal interaction
               @(time,y) ([time, time]);           % Timer interaction
               @(x,y) (round(mean([x,y])*[1,1]))};  % Discretized interact


SIMULATION_TIME = 100; % Number of timesteps to be simulated for

%% Definition of simulation behavior
THRESHOLD_DEVIATION = 0.01; % Break if the std. dev. is below this threshold
NUM_TRIALS = 50; % Number of trials to run per simulation
POPULATION = MAX_POPULATION; % Set the constant variable
tests = 1:10:MAX_NUM_KEEPERS+1; % Create the tests to run
buckets = zeros(size(tests)); % Create buckets for simulation stats

%% Collection of stats
for NUM_KEEPERS = tests

    % Run the trials
    for k = 1:NUM_TRIALS
        index = find(NUM_KEEPERS == tests, 1, 'first');
        
        % Creation of variables
        if NORMAL_DISTRIBUTION == 1
            people = CORRECT_TIME + DEVIATION_TIME.*randn(1,POPULATION); % Times of people
        else
            people = (rand(1,POPULATION).*2.*DEVIATION_TIME) + (CORRECT_TIME-DEVIATION_TIME);
        end
        if DISCRETE_TIME == 1 % Discretize time if required
            people = round(people);
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

        % Simulation of setup
        for i = 1:SIMULATION_TIME
            if std(people) < THRESHOLD_DEVIATION
                break;
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
        % endfor of simulation run
        
        buckets(index) = buckets(index) + i; % Store the time of simulation
    end
    % endfor of trials

    buckets(index) = buckets(index)/NUM_TRIALS;
end
% endfor the collection of stats

%% Plot the statistics receveived
plot(tests, buckets);
axis([0 MAX_NUM_KEEPERS 0 SIMULATION_TIME]);
title('Number of time-keepers vs. Simulation Time');
xlabel('Number of time-keepers');
ylabel('Simulation time');
text(tests(end-3),SIMULATION_TIME-10,strcat('Population: ', num2str(POPULATION)));
% text(tests(end-3),SIMULATION_TIME-10,strcat('Time Keeper: ', num2str(TIME_KEEPER)));
% if TIME_KEEPER == 1
%     text(tests(end-3),SIMULATION_TIME-20,strcat('Num Keepers: ', num2str(NUM_KEEPERS)));
% end