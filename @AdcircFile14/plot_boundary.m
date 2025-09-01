% plot boundary to specific axes
% 
function plot_boundary(obj, axes_h)
    set(axes_h, 'NextPlot', 'add')

    % 绘制开边界
    for i = 1:length(obj.boundary.open)
        idx = obj.boundary.open{i};
        plot(axes_h, obj.coordiantes(idx, 1), obj.coordiantes(idx, 2), 'b')
    end

    % 绘制陆地边界
    for i = 1:length(obj.boundary.land)
        idx = obj.boundary.land{i};
        plot(axes_h, obj.coordiantes(idx, 1), obj.coordiantes(idx, 2), 'k')
    end

end
