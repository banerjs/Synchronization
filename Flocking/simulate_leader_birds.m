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
POPULATION = 300; % Number of birds to simulate
NOISE = 0; % Magnitude of Noise
SPEED = 5; % Magnitude of the velocity
FIELD = 50; % Size of the arena
CONFINE = 2; % Confine the model? 0->No, 1->Toroidal, 2->Reflective
RADIUS = 1; % Field of interaction
NUM_LEADERS = 1; % Number of leaders in the flock
LEADER_HEADING = 0; % Heading of the leaders in the flock
UPDATE_HEADING = 1; % Update the leader heading?
FORCE_LEADER = 1; % Is the leader forceful?
PROBABILISTIC_FOLLOW = 0; % Should we throw a dice to decide on following?
FOLLOW_PROBABILITY = 0.9; % Probability that we decide to follow the leader

% Initialize the birds
theta = rand(1,POPULATION)*2*pi;
positions = rand(2,POPULATION).*FIELD;

% Initialize the leader birds
leaders = zeros(1,POPULATION);
leader_state = 1;
l = randperm(POPULATION);
leaders(l(1:NUM_LEADERS)) = leader_state;
theta(l(1:NUM_LEADERS)) = LEADER_HEADING;

% Helper functions
modulo = @(x,n) (x - n*floor(x/n));

% For loop to do the simulation
num_leaders = NUM_LEADERS;
otheta = theta - 1;

for i = 1:size(t,2)
    % Plot the positions of the birds
    plot(positions(1,:), positions(2,:), '.');
    if CONFINE > 0
        axis([0 FIELD 0 FIELD]);
    else
        axis([-10*FIELD 10*FIELD -10*FIELD 10*FIELD])
    end
    title(['N = ', num2str(POPULATION), ', R = ', num2str(RADIUS)]);
    frames(:,i) = getframe;
    
    % Store old values
    otheta = theta;
    
    % Update the leader heading
    if UPDATE_HEADING == 1
        LEADER_HEADING = LEADER_HEADING + 0.01;
    end
    
    % Update the heading and position of all the birds
    if CONFINE == 0 || CONFINE == 2
        positions(1,:) = positions(1,:)+SPEED*dT.*cos(theta);
        positions(2,:) = positions(2,:)+SPEED*dT.*sin(theta);
    else % CONFINE == 1
        positions(1,:) = modulo(positions(1,:)+SPEED*dT.*cos(theta), FIELD);
        positions(2,:) = modulo(positions(2,:)+SPEED*dT.*sin(theta), FIELD);
    end
    
    for j = 1:POPULATION
        if leaders(j) > 0 % Leaders have special motions
            if leaders(j) == 1
                theta(j) = LEADER_HEADING;
            else
                superior = otheta(leaders == leaders(j)-1);
                if PROBABILISTIC_FOLLOW == 1
                    dice = rand(); % Decide to follow or not
                else
                    dice = 0; % Ensure that following happens
                end
                if dice <= FOLLOW_PROBABILITY
                    theta(j) = superior(1);
                end
            end
            continue;
        end
        neighbours = ((abs(positions(1,:)-positions(1,j)) < RADIUS) & (abs(positions(2,:)-positions(2,j)) < RADIUS));
        if FORCE_LEADER == 1 && any(neighbours & leaders)
            temp = neighbours .* leaders;
            temp(~temp) = inf;
            leader_state = min(temp) + 1;
            if PROBABILISTIC_FOLLOW == 1
                dice = rand(); % Decide to follow or not
            else
                dice = 0; % Ensure that following happens
            end
            if dice <= FOLLOW_PROBABILITY
                leaders(j) = leader_state;
                superior = otheta(leaders == leaders(j)-1);
                theta(j) = superior(1);
            end
        else
            theta(j) = modulo(mean(theta(neighbours)) + NOISE*randn(), 2*pi);
        end
    end
    
    if CONFINE == 2
        need_x = abs(positions(1,:)-FIELD/2) > FIELD/2;
        need_y = abs(positions(2,:)-FIELD/2) > FIELD/2;
        need_xy = need_x & need_y;

        theta(need_x) = modulo(pi-otheta(need_x), 2*pi);
        theta(need_y) = modulo(2*pi-otheta(need_y), 2*pi);
        theta(need_xy) = modulo(pi+otheta(need_xy), 2*pi);
        
        lead_change = (leaders & need_x) | (leaders & need_y);
        if any(lead_change)
            index = find(lead_change, 1, 'first');
            LEADER_HEADING = theta(index);
        end
    end
end
% endfor

% Plot the birds
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