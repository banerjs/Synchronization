%%SIMULATE_VICSEK_BIRDS.m
% This script is to simulate self propelled particles in a manner
% described in the Vicsek paper

if ~exist('STAT_COLLECTING', 'var') || STAT_COLLECTING == 0
    clear all; clc;
end

% Setup timing parameters for the model
T = 100; % Total time of simulation
dT = 0.1; % Timestep size
t = 0:dT:T; % Array of times that the simulation is to run for

% Initialize Movie Parameters
if ~exist('STAT_COLLECTING', 'var') || STAT_COLLECTING == 0
    reruns = 1;
    fps = 1/dT;
    frames = moviein(size(t,2));
    SAVE_MOVIE = 0;
end

% Setup the model parameters
if ~exist('STAT_COLLECTING', 'var') || STAT_COLLECTING == 0
    POPULATION = 400; % Number of birds to simulate
    NOISE = 0; % Magnitude of Noise
    FIELD = 50; % Size of the arena
    RADIUS = 3; % Field of interaction
    CONFINE = 2; % Confine the model? 0->No, 1->Toroidal, 2->Reflective
end
SPEED = 5; % Magnitude of the velocity

% Initialize the birds
theta = rand(1,POPULATION)*2*pi;
positions = rand(2,POPULATION).*FIELD;

% Helper functions
modulo = @(x,n) (x - n*floor(x/n));

% For loop to do the simulation
otheta = theta + 1;
need_x = [];
need_y = [];

for i = 1:size(t,2)
    if exist('STAT_COLLECTING', 'var') && STAT_COLLECTING > 0
        if otheta == theta
            break;
        end
    end
    
    % Plot the positions of the birds
    if ~exist('STAT_COLLECTING', 'var') || STAT_COLLECTING == 0
        plot(positions(1,:), positions(2,:), '.');
        if CONFINE > 0
            axis([0 FIELD 0 FIELD]);
        else
            axis([-10*FIELD 10*FIELD -10*FIELD 10*FIELD])
        end
        title(['N = ', num2str(POPULATION), ', R = ', num2str(RADIUS)]);
        frames(:,i) = getframe;
    end
    
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
        if RADIUS == 0
            break;
        end
        neighbours = ((abs(positions(1,:)-positions(1,j)) < RADIUS) & (abs(positions(2,:)-positions(2,j)) < RADIUS));
        theta(j) = modulo(mean(otheta(neighbours)) + NOISE*randn(), 2*pi);
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
if ~exist('STAT_COLLECTING', 'var') || STAT_COLLECTING == 0
    plot(positions(1,:), positions(2,:), '.');
    if CONFINE > 0
        axis([0 FIELD 0 FIELD]);
    else
        axis([-10*FIELD 10*FIELD -10*FIELD 10*FIELD])
    end
    title(['Final Position, N = ', num2str(POPULATION)]);

    % Save the movie if asked for
    if SAVE_MOVIE == 1
        movie2avi(frames, strcat('Population',num2str(POPULATION),'Radius',num2str(RADIUS), '.avi'));
    end
end