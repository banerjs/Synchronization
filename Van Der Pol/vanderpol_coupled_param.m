% This is a wrapper around the forced Van der Pol simulation and sets the
% parameters for the forcing function

clear all; clc;

% Set the global variable
global juggler_simulated;
juggler_simulated = 1;

% Set initial positions of both oscillators
c_X1 = [0.1; -0.1];
c_X2 = [0.1; -0.1];

% Vary the epsilons of both oscillators
e1limit = 0;
e2limit = 2;
e1 = 10.^(-e1limit:1:e1limit);
e2 = 10.^(-e2limit:1:e2limit);

% Vary the delta
dlimit = -0.3;
d = -0.3; %0:-0.1:dlimit;

% For loop for the simulation
for i = 1:size(e1,2)
    for j = 1:size(e2,2)
        for k = 1:size(d,2)
            c_E1 = e1(i); c_E2 = e2(j);
            c_delta = d(k);
            coupled_vanderpol;
            
            % Create Plot varaiables
            s = size(t,1);
            if s > 1000
                low = floor(s/2);
                high = low + floor(s/8);
            else
                low = 1;
                high = s;
            end
            
            
            % Plot the functions
            figure;
            subplot(2,2,1);
            plot(states1(:,1), states1(:,2));
            title(['Phase Portrait, Epsilon = ', num2str(c_E1)]);
            subplot(2,2,2);
            plot(t(low:high), states1(low:high,1));
            title(['Delta = ', num2str(c_delta)]);
            subplot(2,2,3);
            plot(states2(:,1), states2(:,2));
            title(['Phase Portrait, Epsilon = ', num2str(c_E2)]);
            subplot(2,2,4);
            plot(t(low:high), states2(low:high,1));
            title(['Delta = ', num2str(c_delta)]);
        end
        reply = input('Do you want more [0/1]: ');
        if reply == 0
            break;
        end
    end
end
% endfor
