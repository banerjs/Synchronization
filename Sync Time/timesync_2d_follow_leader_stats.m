%%TIMESYNC_2D_FOLLOW_LEADER_STATS.m
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
CORRECT_INIT_TIME = 20; % Correct initial time for the simulation
TIME_KEEPER_TIME = 19; % Set the time of the timekeeper
CORRECT_UPDATE_TIME = 1; % Correct update of time
DEVIATION_INIT_TIME = 5; % Deviation in the initial time
DEVIATION_UPDATE_TIME = 0.5; % Deviation in the update time for the sim
NORMAL_DISTRIBUTION = 1; % Is the noise a normal distribution?

CHANGE_FUNC = {@(x,y) ([mean([x,y]), mean([x,y])]); % Normal interaction
               @(time,y) ([time, time]);            % Timer interaction
               @(x,y) (round(mean([x,y])*[1,1]))};  % Discretized interact
INDEX_FUNC = @(x) ((x+abs(x))/2); % Helps with indexing the array

SIMULATION_TIME = 200; % Number of timesteps to be simulated for
SHOW_RESULT = 0; % Show the result or save the result?

%% Create the master loop(s) for getting the results
NUM_TRIALS = 30; % Number of trials per parameter
SQRT_POP = MAX_SQRT_POP; % Set the other parameter
POPULATION = SQRT_POP * SQRT_POP;
tests = [0, 1, 2, 5, 10, 12, 16, 18, 20]; % Create the tests to run
buckets = zeros(size(tests)); % Create buckets for simulation time taken
results = zeros([SQRT_POP, SQRT_POP, size(tests,2)]); % Create buckets for final value of convergence

%% Simulate the results and gather data
disp(strcat('Beginning simulation. Time Keeper Time has been set to=', num2str(TIME_KEEPER_TIME)));

