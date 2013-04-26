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
POPULATION = 5; % Number of birds to simulate
NOISE = 0; % Magnitude of Noise
SPEED = 1; % Magnitude of the velocity
FIELD = 50; % Size of the arena
RADIUS = 10; % Field of interaction
CONFINE = 1; % Confine the model? 0->No, 1->Toroidal, 2->Reflective

% Initialize the birds
theta = rand(1,POPULATION)*2*pi;
positions = rand(2,POPULATION).*FIELD;

% Helper functions
modulo = @(x,n) (x - n*floor(x/n));

% For loop to do the simulation
otheta = theta + 1;

for i = 1:size(t,2)
    % Plot the positions of the birds
    plot(positions(1,:), positions(2,:), '.');
    if CONFINE > 0
        axis([0 FIELD 0 FIELD]);
    else
        axis([-5*FIELD 5*FIELD -5*FIELD 5*FIELD])
    end
    title(['N = ', num2str(POPULATION), ', R = ', num2str(RADIUS)]);
    frames(:,i) = getframe;

    otheta = theta; % Store the previous heading of everyone
    
    % Update the heading and position of all the birds
    if CONFINE == 0 || CONFINE == 2
        positions(1,:) = positions(1,:)+SPEED*dT.*cos(theta);
        positions(2,:) = positions(2,:)+SPEED*dT.*sin(theta);
    else % CONFINE == 1
        positions(1,:) = modulo(positions(1,:)+SPEED*dT.*cos(theta), FIELD);
        positions(2,:) = modulo(positions(2,:)+SPEED*dT.*sin(theta), FIELD);
    end

    for j = 1:POPULATION
        neighbours = ((abs(positions(1,:)-positions(1,j)) < RADIUS) & (abs(positions(2,:)-positions(2,j)) < RADIUS));
        %theta(j) = modulo(mean(theta(neighbours)) + NOISE*randn(), 2*pi);
        theta(j) = NuclearForces(positions(:,j), neighbours, positions, RADIUS, otheta(j));
    end
    
    if CONFINE == 2
        need_x = abs(positions(1,:)-FIELD/2) > FIELD/2;
        need_y = abs(positions(2,:)-FIELD/2) > FIELD/2;
        need_xy = need_x & need_y;
        
        theta(need_x) = modulo(pi-otheta(need_x), 2*pi);
        theta(need_y) = modulo(2*pi-otheta(need_y), 2*pi);
        theta(need_xy) = modulo(pi+otheta(need_xy), 2*pi);
    end    
end
% endfor

% Plot the birds
plot(positions(1,:), positions(2,:), '.');
if CONFINE > 0
    axis([0 FIELD 0 FIELD]);
else
    axis([-5*FIELD 5*FIELD -5*FIELD 5*FIELD])
end
title(['Final Position, N = ', num2str(POPULATION)]);

% Save the movie if asked for
if SAVE_MOVIE == 1
    movie2avi(frames, strcat('Population',num2str(POPULATION),'Radius',num2str(RADIUS), '.avi'));
end
