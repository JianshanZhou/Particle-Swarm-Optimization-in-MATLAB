function [exitFlag, reasonToStop] = stopPSO(options,state,bestFvalsWindow)
iteration = state.Iteration;

iterationIndex = 1+mod(iteration-1,options.StallIterLimit);
bestFval = bestFvalsWindow(iterationIndex);

% Compute change in fval and individuals in last 'Window' iterations
Window = options.StallIterLimit;
if iteration > Window
    % The smallest fval in the window should be bestFval.
    % The largest fval in the window should be the oldest one in the
    % window. This value is at iterationIndex+1 (or 1).
    if iterationIndex == Window
        % The window runs from index 1:iterationIndex
        maxBestFvalsWindow = bestFvalsWindow(1);
    else
        % The window runs from [iterationIndex+1:end, 1:iterationIndex]
        maxBestFvalsWindow = bestFvalsWindow(iterationIndex+1);
    end
    funChange = abs(maxBestFvalsWindow-bestFval)/max(1,abs(bestFval));
else
    funChange = Inf;
end

reasonToStop = '';
exitFlag = [];
if state.Iteration >= options.MaxIter
    reasonToStop = getString(message('globaloptim:particleswarm:ExitMaxIter'));
    exitFlag = 0;
elseif toc(state.StartTime) > options.MaxTime
    reasonToStop = getString(message('globaloptim:particleswarm:ExitMaxTime'));
    exitFlag = -5;
elseif (toc(state.StartTime)-state.LastImprovementTime) > options.StallTimeLimit
    reasonToStop = getString(message('globaloptim:particleswarm:ExitStallTimeLimit'));
    exitFlag = -4;
elseif bestFval <= options.ObjectiveLimit
    reasonToStop = getString(message('globaloptim:particleswarm:ExitObjectiveLimit'));
    exitFlag = -3;
elseif state.StopFlag
    reasonToStop = getString(message('globaloptim:particleswarm:ExitOutputPlotFcn'));
    exitFlag = -1;
elseif funChange <= options.TolFunValue
    reasonToStop = getString(message('globaloptim:particleswarm:ExitTolFun'));    
    exitFlag = 1;
end

if ~isempty(reasonToStop)
    fprintf('%s\n',reasonToStop);
    return
end

end