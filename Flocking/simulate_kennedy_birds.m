%%SIMULATE_KENNEDY_BIRDS.m
% This simulator uses the Kennedy and Eberhart model of particles to
% simulate the behavior of birds. Main difference between this simulation
% and the one presented by Kennedy is that this still follows the Vicsek
% paradigm of changing velocity by changing the heading only.

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
POPULATION = 200; % Number of birds to simulate
NOISE = 0; % Magnitude of Noise
SPEED = 5; % Magnitude of the velocity
FIELD = 50; % Size of the arena
RADIUS = 0; % Field of interaction. 0 -> do not use nearest neighbour
ROOST = [FIELD/2; FIELD/2]; % Set the roost position of the particle
P_INCREMENT = 0.05; % Set p_increment according to the model
G_INCREMENT = 0.05; % Set g_increment according to the model

% Initialize the birds
theta = rand(1,POPULATION)*2*pi; % Heading of each particle
positions = rand(2,POPULATION).*FIELD; % Present solution of each particle
best = positions; % Create an array for the best solution
[~, gbest] = min(sqrt((best(1,:)-ROOST(1)).^2 + (best(2,:)-ROOST(2)).^2));

% Helper functions
modulo = @(x,n) (x - n*floor(x/n));

% For loop to do the simulation
for i = 1:size(t,2)
    % Plot the positions of the birds
    plot(positions(1,:), positions(2,:), '.', ROOST(1), ROOST(2), 'ro');
    axis([0 FIELD 0 FIELD]);
    %axis([-5*FIELD 5*FIELD -5*FIELD 5*FIELD]);
    title(['N = ', num2str(POPULATION), ', R = ', num2str(RADIUS)]);
    frames(:,i) = getframe;
    
    % Update the heading and position of all the birds
    positions(1,:) = modulo(positions(1,:)+SPEED*dT.*cos(theta), FIELD);
    %positions(1,:) = positions(1,:)+SPEED*dT.*cos(theta);
    positions(2,:) = modulo(positions(2,:)+SPEED*dT.*sin(theta), FIELD);
    %positions(2,:) = positions(2,:)+SPEED*dT.*sin(theta);
    
    for j = 1:POPULATION
        % Check if nearest neighbour interactions are enabled
        if RADIUS > 0
            neighbours = ((abs(positions(1,:)-positions(1,j)) < RADIUS) & (abs(positions(2,:)-positions(2,j)) < RADIUS));
            theta(j) = modulo(mean(theta(neighbours)) + NOISE*randn(), 2*pi);
        end
        
        % Adjust according to roost position
        pangle = acos(dot(positions(:,j),best(:,j))/...
                      (norm(positions(:,j))*norm(best(:,j))));
        pside = cross([positions(:,j);0], [best(:,j);0]);
        gangle = acos(dot(positions(:,j),best(:,gbest))/...
                      (norm(positions(:,j))*norm(best(:,gbest))));
        gside = cross([positions(:,j);0], [best(:,gbest);0]);
        
        theta(j) = theta(j) + sign(pside(3))*P_INCREMENT*(pangle-theta(j)) ...
                    + sign(gside(3))*G_INCREMENT*(gangle-theta(j));
        
        % Update the best
        if norm(positions(:,j)-ROOST) < norm(best(:,j)-ROOST)
            best(:,j) = positions(:,j);
        end
    end
    
    % Get the global best
    [~, gbest] = min(sqrt((best(1,:)-ROOST(1)).^2 + (best(2,:)-ROOST(2)).^2));
end
% endfor

% Plot the birds
figure;
plot(positions(1,:), positions(2,:), '.', ROOST(1), ROOST(2), 'ro');
axis([0 FIELD 0 FIELD]);
title(['Final Position, N = ', num2str(POPULATION)]);

% Save the movie if asked for
if SAVE_MOVIE == 1
    movie2avi(frames, strcat('Population',num2str(POPULATION),'Radius',num2str(RADIUS), '.avi'));
end