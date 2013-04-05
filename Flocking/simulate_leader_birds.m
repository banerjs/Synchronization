%%SIMULATE_LEADER_BIRDS.m
% This script is to simulate boids with the rule to follow the special bird

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
NOISE = 0; % Magnitude of Noise
SPEED = 5; % Magnitude of the velocity
FIELD = 50; % Size of the arena
RADIUS = 2; % Field of interaction
NUM_LEADERS = 1; % Number of leaders in the flock
LEADER_HEADING = 0; % Heading of the leaders in the flock
FORCE_LEADER = 1; % Is the leader forceful?

% Initialize the birds
theta = rand(1,POPULATION)*2*pi;
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
    axis([0 FIELD 0 FIELD]);
    title(['N = ', num2str(POPULATION), ', R = ', num2str(RADIUS)]);
    frames(:,i) = getframe;
    
    % Update the heading and position of all the birds
    positions(1,:) = modulo(positions(1,:)+SPEED*dT.*cos(theta), FIELD);
    positions(2,:) = modulo(positions(2,:)+SPEED*dT.*sin(theta), FIELD);

    for j = 1:POPULATION
        if any(j == leaders) % Do not update the leaders
            continue;
        end
        neighbours = ((abs(positions(1,:)-positions(1,j)) < RADIUS) & (abs(positions(2,:)-positions(2,j)) < RADIUS));
        if FORCE_LEADER == 1 && any(neighbours(leaders(1:num_leaders)))
            theta(j) = LEADER_HEADING;
            num_leaders = num_leaders+1;
            leaders(num_leaders) = j;
        else
            theta(j) = modulo(mean(theta(neighbours)) + NOISE*randn(), 2*pi);
        end
    end
end
% endfor

% Plot the birds
figure;
plot(positions(1,:), positions(2,:), '.');
axis([0 FIELD 0 FIELD]);
title(['Final Position, N = ', num2str(POPULATION)]);

% Save the movie if asked for
if SAVE_MOVIE == 1
    movie2avi(frames, strcat('Population',num2str(POPULATION),'Radius',num2str(RADIUS), '.avi'));
end