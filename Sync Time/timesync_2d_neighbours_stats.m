%%TIMESYNC_CONTINUOUS_STATS.m
% This is a 2-D simulation of the collection of statistics of running
% timesync_continuous.

clear all; clc;

%% Set up the parameters of the simulation
TIME_KEEPER = 1; % 0->there is no time-keeper, 1->there are time-keepers
MAX_NUM_KEEPERS = 100; % Number of conductors in the arena
UPDATE_TIME = 0; % Time updates during model?
UPDATE_NOISE = 1; % Are the updates noisy?
DISCRETE_TIME = 1; % Flag to discretize time

MAX_SQRT_POP = 100; % Give dimensions for the arena
RADIUS = 1; % Radius of people to receive updates from
CORRECT_INIT_TIME = 20; % Correct initial time for the simulation
CORRECT_UPDATE_TIME = 1; % Correct update of time
DEVIATION_INIT_TIME = 5; % Deviation in the initial time
DEVIATION_UPDATE_TIME = 0.5; % Deviation in the update time for the sim
NORMAL_DISTRIBUTION = 1; % Is the noise a normal distribution?

CHANGE_FUNC = {@(x,y) ([mean([x,y]), mean([x,y])]); % Normal interaction
               @(time,y) ([time, time]);            % Timer interaction
               @(x,y) (round(mean([x,y])*[1,1]))};  % Discretized interact
INDEX_FUNC = @(x) ((x+abs(x))/2); % Helps with indexing the array

SIMULATION_TIME = 100; % Number of timesteps to be simulated for
SHOW_RESULT = 1; % Show the result or save the result?

%% Create the master loop(s) for getting the results
THRESHOLD_DEVIATION = 0.01; % Threshold value of std. dev. break on
NUM_TRIALS = 10; % Number of trials per parameter
SQRT_POP = MAX_SQRT_POP; % Set the other parameter
POPULATION = SQRT_POP * SQRT_POP;
tests = 0:20:MAX_NUM_KEEPERS; % Create the tests to run
buckets = zeros(size(tests)); % Create buckets for simulation stats

%% Simulate the results and gather data
for NUM_KEEPERS = tests
    % Set the other parameters

    for m = 1:NUM_TRIALS
        index = find(NUM_KEEPERS == tests, 1, 'first');
        
        % Create initial variables for the simulation
        if NORMAL_DISTRIBUTION == 1
            people = CORRECT_INIT_TIME + DEVIATION_INIT_TIME.*randn(SQRT_POP); % Times of people
        else
            people = (rand(SQRT_POP).*2.*DEVIATION_INIT_TIME) + (CORRECT_INIT_TIME-DEVIATION_INIT_TIME);
        end
        if DISCRETE_TIME == 1 % Discretize time if required
            people = round(people);
        end

        if TIME_KEEPER == 1
            keeper = zeros(NUM_KEEPERS,2);
            for i = 1:NUM_KEEPERS
                keeper(i,:) = [randi(SQRT_POP), randi(SQRT_POP)]; % Set a time-keeper
                people(keeper(i,1),keeper(i,2)) = CORRECT_INIT_TIME; % Make person the keeper
            end
        end

        % Simulation of Setup
        for i = 1:SIMULATION_TIME
            % Check for a break from the simulation time
            if std(people(:)) < THRESHOLD_DEVIATION
                break;
            end
            
            % Create a parallel matrix of people
            npeople = people;
            
            % Update the times for all the people based on avg of neighbours
            for j = 1:size(people,1)
                for k = 1:size(people,2)
                    if TIME_KEEPER == 1 && any(all(repmat([j,k],size(keeper,1),1)==keeper, 2))
                        continue;
                    end

                    % Generate the neighbours
                    columns = 2*RADIUS+1; rows = 2*RADIUS+1;
                    cstart = j-RADIUS; cend = j+RADIUS; rstart = k-RADIUS; rend = k+RADIUS;
                    if j-RADIUS < 1
                        columns = columns-RADIUS+j-1;
                        cstart = 1;
                    end
                    if j+RADIUS > SQRT_POP
                        columns = columns-RADIUS+SQRT_POP-j;
                        cend = SQRT_POP;
                    end
                    if k-RADIUS < 1
                        rows = rows-RADIUS+k-1;
                        rstart = 1;
                    end
                    if k+RADIUS > SQRT_POP
                        rows = rows-RADIUS+SQRT_POP-k;
                        rend = SQRT_POP;
                    end
                    neighbours = npeople(rstart:rend,cstart:cend);

                    % Update the time at location
                    people(j,k) = mean(neighbours(:));
                end
            end
            % endfor loop over people

            if UPDATE_TIME == 1
                people = people+CORRECT_UPDATE_TIME;

                % Add in noise as required
                if UPDATE_NOISE == 1
                    if NORMAL_DISTRIBUTION == 1
                        people = people + DEVIATION_UPDATE_TIME.*randn(size(people));
                    else
                        people = people + (rand(size(people)).*DEVIATION_UPDATE_TIME) - DEVIATION_UPDATE_TIME;
                    end
                end
            end

            % If only discrete values are allowed
            if DISCRETE_TIME == 1
                people = round(people);
            end
        end
        % endfor simulation of situation
        
        buckets(index) = buckets(index) + i; % Store the time of simulation
    end
    % endfor of trials
    
    buckets(index) = buckets(index)/NUM_TRIALS;
end

%% Save the computations done
save(strcat('Continuous_Population',num2str(POPULATION),'_Update',num2str(UPDATE_TIME),'.mat'));
if SHOW_RESULT
    plot(tests.^2, buckets);
    axis([0 POPULATION 0 SIMULATION_TIME]);
    title('Population vs. Simulation Time');
    xlabel('Number of people');
    ylabel('Simulation time');
    text(tests(end-3).^2,SIMULATION_TIME-10,strcat('Number of time-keepers: ', num2str(NUM_KEEPERS)));
end