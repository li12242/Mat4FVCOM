function transfer_to_carthesian(obj, varargin)
    % 转换经纬度坐标为笛卡尔坐标系
    if nargin == 3
        lat0 = varargin{1};
        lon0 = varargin{2};
        fprintf('Set reference lat0 lon0 with given value: (%f, %f)\n', lat0, lon0);
    else
        lat0 = mean(obj.lat);
        lon0 = mean(obj.lon);
        fprintf('Warning: unset lat0 lon0, using mean value: (%f, %f)\n', lat0, lon0);
    end

    % 初始化x, y属性
    obj.x = zeros(size(obj.lat));
    obj.y = zeros(size(obj.lon));

    [obj.x, obj.y] = llh2enu(obj.lat, obj.lon, lat0, lon0);

    % 更新坐标系类型
    obj.native_coords = 'carthesian';
end

function [x, y] = llh2enu(lat, lon, lat0, lon0)
    % Input:
    % lat, lon - 目标点的纬度、经度和高度（WGS84坐标系）
    % lat0, lon0 - 参考点的纬度、经度和高度（WGS84坐标系）
    % Output:
    % x, y - 目标点相对于参考点的东北天坐标

    % 定义WGS84椭球模型
    wgs84 = wgs84Ellipsoid('kilometer');

    % 转换为东北天坐标
    [x, y, ~] = geodetic2enu(lat, lon, 0, lat0, lon0, 0, wgs84);
end
