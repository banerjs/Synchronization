function X_dot = MultipleVanDerPol(t,X,E,A,delta,N,F)
%MultipleVanDerPol is a version of ForcedVanDerPol that has been written
%for the purpose of MATLAB ODE solvers, and for multiple(N) osciillators
% The arguments to this function are:
%   t = Time points
%   X = Current state. Top half is position, later half is velocity
%   E = Vector of epsilons for the equation
%   A = Adjacency matrix for the oscillators
%   delta = Effect of multiple oscillators
%   N = Number of oscillators
%   F = Forcing function (optional)
%   X_dot = Differential of the state vector

if ~exist('F', 'var')
    F = 0;
end

ps = 1; pe = N;
vs = N+1; ve = 2*N;

X_dot = [X(vs:ve); (E.*(1-X(ps:pe).^2).*X(vs:ve))-X(ps:pe)+delta.*(A*X(ps:pe))+F];

end