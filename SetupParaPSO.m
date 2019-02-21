function options = SetupParaPSO(nvars)
options = struct;

% Initialize the swarm size
options.SwarmSize = min(100,10*nvars);

% Set the maximum iteration number
options.MaxIter = nvars*200;
options.MaxTime = Inf;

% Set initial swarm span
options.InitialSwarmSpan = repmat(2000, 1, nvars);

options.InertiaRange = [0.1,1.1];
options.MinFractionNeighbors = 0.25;

options.SelfAdjustment = 1.49;
options.SocialAdjustment = 1.49;

options.StallIterLimit = 20;
options.StallTimeLimit = Inf;

options.TolFunValue = 1.e-06;
options.TolFun = 1.e-06;
options.ObjectiveLimit = -Inf;

end