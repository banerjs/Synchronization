%%SIMULATE_REPULSIVE_BIRDS.m
% This script is to simulate self propelled particles in a manner
% described in the Vicsek paper

clear all; clc;

% Setup timing parameters for the model
T = 100; % Total time of simulation
dT = 0.1; % Timestep size
t = 0:dT:T; % Array of times that the simulation is to run for

% Initialize Movie Parameters
reruns = 1;
fps = 1/dT;
frames = moviein(size(t,2));

% Setup the model parameters
POPULATION = 200; % Number of birds to simulate
NOISE = pi/40; % Magnitude of Noise
SPEED = 5; % Magnitude of the velocity
FIELD = 50; % Size of the arena
ATTRACT_RADIUS = 3; % Field of attraction
REPULSE_RADIUS = 1; % Field of repulsion

% Initialize the birds
theta = rand(1,POPULATION)*2*pi;
positions = rand(2,POPULATION).*FIELD;

% Helper functions
modulo = @(x,n) (x - n*floor(x/n));

% For loop to do the simulation
for i = 1:size(t,2)
    % Plot the positions of the birds
    plot(positions(1,:), positions(2,:), '.');
    axis([0 FIELD 0 FIELD]);
    title(['N = ', num2str(POPULATION)]);
    frames(:,i) = getframe;
    
    % Update the heading and position of all the birds
    positions(1,:) = modulo(positions(1,:)+SPEED*dT.*cos(theta), FIELD);
    positions(2,:) = modulo(positions(2,:)+SPEED*dT.*sin(theta), FIELD);

    for j = 1:POPULATION
        repel_1 = ((((positions(1,:)-positions(1,j)) > 0) & (abs(positions(1,:)-positions(1,j)) < REPULSE_RADIUS)) & ...
                   (((positions(2,:)-positions(2,j)) > 0) & (abs(positions(2,:)-positions(2,j)) < REPULSE_RADIUS)));
        repel_2 = ((((positions(1,:)-positions(1,j)) < 0) & (abs(positions(1,:)-positions(1,j)) < REPULSE_RADIUS)) & ...
                   (((positions(2,:)-positions(2,j)) > 0) & (abs(positions(2,:)-positions(2,j)) < REPULSE_RADIUS)));
        repel_3 = ((((positions(1,:)-positions(1,j)) < 0) & (abs(positions(1,:)-positions(1,j)) < REPULSE_RADIUS)) & ...
                   (((positions(2,:)-positions(2,j)) < 0) & (abs(positions(2,:)-positions(2,j)) < REPULSE_RADIUS)));
        repel_4 = ((((positions(1,:)-positions(1,j)) > 0) & (abs(positions(1,:)-positions(1,j)) < REPULSE_RADIUS)) & ...
                   (((positions(2,:)-positions(2,j)) < 0) & (abs(positions(2,:)-positions(2,j)) < REPULSE_RADIUS)));
        theta(j) = modulo(repulse_function(theta(j), [sum(repel_1), sum(repel_2), sum(repel_3), sum(repel_4)]), 2*pi);

        neighbours = ((abs(positions(1,:)-positions(1,j)) < ATTRACT_RADIUS) & (abs(positions(2,:)-positions(2,j)) < ATTRACT_RADIUS));
        theta(j) = modulo(mean(theta(neighbours)) + NOISE*randn(), 2*pi);
    end
end
% endfor

% Plot the birds
figure;
plot(positions(1,:), positions(2,:), '.');
axis([0 FIELD 0 FIELD]);
title(['Final Position, N = ', num2str(POPULATION)]);