%%SIMULATE_CONFINED_BIRDS.m
% This simulation is used to simulate birds confined to move in one
% direction, and remain within a particular width

clear all; clc;

% Setup timing parameters for the model
T = 100; % Total time of simulation
dT = 0.1; % Timestep size
t = 0:dT:T; % Array of times that the simulation is to run for

% Initialize Movie Parameters
reruns = 1;
fps = 1/dT;
frames = moviein(size(t,2));
SAVE_MOVIE = 0;

% Setup the model parameters
POPULATION = 400; % Number of birds to simulate
SPEED = 5; % Magnitude of the velocity
FIELD = 50; % Size of the arena
RADIUS = 100; % Field of interaction
SWIDTH = 2; % Width of swath to consider
NUM_LEADERS = 0; % Number of leaders in the flock
LEADER_HEADING = 0; % Heading of the leaders in the flock
FORCE_LEADER = 0; % Is the leader forceful?

% Initialize the birds
theta = randn(1,POPULATION)*10;
positions = rand(2,POPULATION).*FIELD;

% Initialize the leader birds
leaders = randperm(POPULATION);
if FORCE_LEADER == 1
    l = leaders(1:NUM_LEADERS);
    theta(l) = LEADER_HEADING;
    leaders = zeros(POPULATION,1);
    leaders(1:NUM_LEADERS) = l;
else
    leaders = leaders(1:NUM_LEADERS);
    theta(leaders) = LEADER_HEADING;
end

% Helper functions
modulo = @(x,n) (x - n*floor(x/n));

% For loop to do the simulation
num_leaders = NUM_LEADERS;

for i = 1:size(t,2)
    % Plot the positions of the birds
    plot(positions(1,:), positions(2,:), '.');
    axis([-FIELD*10 FIELD*10 -10*FIELD FIELD*10]);
    title(['N = ', num2str(POPULATION), ', R = ', num2str(RADIUS)]);
    frames(:,i) = getframe;
    
    % Update the heading and position of all the birds
    %positions(1,:) = modulo(positions(1,:)+SPEED*dT.*cos(theta), FIELD);
    positions(1,:) = positions(1,:)+SPEED*dT.*cos(theta);
    %positions(2,:) = modulo(positions(2,:)+SPEED*dT.*sin(theta), FIELD);
    positions(2,:) = positions(2,:)+SPEED*dT.*sin(theta);
    x = positions(1,:);
    y = positions(2,:);
    
    for j = 1:POPULATION
        if RADIUS < 1
            break;
        end
        if any(j == leaders) % Do not update the leaders
            continue;
        end
        offset = y(j) - tan(theta(j))*x(j);
        neighbours = positions(:, ((abs(y-y(j)) < RADIUS) & (abs(x-x(j)) < RADIUS)));
        lneighbours = neighbours(2,:) < tan(theta(j))*neighbours(1,:)+offset;
        rneighbours = neighbours(2,:) > tan(theta(j))*neighbours(1,:)+offset;
        
        if NUM_LEADERS > 0
            if any(FORCE_LEADER == 1 & intersect(neighbours',positions(:, leaders(1:num_leaders))', 'rows'))
                theta(j) = LEADER_HEADING;
                num_leaders = num_leaders+1;
                leaders(num_leaders) = j;
            end
        elseif sum(lneighbours | rneighbours) ~= 0
            theta(j) = modulo(theta(j) + ((sum(lneighbours)-sum(rneighbours))/sum(lneighbours | rneighbours))*pi/2, 2*pi);
        end
    end
    
    % Apply confinement rules
    %need = (positions(1,:)<=0 | positions(1,:)>=FIELD);
    %theta(need) = pi - theta(need);
end
% endfor

% Plot the birds
figure;
plot(positions(1,:), positions(2,:), '.');
axis([-FIELD*10 FIELD*10 -10*FIELD FIELD*10]);
title(['Final Position, N = ', num2str(POPULATION)]);

% Save the movie if asked for
if SAVE_MOVIE == 1
    movie2avi(frames, strcat('Population',num2str(POPULATION),'Radius',num2str(RADIUS), '.avi'));
end