%% Preparation
clear
close all
clc

%% Test the objective function
inputs = [1.0, 2.];
z = ObjectiveFunc2(inputs);

%% Plot
xmin = -4;
xmax = 4;

[X,Y] = meshgrid(linspace(xmin,xmax,100), linspace(xmin,xmax,100));
Z = zeros(size(X));
[rn,cn] = size(X);
for i = 1:rn
    for j = 1:cn
        inputs = [X(i,j);Y(i,j)];
        Z(i,j) = ObjectiveFunc2(inputs);
    end
end
figure
surf(X,Y,Z);


%% PSO in MATLAB
% Specify the number of decision variables in optimization problem.
nvars = 2; % choose any even value for nvars

% Opt Obj
fun = @ObjectiveFunc2;

% boud conditions
% -4<= x1<= 4
% -5 <= x2 <= 6
lb = [-4;-5];
ub = [4; 6];

options = optimoptions('particleswarm');
options.SwarmSize = 300;
options.Display = 'iter';

%%
[x, fval] = particleswarm(fun,nvars,lb,ub,options);
%%
hold on
plot3(x(1),x(2),fval,'ro','MarkerSize', 10, 'MarkerFaceColor', 'r');
hold off








