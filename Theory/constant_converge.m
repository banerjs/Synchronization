%%CONSTANT_CONVERGE.m
% This script shows the convergence of a contant time matrix given the
% trivial eigenvector corresponding to eigenvalue 1.

clear all; clc;

% Constants
DIMENSION = 4;
v = [1;2;3;4];%ones(DIMENSION,1)/sqrt(DIMENSION);%[1; 2; 1; 1]/sqrt(7);
eV = [v, rand(DIMENSION, DIMENSION-1)];
eVi = inv(eV);
lambda = [[1;zeros(DIMENSION-1,1)],[zeros(1,DIMENSION-1);(eye(DIMENSION-1).*rand(DIMENSION-1))]];
A = eV*lambda*eVi;%v*v';
disp('Matrix:'); disp(A);

% Simulate
init = 200*rand(DIMENSION,1);
disp('Initial conditions ='); disp(init);

fin = init;
ofin = init-1;
while fin ~= ofin
    ofin = fin;
    fin = A*ofin;
    disp(fin);
end