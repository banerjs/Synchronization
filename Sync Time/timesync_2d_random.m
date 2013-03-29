%%TIMESYNC_2D_RANDOM.m
% This script is the same as the script in timesync_1d, except this time it
% has been implemented in 2-D

clear all; clc;

%% Definitions of parameters
TIME_KEEPER = 1; % 0->there is no time-keeper. 1->there are time-keepers
NUM_KEEPERS = 100; % Number of time-keepers in the simulation
DISCRETE_TIME = 1; % Parameter for discretized times

SQRT_POP = 100;  % Axis size
POPULATION = SQRT_POP * SQRT_POP; % Number of people present
CORRECT_TIME = 20;  % Correct time of the simulation
DEVIATION_TIME = 5; % Std. Dev. of time in population
NORMAL_DISTRIBUTION = 0; % Decide if noise is randomly distributed

CHANGE_FUNC = {@(x,y) ([mean([x,y]), mean([x,y])]); % Normal interaction
               @(time,y) ([time, time]);           % Timer interaction
               @(x,y) (round(mean([x,y])*[1,1]))};  % Discretized interact

SIMULATION_TIME = 100; % Number of timesteps to be simulated for
THRESHOLD_DEVIATION = 0.01; % Set a threshold Deviation
BREAK_ON_DEVIATION = 1; % Break when the deviation reaches below THRESHOLD
SHOW_SIMULATION = 1; % Show the animation
SIMULATION_FACTORED = 1; % Show intermediate time-steps
SHOW_RESULT = 1; % Show the final state

%% Creation of variables
if NORMAL_DISTRIBUTION == 1
    people = CORRECT_TIME + DEVIATION_TIME.*randn(SQRT_POP); % Times of people
else
    people = (rand(SQRT_POP).*2.*DEVIATION_TIME) + (CORRECT_TIME-DEVIATION_TIME);
end
if DISCRETE_TIME == 1 % Discretize time if required
    people = round(people);
end

if TIME_KEEPER == 1
    keeper = zeros(NUM_KEEPERS,2);
    for i = 1:NUM_KEEPERS
        keeper(i,:) = [randi(SQRT_POP), randi(SQRT_POP)]; % Set a time-keeper
        people(keeper(i,1),keeper(i,2)) = CORRECT_TIME; % Make person the keeper
    end
end

%% Simulation of setup
for i = 1:SIMULATION_TIME
    if SHOW_SIMULATION == 1 && mod(i,SIMULATION_FACTORED) == 0
        imagesc(people,[15, 25]);
        drawnow;
    end
    
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
                if DISCRETE_TIME == 1
                    new_times = CHANGE_FUNC{3}(people(meeters1(1),meeters1(2)), people(meeters2(1),meeters2(2)));
                else
                    new_times = CHANGE_FUNC{1}(people(meeters1(1),meeters1(2)), people(meeters2(1),meeters2(2)));
                end
            end
        else
            if DISCRETE_TIME == 1
                new_times = CHANGE_FUNC{3}(people(meeters1(1),meeters1(2)), people(meeters2(1),meeters2(2)));
            else
                new_times = CHANGE_FUNC{1}(people(meeters1(1),meeters1(2)), people(meeters2(1),meeters2(2)));
            end
        end
        people(meeters2(1),meeters2(2)) = new_times(1);
        people(meeters1(1),meeters1(2)) = new_times(2);
    end
end

%% Display the end results
if SHOW_RESULT == 1
    imagesc(people,[15 25]);
    title(['Population Time Range = [', num2str(min(min(people))), ' , ', num2str(max(max(people))), ']']);
    colorbar;
end