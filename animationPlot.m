%% Do animation
close
clc

figure
contourf(X,Y,Z, 'LineWidth',1,'LineColor','k','LineStyle',':');
xlabel("$x_1$", 'Interpreter','latex', 'FontSize',18);
ylabel("$x_2$", 'Interpreter','latex', 'FontSize',18);
c = colorbar('eastoutside');
c.Label.String = '$f([x_1,x_2])$';
c.Label.Interpreter = 'Latex';
c.Label.FontSize = 18;
Xcol = X(:);
Ycol = Y(:);
[zOpt,indOpt] = min(Z(:));
xOpt = Xcol(indOpt);
yOpt = Ycol(indOpt);
title(['Global Opt. point: [', num2str(xOpt), ...
    ',',num2str(yOpt),'] with Opt. Value: ', num2str(zOpt)],...
    'FontSize',11,'FontName','Times New Roman');

hold on
plotHandle = plot(output.PStrajectory{1}(:,1),...
    output.PStrajectory{2}(:,1),...
    'bo','MarkerSize', 6, 'MarkerFaceColor', 'r');
hold off
axis manual
iterNum = size(output.PStrajectory{1},2);
f = getframe;
[im,map] = rgb2ind(f.cdata,256,'nodither');
im(1,1,1,iterNum) = 0;
for k = 2:iterNum
    plotHandle.XData = output.PStrajectory{1}(:,k);
    plotHandle.YData = output.PStrajectory{2}(:,k);
    drawnow; 
    f = getframe;
    im(:,:,1,k) = rgb2ind(f.cdata,map,'nodither');
    pause(0.25);
%     drawnow limitrate
end
imwrite(im,map,'PSOdemo.gif','DelayTime',0,'LoopCount',inf) %g443800