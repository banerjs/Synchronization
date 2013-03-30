%%TIMESYNC_2D_NEIGHBOURS.m
% This is a 2-D simulation of update of time happening and affecting only
% neighbours. Very, very similar to the sandpile model.

clear all; clc;

%% Set up the parameters of the simulation
TIME_KEEPER = 1; % 0->there is no time-keeper, 1->there are time-keepers
NUM_KEEPERS = 1; % Number of conductors in the arena
UPDATE_TIME = 1; % Time updates during model?
UPDATE_NOISE = 1; % Are the updates noisy?
DISCRETE_TIME = 1; % Parameter for discretized time only

SQRT_POP = 100; % Give dimensions for the arena
POPULATION = SQRT_POP * SQRT_POP; % Number of people in this experiment
RADIUS = 10; % Radius of people to receive updates from
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
SHOW_SIMULATION = 1; % Show the animation
SIMULATION_FACTORED = 1; % Show intermediate time-steps
SHOW_RESULT = 1; % Show the final state
THRESHOLD_DEVIATION = 0.01; % Set a threshold standard deviation
BREAK_ON_DEVIATION = 1; % Flag for whether or not to break on std. dev.

%% Create initial variables for the simulation
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

%% Create the movie
reruns = 1;
fps = 5;
frames = moviein(SIMULATION_TIME);

%% Simulation of Setup
imagesc(people,[CORRECT_INIT_TIME-DEVIATION_INIT_TIME CORRECT_INIT_TIME+DEVIATION_INIT_TIME])
drawnow;

for i = 1:SIMULATION_TIME
    if BREAK_ON_DEVIATION == 1 && std(people(:)) < THRESHOLD_DEVIATION
        break;
    end
    
    if SHOW_SIMULATION == 1 && mod(i,SIMULATION_FACTORED) == 0
        if UPDATE_TIME == 1
            imagesc(people,[CORRECT_INIT_TIME+(i-1)*CORRECT_UPDATE_TIME-DEVIATION_INIT_TIME, CORRECT_INIT_TIME+(i-1)*CORRECT_UPDATE_TIME+DEVIATION_INIT_TIME]);
        else
            imagesc(people,[CORRECT_INIT_TIME-DEVIATION_INIT_TIME, CORRECT_INIT_TIME+DEVIATION_INIT_TIME])
        end
        text(SQRT_POP/2, SQRT_POP/8, strcat('Mean = ', num2str(mean(people(:))), ', Variance = ', num2str(var(people(:)))), ...
            'BackgroundColor', [1 1 1]);
        frames(:,i) = getframe;
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
    
    if DISCRETE_TIME == 1
        people = round(people);
    end
end
% endfor simulation of situation

%% Display the end results
if SHOW_RESULT == 1
    disp(strcat('Simulation ended on step=', num2str(i)));
    if UPDATE_TIME == 1
        imagesc(people,[CORRECT_INIT_TIME+i*CORRECT_UPDATE_TIME-DEVIATION_INIT_TIME CORRECT_INIT_TIME+i*CORRECT_UPDATE_TIME+DEVIATION_INIT_TIME]);
    else
        imagesc(people,[CORRECT_INIT_TIME-DEVIATION_INIT_TIME CORRECT_INIT_TIME+DEVIATION_INIT_TIME])
    end
    title(['Population Time Range = [', num2str(min(min(people))), ' , ', num2str(max(max(people))), ']']);
    text(SQRT_POP/2, SQRT_POP/8, strcat('Mean = ', num2str(mean(people(:))), ', Variance = ', num2str(var(people(:)))), ...
        'BackgroundColor', [1 1 1]);
    colorbar;
end