%% Example 1
nvars = 2; % choose any even value for nvars
fun = @dejong5fcn;
lb = [-50;-50];
ub = -lb;
options = optimoptions('particleswarm','SwarmSize',100);
options.SwarmSize = 200;
[x,fval] = particleswarm(fun,nvars,[],[],options)

%% Example 2
nvars = 6; % choose any even value for nvars
fun = @multirosenbrock;
lb = -10*ones(1,nvars);
ub = -lb;
options = optimoptions('particleswarm','MinNeighborsFraction',1);
options.SwarmSize = 200;
options.SelfAdjustmentWeight = 1.9;
x0 = zeros(20,6); % set 20 individuals as row vectors
options.InitialSwarmMatrix = x0; % the rest of the swarm is random
[x,fval] = particleswarm(fun,nvars,[],[],options)
