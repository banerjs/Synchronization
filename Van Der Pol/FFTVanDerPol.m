function [f,power, n] = FFTVanDerPol(tlim, t, states)
% FFTVANDERPOL is a function that performs an fft on a van der pol
% simulation that has just been run. It takes in the time stamps and the
% states that correspond to various timestamps.

SAMPLE_FREQ = 10; % Set a constant for the sampling frequency

ti = tlim(1):1/SAMPLE_FREQ:tlim(2)-1/SAMPLE_FREQ; % Interpolated time vector
xi = interp1(t,states,ti,'spline'); % Interpolated states
m = length(xi);    % Window size
n = 2^nextpow2(m); % Get nearest FFT window size
freqs = fft(xi(:,1),n); % Get the FFT of the signal
f = (0:n-1)*(SAMPLE_FREQ/n); % Create the X axis for freq plot
power = freqs.*conj(freqs)/n; % Get the power of a frequency

end