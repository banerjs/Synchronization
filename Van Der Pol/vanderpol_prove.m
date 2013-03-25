%%VANDERPOL_PROVE.m
% This is a script that generates the graph use to prove the van der Pol
% oscillator's presence of a limit cycle. Most of the calcuations have been
% done by hand. This script is just used to generate the graph.

clear all; clc;

NUM_LINES = 20;

vdp = @(t,y) ([y(2)+y(1)-((y(1)^3)/3); -y(1)]); % Create changed ODE

states = cell(NUM_LINES,1); % Create a cell array for the states returned by ODE
x1 = -5:0.1:5; % Create a set of points for plotting F(x)
x2 = ((x1.^3)/3) - x1; % Define the function F(x)

% Generate the different limit cycles
for i = 1:NUM_LINES
    [t, states{i}] = ode45(vdp, [0 100], [0 -NUM_LINES/4 + i/2]);
end
% endfor

% Plot the results
CM = copper(NUM_LINES);
plot(x1,x2,'linewidth',3);
axis([-3 3 -3 3]);
for i = 1:NUM_LINES
    hold on;
    plot(states{i}(:,1), states{i}(:,2), 'color', CM(i,:));
    axis([-3 3 -3 3]);
    xlabel('X1');
    ylabel('X2');
    grid on;
end