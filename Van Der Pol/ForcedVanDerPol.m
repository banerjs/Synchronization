function [ nX ] = ForcedVanDerPol (X, E, dT, U)
%ForcedVanDerPol is a function to evaluate the new state given a Van Der
%Pol oscillator
%   X is the current state
%   E is the epsilon in the equation
%   dT is the time step of the equation
%   U is the amount of force delivered by the forcing function

if ~exist('U', 'var')
    U = 0;
end

F = 1 - X(1)^2;

S = X(1) + X(2)*dT;
T = X(2) - X(1)*dT + E*X(2)*F*dT + U*dT;

nX = [S; T];

end