%%ROULETTE_CONVERGE.m
% Try out stochastic matrices in order and check for convergence

clear all; clc;

% Parametes
DIMENSION = 3;
NUM_MATRICES = 8;
A = zeros(DIMENSION,DIMENSION,NUM_MATRICES);

% Simulation Params
MULTIPLY = 20; % Number of times to multiply the matrices
ROULETTE = 2; % 0 -> random, 1 -> cyclical, 2 -> repeated

% Generate matrices
disp('Generated matrices:');
for i = 1:NUM_MATRICES
    A(:,:,i) = stochastic(DIMENSION);
    disp(i); disp(A(:,:,i));
end

% Do the simulation
x = 200.*rand(DIMENSION,1); % Random initial value
B = eye(DIMENSION);
disp('Random Initial Value:'); disp(x');
for i = 1:MULTIPLY
    if ROULETTE == 1
        index = mod(i-1,NUM_MATRICES)+1;
    elseif ROULETTE == 2
        num = MULTIPLY/NUM_MATRICES;
        index = floor(i/num)+1;
        if index > NUM_MATRICES
            index = NUM_MATRICES;
        end
    else
        index = randi(NUM_MATRICES);
    end
    C = A(:,:,index);
    B = B*C;
    x = C*x;
    disp(strcat({'Mutiply by '}, num2str(index), {' yields:'}));
    disp(x);
    disp(B);
end