for RADIUS = [1, 2, 5, 10] % Radius of people to receive updates from
disp(strcat('Checking radius=',num2str(RADIUS)));

    for KEEPERS_MODE = 0:2 % 0->Random, 1->Equidistant, 2->Center cluster
    disp(strcat('Checking mode=',num2str(KEEPERS_MODE)));

        for NUM_KEEPERS = tests
            disp(strcat('NumKeepers has been set to=',num2str(NUM_KEEPERS)));

                if TIME_KEEPER == 1
                    keeper = zeros(NUM_KEEPERS,2);
                    for i = 1:NUM_KEEPERS
                        if KEEPERS_MODE == 0
                            keeper(i,:) = [randi(SQRT_POP), randi(SQRT_POP)]; % Set a time-keeper
                        elseif KEEPERS_MODE == 1
                            if NUM_KEEPERS == 1 % Hard code solution for 1
                                keeper(i,:) = floor([SQRT_POP/2, SQRT_POP/2]);
                            elseif NUM_KEEPERS == 5 % Hard code solution for 5
                                if i == 1
                                    keeper(i,:) = floor([SQRT_POP/2, SQRT_POP/6]);
                                elseif i == 2 || i == 3
                                    keeper(i,:) = floor([SQRT_POP/2+(i-2.5)*2*SQRT_POP/3, SQRT_POP/2]);
                                else % i == 4 || i == 5
                                    keeper(i,:) = floor([SQRT_POP/2+(i-4.5)*2*SQRT_POP/6, 5*SQRT_POP/6]);
                                end
                            elseif mod(NUM_KEEPERS,2) == 0 % Write solution for even num
        %                          if mod(NUM_KEEPERS, 20) == 0 % Check for highest divisibilty
        %                             kx = mod(i,20);
        %                             ky = floor((i-1)/20);
        %                             keeper(i,:) = floor([SQRT_POP/2+(kx-9.5)*SQRT_POP/20, (SQRT_POP*20/NUM_KEEPERS)*ky + SQRT_POP*10/NUM_KEEPERS]);
        %                          elseif mod(NUM_KEEPERS, 16) == 0 % Check for highest divisibilty
        %                             kx = mod(i,16);
        %                             ky = floor((i-1)/16);
        %                             keeper(i,:) = floor([SQRT_POP/2+(kx-7.5)*SQRT_POP/16, (SQRT_POP*16/NUM_KEEPERS)*ky + SQRT_POP*8/NUM_KEEPERS]);
        %                          elseif mod(NUM_KEEPERS, 10) == 0 % Check for highest divisibilty
        %                             kx = mod(i,10);
        %                             ky = floor((i-1)/10);
        %                             keeper(i,:) = floor([SQRT_POP/2+(kx-4.5)*SQRT_POP/10, (SQRT_POP*10/NUM_KEEPERS)*ky + SQRT_POP*5/NUM_KEEPERS]);
                                  if mod(NUM_KEEPERS, 8) == 0 % Check for highest divisibilty
                                     kx = mod(i,8);
                                     ky = floor((i-1)/8);
                                     keeper(i,:) = floor([SQRT_POP/2+(kx-3.5)*SQRT_POP/8, (SQRT_POP*8/NUM_KEEPERS)*ky + SQRT_POP*4/NUM_KEEPERS]);
                                  elseif mod(NUM_KEEPERS,4) == 0
                                     kx = mod(i,4);
                                     ky = floor((i-1)/4);
                                     keeper(i,:) = floor([SQRT_POP/2+(kx-1.5)*SQRT_POP/4, (SQRT_POP*4/NUM_KEEPERS)*ky + SQRT_POP*2/NUM_KEEPERS]);
                                  else % mod(NUM_KEEPERS,2) == 0
                                     kx = mod(i,2);
                                     ky = floor((i-1)/2);
                                     keeper(i,:) = floor([SQRT_POP/2+(kx-0.5)*SQRT_POP/2, (SQRT_POP*2/NUM_KEEPERS)*ky + SQRT_POP/NUM_KEEPERS]);
                                  end
                            else % Odd number but not 1 or 5
                                disp('Invalid number of keepers. Not trained for this!');
                                return;
                            end
                        elseif KEEPERS_MODE == 2
                            kd = floor(sqrt(NUM_KEEPERS));
                            ks = floor([SQRT_POP/2-kd, SQRT_POP/2-kd]);
                            keeper(i,:) = ks + [mod(i,kd), floor(i/kd)];
                        end
                    end
                end

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
                    for i = 1:NUM_KEEPERS
                        people(keeper(i,1),keeper(i,2)) = TIME_KEEPER_TIME; % Make person the keeper
                    end
                end

                % Simulation of Setup
                npeople = people - 1;
                num_keepers = NUM_KEEPERS;
                
                for i = 1:SIMULATION_TIME
                    % Check for a break from the simulation time
                    if npeople == people
                        break;
                    end

                    % Create a parallel matrix of people
                    npeople = people;
                    nkeeper = keeper;

                    % Update the times for all the people based on avg of neighbours
                    for j = 1:size(people,1)
                        for k = 1:size(people,2)
                            if TIME_KEEPER == 1 && any(all(repmat([j,k],size(nkeeper,1),1)==nkeeper, 2))
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
                            [nx, ny] = meshgrid(rstart:rend,cstart:cend);
                            npositions = [nx(:), ny(:)];
                            neighbours = npeople(rstart:rend,cstart:cend);

                            % Update the time at location
                            keep = intersect(nkeeper, npositions, 'rows');
                            if keep
                                people(j,k) = TIME_KEEPER_TIME;
                                num_keepers = num_keepers + 1;
                                keeper(num_keepers,:) = [j,k];
                            else
                                people(j,k) = mean(neighbours(:));
                            end
                        end
                    end
                    % endfor loop over people

                    % If only discrete values are allowed
                    if DISCRETE_TIME == 1
                        people = round(people);
                    end
                end
                % endfor simulation of situation

                buckets(index) = buckets(index) + i; % Store the time of simulation
                results(:,:,index) = results(:,:,index) + people; % Store the value of convergence
            end
            % endfor of trials

            disp('Finished all trials');
            buckets(index) = buckets(index)/NUM_TRIALS;
            results(:,:,index) = results(:,:,index)/NUM_TRIALS;
        end

        %% Save the computations done
        save(strcat('ForceTime',num2str(TIME_KEEPER_TIME),'_Radius',num2str(RADIUS),'_KeeperMode',num2str(KEEPERS_MODE),'.mat'));
    end
end
exit