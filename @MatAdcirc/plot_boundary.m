% PLOT_BOUNDARY Plots the boundary of the ADCIRC mesh.
%
%   plot_boundary(obj, axes_h) plots the boundary of the ADCIRC mesh
%   associated with the AdcircFile14 object. The boundary is drawn on
%   the specified axes handle.
%
%   Inputs:
%       obj     - An instance of the AdcircFile14 class containing the
%                 ADCIRC mesh data.
%       axes_h  - Handle to the axes where the boundary will be plotted.
%
%   Example:
%       adcircFile = AdcircFile14('mesh.14');
%       figure;
%       ax = axes;
%       adcircFile.plot_boundary(ax);
%
%   See also: AdcircFile14
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
