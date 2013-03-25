%%TIMESYNC_2D_STATS.m
% This script does the collection of statistics of running timesync_2d

clear all; clc;

%% Definitions of parameters
TIME_KEEPER = 1; % 0->there is no time-keeper. 1->there are time-keepers
MAX_NUM_KEEPERS = 10; % Number of time-keepers in the simulation

MAX_SQRT_POP = 100;  % Axis size
CORRECT_TIME = 20;  % Correct time of the simulation
DEVIATION_TIME = 5; % Std. Dev. of time in population
NORMAL_DISTRIBUTION = 0; % Decide if noise is randomly distributed

CHANGE_FUNC = {@(x,y) ([mean([x,y]), mean([x,y])]); % Normal interaction
               @(time,y) ([time, time])};           % Timer interaction

SIMULATION_TIME = 100; % Number of timesteps to be simulated for
THRESHOLD_DEVIATION = 0.01; % Set a threshold Deviation
BREAK_ON_DEVIATION = 1; % Break when the deviation reaches below THRESHOLD
SHOW_RESULT = 1; % Show the final state

%% Creation of parameters for test
NUM_TRIALS = 50; % Number of trials per test
NUM_KEEPERS = MAX_NUM_KEEPERS; % Set the other parameter
tests = 10:10:MAX_SQRT_POP; % Create the tests to run
buckets = zeros(size(tests)); % Create buckets for simulation stats

%% Collect the stats
for SQRT_POP = tests
    % Create other parameters
    POPULATION = SQRT_POP * SQRT_POP;

    % Do each trial for this setting
    for m = 1:NUM_TRIALS
        index = find(SQRT_POP == tests, 1, 'first');

        % Creation of variables
        if NORMAL_DISTRIBUTION == 1
            people = CORRECT_TIME + DEVIATION_TIME.*randn(SQRT_POP); % Times of people
        else
            people = (rand(SQRT_POP).*2.*DEVIATION_TIME) + (CORRECT_TIME-DEVIATION_TIME);
        end

        if TIME_KEEPER == 1
            keeper = zeros(NUM_KEEPERS,2);
            for i = 1:NUM_KEEPERS
                keeper(i,:) = [randi(SQRT_POP), randi(SQRT_POP)]; % Set a time-keeper
                people(keeper(i,1),keeper(i,2)) = CORRECT_TIME; % Make person the keeper
            end
        end

        % Simulation of setup
        for i = 1:SIMULATION_TIME
            if BREAK_ON_DEVIATION == 1 && std(people(:)) < THRESHOLD_DEVIATION
                break;
            end

            num_interact = randi(floor(POPULATION/2)); % Number of interactions

            for j = 1:num_interact                     % Simulate interations
                meeters1 = [randi(SQRT_POP), randi(SQRT_POP)];
                meeters2 = [randi(SQRT_POP), randi(SQRT_POP)];
                if TIME_KEEPER == 1
                    if any(all(repmat(meeters1,size(keeper,1),1)==keeper, 2))
                        new_times = CHANGE_FUNC{2}(people(meeters1(1),meeters1(2)), people(meeters2(1),meeters2(2)));
                    elseif any(all(repmat(meeters2,size(keeper,1),1)==keeper, 2))
                        new_times = CHANGE_FUNC{2}(people(meeters2(1),meeters2(2)), people(meeters1(1),meeters1(2)));
                    else
                        new_times = CHANGE_FUNC{1}(people(meeters1(1),meeters1(2)), people(meeters2(1),meeters2(2)));
                    end
                else
                    new_times = CHANGE_FUNC{1}(people(meeters1(1),meeters1(2)), people(meeters2(1),meeters2(2)));
                end
                people(meeters2(1),meeters2(2)) = new_times(1);
                people(meeters1(1),meeters1(2)) = new_times(2);
            end
        end
        % endfor simulation

        buckets(index) = buckets(index) + i; % Store the time of simulation
    end
    % endfor NUM_TRIALS

    buckets(index) = buckets(index)/NUM_TRIALS;
end

%% Save the end results
save(strcat('2D_TimeKeeper',num2str(NUM_KEEPERS),'.mat'));