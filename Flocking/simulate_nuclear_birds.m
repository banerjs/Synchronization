%%SIMULATE_NUCLEAR_BIRDS.m
% Simulate birds following the nuclear laws of separation

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
POPULATION = 100; % Number of birds to simulate
NOISE = 0; % Magnitude of Noise
SPEED = 5; % Magnitude of the velocity
FIELD = 50; % Size of the arena
RADIUS = 10; % Field of interaction

% Initialize the birds
theta = rand(1,POPULATION)*2*pi;
positions = rand(2,POPULATION).*FIELD;

% Helper functions
modulo = @(x,n) (x - n*floor(x/n));

% For loop to do the simulation
for i = 1:size(t,2)
    % Plot the positions of the birds
    plot(positions(1,:), positions(2,:), '.');
    %axis([0 FIELD 0 FIELD]);
    title(['N = ', num2str(POPULATION), ', R = ', num2str(RADIUS)]);
    frames(:,i) = getframe;
    
    % Update the heading and position of all the birds
    %positions(1,:) = mod(positions(1,:)+SPEED*dT.*cos(theta),FIELD);
    %positions(2,:) = mod(positions(2,:)+SPEED*dT.*sin(theta),FIELD);
    positions(1,:) = positions(1,:)+SPEED*dT.*cos(theta);
    positions(2,:) = positions(2,:)+SPEED*dT.*sin(theta);

    for j = 1:POPULATION
        neighbours = ((abs(positions(1,:)-positions(1,j)) < RADIUS) & (abs(positions(2,:)-positions(2,j)) < RADIUS));
        %theta(j) = modulo(mean(theta(neighbours)) + NOISE*randn(), 2*pi);
        theta(j) = NuclearForces(positions(:,j), neighbours, positions, RADIUS, theta(j));
    end
    
    %break;
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