% This is the simulation for the Van der Pol

% Set the global variable
global juggler_simulated;
if isempty(juggler_simulated) || juggler_simulated == 0
    clear all; clc;
    c_x = 0.3;
    c_y = 0.1;
    c_E = 1;
    c_amp = 0;
    c_freq = 2.4;
    ANALYZE_FREQ = 1;
    SAMPLE_FREQ = 0;
    juggler_simulated = 0;
end

% Set the timing parameters
T = 2000; % Set the total time for the simulation
tspan = [0, T]; % Set the span for the simulation

% Set the initial conditions
X = [c_x; c_y]; % State of the equation
E = c_E; % Epsilon

% Create the forcing function
amp = c_amp;
freq = c_freq;

% Define the van der Pol differential equation
fvdp = @(t,y) ([y(2); E*(1-y(1)^2)*y(2)-y(1)+(amp.*sin(freq.*t))]);

% Use built in solvers to solve the ODE
[t,states] = ode15s(fvdp, tspan, X);

% The following is for the previous linear implementation of vanderpol
% ts = 20*T; % Set the time step for the simulation
% t = 0:T/ts:T; % Create the time array
%
% forcfunc = @(x) amp*sin(freq*x);
% 
% % Create the plot parameters
% states = zeros(2, ts+1);
% 
% % For loop
% for a = 1:ts+1
%     states(:,a) = X;
%     nX = ForcedVanDerPol(X, E, T/ts, forcfunc(T*a/ts));
%     X = nX;
% end
% % endfor

% Plot the graphs if not the subordinate
if juggler_simulated == 0
    figure;
    subplot(2,1,1);
    plot(states(:,1), states(:,2));
    title(['Phase Portrait, Drive Freq = ', num2str(freq)]);
    subplot(2,1,2);
    plot(t, states(:,1)); %, t, amp*sin(freq.*t));

    % Do a frequency analysis
    if ANALYZE_FREQ == 1
        ti = tspan(1):1/SAMPLE_FREQ:tspan(2)-1/SAMPLE_FREQ; % Interpolated time vector
        xi = interp1(t,states,ti,'spline'); % Interpolated states
        m = length(xi);    % Window size
        n = 2^nextpow2(m); % Get nearest FFT window size
        freqs = fft(xi(:,1),n); % Get the FFT of the signal
        f = (0:n-1)*(SAMPLE_FREQ/n); % Create the X axis for freq plot
        power = freqs.*conj(freqs)/n; % Get the power of a frequency
        figure;
        plot(f(1:floor(n/2)), power(1:floor(n/2)));
        xlabel('Frequency (Hz)');
        ylabel('Power');
    end
end