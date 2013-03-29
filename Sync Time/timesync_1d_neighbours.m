%%TIMESYNC_1D_NEIGHBOURS.m
% This is a script to simulate time synchronization between neighbours on a
% line. Similar to 1D_TIMESYNC_RANDOM.

clear all; clc;

%% Definition of parameters
TIME_KEEPER = 0; % 0->there is no time-keeper. 1->there are time-keepers
NUM_KEEPERS = 100; % The number of time-keepers in the simulation
DISCRETE_TIME = 0; % Parameter for if time is discretized

POPULATION = 1000;  % Number of people
NUM_NEIGHBOURS = 800; % No. of neighbours to interact with. 'ALL' is valid
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
if strcmpi('ALL', NUM_NEIGHBOURS) % If everyone is affected by everyone
    NUM_NEIGHBOURS = POPULATION + 1;
end

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

ymax = 25; % MAX and MIN for the axes
ymin = 15;

%% Simulation of setup
for i = 1:SIMULATION_TIME
    if BREAK_ON_DEVIATION == 1 && std(people) < THRESHOLD_DEVIATION
        break;
    end
    
    if SHOW_SIMULATION == 1
        subplot(2,1,1);
        plot(1:POPULATION, people, 1:POPULATION, CORRECT_TIME);
        axis([0, POPULATION, ymin, ymax]);
        subplot(2,1,2);
        bar(unique(people),histc(people, unique(people)));
        xlim([CORRECT_TIME-DEVIATION_TIME CORRECT_TIME+DEVIATION_TIME]);
        drawnow; pause(0.1);
    end
    
    [sorted, ix] = sort(people);
    npeople = people;
    
    for p = 1:POPULATION % Update the times of everyone
        if p <= NUM_NEIGHBOURS
            start = 1;
        else
            start = p - NUM_NEIGHBOURS;
        end
        if p > POPULATION - NUM_NEIGHBOURS
            last = POPULATION;
        else
            last = p + NUM_NEIGHBOURS;
        end
        neighbours = ix(start:last);
        
        if DISCRETE_TIME == 1
            npeople(ix(p)) = round(mean(people(neighbours)));
        else
            npeople(ix(p)) = mean(people(neighbours));
        end
    end
    
    people = npeople;
end
% endfor

if SHOW_RESULTS == 1
    subplot(2,1,1);
    plot(1:POPULATION, people, 1:POPULATION, CORRECT_TIME);
    axis([0, POPULATION, ymin, ymax]);
    title(['Population Time Range = [', num2str(min(people)), ' , ', num2str(max(people)), ']']);
    text(POPULATION/2,ymax-0.5,strcat('Number of simulation steps = ', num2str(i)));
    subplot(2,1,2);
    bar(unique(people),histc(people, unique(people)));
    xlim([CORRECT_TIME-DEVIATION_TIME CORRECT_TIME+DEVIATION_TIME]);
end