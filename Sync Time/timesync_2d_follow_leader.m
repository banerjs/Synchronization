%%TIMESYNC_2D_FOLLOW_LEADER.m
% Same as neighbours, except move directly to neighbour's time
clear all; clc;

%% Set up the parameters of the simulation
TIME_KEEPER = 1; % 0->there is no time-keeper, 1->there are time-keepers
NUM_KEEPERS = 1; % Number of conductors in the arena
KEEPERS_MODE = 1; % 0->Random, 1->Equidistant, 2->Center cluster
UPDATE_TIME = 0; % Time updates during model?
UPDATE_NOISE = 0; % Are the updates noisy?
DISCRETE_TIME = 1; % Parameter for discretized time only

SQRT_POP = 100; % Give dimensions for the arena
POPULATION = SQRT_POP * SQRT_POP; % Number of people in this experiment
RADIUS = 1; % Radius of people to receive updates from
CORRECT_INIT_TIME = 20; % Correct initial time for the simulation
TIME_KEEPER_TIME = 17; % Time that all the time-keepers share
CORRECT_UPDATE_TIME = 1; % Correct update of time
DEVIATION_INIT_TIME = 5; % Deviation in the initial time
DEVIATION_UPDATE_TIME = 0.5; % Deviation in the update time for the sim
NORMAL_DISTRIBUTION = 1; % Is the noise a normal distribution?

SIMULATION_TIME = 200; % Number of timesteps to be simulated for
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
    keeper = zeros(size(people));
    keeper_state = 1;
    for i = 1:NUM_KEEPERS
        if KEEPERS_MODE == 0
            pos = [randi(SQRT_POP), randi(SQRT_POP)];
            keeper(pos(1), pos(2)) = keeper_state; % Set a time-keeper
        elseif KEEPERS_MODE == 1
            if NUM_KEEPERS == 1 % Hard code solution for 1
                pos = floor([SQRT_POP/2, SQRT_POP/2]);
                keeper(pos(1), pos(2)) = keeper_state;
            elseif NUM_KEEPERS == 5 % Hard code solution for 5
                if i == 1
                    pos = floor([SQRT_POP/2, SQRT_POP/6]);
                elseif i == 2 || i == 3
                    pos = floor([SQRT_POP/2+(i-2.5)*2*SQRT_POP/3, SQRT_POP/2]);
                else % i == 4 || i == 5
                    pos = floor([SQRT_POP/2+(i-4.5)*2*SQRT_POP/6, 5*SQRT_POP/6]);
                end
                keeper(pos(1),pos(2)) = keeper_state;
            elseif mod(NUM_KEEPERS,2) == 0 % Write solution for even num
                if mod(NUM_KEEPERS, 20) == 0 % Check for highest divisibilty
                    kx = mod(i,20);
                    ky = floor((i-1)/20);
                    pos = floor([SQRT_POP/2+(kx-9.5)*SQRT_POP/20, (SQRT_POP*20/NUM_KEEPERS)*ky + SQRT_POP*10/NUM_KEEPERS]);
                elseif mod(NUM_KEEPERS, 16) == 0 % Check for highest divisibilty
                    kx = mod(i,16);
                    ky = floor((i-1)/16);
                    pos = floor([SQRT_POP/2+(kx-7.5)*SQRT_POP/16, (SQRT_POP*16/NUM_KEEPERS)*ky + SQRT_POP*8/NUM_KEEPERS]);
                elseif mod(NUM_KEEPERS, 10) == 0 % Check for highest divisibilty
                    kx = mod(i,10);
                    ky = floor((i-1)/10);
                    pos = floor([SQRT_POP/2+(kx-4.5)*SQRT_POP/10, (SQRT_POP*10/NUM_KEEPERS)*ky + SQRT_POP*5/NUM_KEEPERS]);
                elseif mod(NUM_KEEPERS, 8) == 0 % Check for highest divisibilty
                    kx = mod(i,8);
                    ky = floor((i-1)/8);
                    pos = floor([SQRT_POP/2+(kx-3.5)*SQRT_POP/8, (SQRT_POP*8/NUM_KEEPERS)*ky + SQRT_POP*4/NUM_KEEPERS]);
                elseif mod(NUM_KEEPERS,4) == 0
                    kx = mod(i,4);
                    ky = floor((i-1)/4);
                    pos = floor([SQRT_POP/2+(kx-1.5)*SQRT_POP/4, (SQRT_POP*4/NUM_KEEPERS)*ky + SQRT_POP*2/NUM_KEEPERS]);
                else % mod(NUM_KEEPERS,2) == 0
                    kx = mod(i,2);
                    ky = floor((i-1)/2);
                    pos = floor([SQRT_POP/2+(kx-0.5)*SQRT_POP/2, (SQRT_POP*2/NUM_KEEPERS)*ky + SQRT_POP/NUM_KEEPERS]);
                end
                keeper(pos(1),pos(2)) = keeper_state;
            else % Odd number but not 1 or 5
                disp('Invalid number of keepers. Not trained for this!');
                return;
            end
        elseif KEEPERS_MODE == 2
            kd = floor(sqrt(NUM_KEEPERS));
            ks = floor([SQRT_POP/2-kd, SQRT_POP/2-kd]);
            pos = ks + [mod(i,kd), floor(i/kd)];
            keeper(pos(1), pos(2)) = keeper_state;
        end
        people(pos(1), pos(2)) = TIME_KEEPER_TIME; % Set the time for the time-keeper
    end
end

%% Create the movie
reruns = 1;
fps = 5;
frames = moviein(SIMULATION_TIME);

%% Simulation of Setup
imagesc(people,[CORRECT_INIT_TIME-DEVIATION_INIT_TIME CORRECT_INIT_TIME+DEVIATION_INIT_TIME])
drawnow;

npeople = people + 1;

for i = 1:SIMULATION_TIME
    if all(BREAK_ON_DEVIATION == 1 & npeople == people)
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
    nkeeper = keeper;
    
    % Update the times for all the people based on avg of neighbours
    for j = 1:size(people,1)
        for k = 1:size(people,2)
            if TIME_KEEPER == 1 && nkeeper(j,k) > 0
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
            keeper_present = max(max(nkeeper(rstart:rend,cstart:cend)));
            if keeper_present > 0
                people(j,k) = TIME_KEEPER_TIME;
                keeper(j,k) = keeper_present+1;
            else
                people(j,k) = mean(neighbours(:));
            end
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