%%CONTROL_CONFINED_BIRDS.m
% This program control a confined set of birds to follow a given line. It
% does so with Proportional linear control applied to the acceleration.

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
POPULATION = 500; % Number of birds to simulate
SPEED = 5; % Magnitude of the velocity
FIELD = 50; % Size of the arena

% Initialize the birds
theta = rand(1,POPULATION)*pi;
positions = rand(2,POPULATION).*FIELD;

% Helper functions
modulo = @(x,n) (x - n*floor(x/n));

% Desired Line
X = 5;

% For loop to do the simulation
for i = 1:size(t,2)
    % Plot the positions of the birds
    plot(positions(2,:), positions(1,:), '.', 0:FIELD, X*ones(size(0:FIELD)), 'r--');
    axis([0 FIELD 0 FIELD]);
    title(['N = ', num2str(POPULATION)]);
    frames(:,i) = getframe;
    
    % Update the heading and position of all the birds
    positions(1,:) = positions(1,:)+SPEED*dT.*cos(theta);
    positions(2,:) = modulo(positions(2,:)+SPEED*dT.*sin(theta), FIELD);
    
    theta = pi/2 + ((positions(1,:)-X)/FIELD)*(pi/2);
    
    % Apply confinement rules
    need = (positions(1,:)<=0 | positions(1,:)>=FIELD);
    theta(need) = pi - theta(need);
end
% endfor
