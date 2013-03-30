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
POPULATION = 50; % Number of birds to simulate
SPEED = 5; % Magnitude of the velocity
FIELD = 50; % Size of the arena
RADIUS = 5; % Field of interaction
SWIDTH = 2; % Width of swath to consider

% Initialize the birds
theta = rand(1,POPULATION)*pi;
positions = rand(2,POPULATION).*FIELD;

% Helper functions
modulo = @(x,n) (x - n*floor(x/n));

% For loop to do the simulation
for i = 1:size(t,2)
    % Plot the positions of the birds
    plot(positions(1,:), positions(2,:), '.');
    axis([0 FIELD 0 FIELD]);
    title(['N = ', num2str(POPULATION), ', R = ', num2str(RADIUS)]);
    frames(:,i) = getframe;
    
    % Update the heading and position of all the birds
    positions(1,:) = modulo(positions(1,:)+SPEED*dT.*cos(theta), FIELD);
    positions(2,:) = modulo(positions(2,:)+SPEED*dT.*sin(theta), FIELD);
    x = positions(1,:);
    y = positions(2,:);
    
    for j = 1:POPULATION
        if RADIUS < 1
            break;
        end
        offset = y(j) - tan(theta(j))*x(j);
        neighbours = positions(:, ((abs(y-y(j)) < RADIUS) & (abs(x-x(j)) < RADIUS)));
        lneighbours = neighbours(2,:) < tan(theta(j))*neighbours(1,:);
        rneighbours = neighbours(2,:) > tan(theta(j))*neighbours(1,:);
        
        theta(j) = modulo(theta(j) + (sum(rneighbours)-sum(lneighbours))*dT/sum(lneighbours | rneighbours), 2*pi);
    end
    
    % Apply confinement rules
    % need = (positions(1,:)<=0 | positions(1,:)>=FIELD);
    % theta(need) = pi - theta(need);
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