function printInfo(state)
fprintf('\n                                 Best            Mean     Stall\n');
fprintf(  'Iteration     f-count            f(x)            f(x)    Iterations\n');
fprintf('%5.0f         %7.0f    %12.4g    %12.4g    %5.0f\n', ...
    0, state.FunEval, min(state.Fvals), mean(state.Fvals), 0);
end