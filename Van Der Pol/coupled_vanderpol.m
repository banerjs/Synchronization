%%COUPLED_VANDERPOL.m
% This is a simulation script for coupled Van Der Pol Oscillators with
% different natural frequencies of oscillation

% Set the global variable
global juggler_simulated;
if isempty(juggler_simulated) || juggler_simulated == 0
    clear all; clc;
    c_X1 = [0.01; 0];
    c_E1 = 100;
    c_X2 = [1; 1];
    c_E2 = 1;
    c_delta = 0.5;
    ANALYZE_FREQ = 1;
    SAMPLE_FREQ = 10;
    juggler_simulated = 0;
end

% Set the timing parameters
T = 1000; % Set the total time for the simulation
tspan = [0, T]; % Set the span for the ODE solver

% Set the initial conditions
X1 = c_X1; % State of the equation 1
E1 = c_E1; % Epsilon 1
X2 = c_X2; % State of the equation 2
E2 = c_E2; % Epsilon 2
delta = c_delta; % Forcing parameter
X = [X1; X2]; % Create a comprehensive state variable for the MATLAB solver

% Create the coupled van der pol equation
cvdp = @(t,y) ([y(2); E1*(1-y(1)^2)*y(2)-y(1)+delta*(y(1)-y(3)); y(4); E2*(1-y(3)^2)*y(4)-y(3)+delta*(y(3)-y(1))]);

% Use the built in ODE solver to solve the equations
[t,states] = ode15s(cvdp, tspan, X);
states1 = states(:,1:2);
states2 = states(:,3:4);

% Code for euler implementation of van der Pol
% ts = 20*T; % Set the time step for the simulation
% t = 0:T/ts:T; % Create the time array
% % Create the plot parameters
% states1 = zeros(2, ts+1);
% states2 = zeros(2, ts+1);
% 
% % For loop
% for a = 1:ts+1
%     states1(:,a) = X1;
%     states2(:,a) = X2;
%     nX1 = ForcedVanDerPol(X1, E1, T/ts, delta*(X1(1)-X2(1)));
%     nX2 = ForcedVanDerPol(X2, E2, T/ts, delta*(X2(1)-X1(1)));
%     X1 = nX1;
%     X2 = nX2;
% end
% % endfor

% Plot the graphs if not the subordinate
if juggler_simulated == 0
    figure;
    subplot(2,2,1);
    plot(states1(:,1), states1(:,2));
    title(['Phase Portrait, Epsilon 1 = ', num2str(E1)]);
    subplot(2,2,2);
    plot(t, states1(:,1), t, states2(:,1));
    title(['Delta = ', num2str(delta)]);
    subplot(2,2,3);
    plot(states2(:,1), states2(:,2));
    title(['Phase Portrait, Epsilon 2 = ', num2str(E2)]);
    subplot(2,2,4);
    plot(states1(:,1), states2(:,1), 'r');
    title('Combined Phase Portrait');
    
    % Do a frequency analysis
    if ANALYZE_FREQ == 1
        ti = tspan(1):1/SAMPLE_FREQ:tspan(2)-1/SAMPLE_FREQ; % Interpolated time vector
        xi1 = interp1(t,states1,ti,'spline'); % Interpolated states
        m = length(xi1);    % Window size
        n = 2^nextpow2(m); % Get nearest FFT window size
        freqs1 = fft(xi1(:,1),n); % Get the FFT of the signal
        f1 = (0:n-1)*(SAMPLE_FREQ/n); % Create the X axis for freq plot
        power1 = freqs1.*conj(freqs1)/n; % Get the power of a frequency
        figure;
        plot(f1(1:floor(n/2)), power1(1:floor(n/2)));
        xlabel('Frequency (Hz)');
        ylabel('Power');
        
        xi2 = interp1(t,states2,ti,'spline'); % Interpolated states
        m = length(xi2);    % Window size
        n = 2^nextpow2(m); % Get nearest FFT window size
        freqs2 = fft(xi2(:,1),n); % Get the FFT of the signal
        f2 = (0:n-1)*(SAMPLE_FREQ/n); % Create the X axis for freq plot
        power2 = freqs2.*conj(freqs2)/n; % Get the power of a frequency
        figure;
        plot(f2(1:floor(n/2)), power2(1:floor(n/2)));
        xlabel('Frequency (Hz)');
        ylabel('Power');
                
        disp(num2str([f1(power1 > 1000)*2*pi; power1(power1 > 1000)']));
        disp(num2str([f2(power2 > 1000)*2*pi; power2(power2 > 1000)']));
    end
end