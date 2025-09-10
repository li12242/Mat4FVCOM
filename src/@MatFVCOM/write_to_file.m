%------------------------------------------------------------------------------
% write FVCOM input files
%------------------------------------------------------------------------------
function write_to_file(obj)
  casename = obj.casename;
  output_folder = pwd;
  % dump to file

  write_depth_file(obj, output_folder, casename);
  write_grid_file(obj, output_folder, casename);
  write_obc_file(obj, output_folder, casename);
  write_cor_file(obj, output_folder, casename);
  write_sigma_file(obj, output_folder, casename, 'Uniform', 10);
  write_sponge_file(obj, output_folder, casename)
end

%------------------------------------------------------------------------------
% write *_dep.dat file
%------------------------------------------------------------------------------
function write_depth_file(obj, input_folder, casename)
  filename = strcat(input_folder, filesep, casename, '_dep.dat');
  fprintf('writing FVCOM depth file: %s\n', filename);

  % Dump the file
  file_h = fopen(filename, 'w');
  fprintf(file_h, 'Node Number = %d\n', obj.Nv);

  for i = 1:obj.Nv
    fprintf(file_h, '%f %f %f\n', obj.x(i), obj.y(i), obj.h(i));
  end

  fclose(file_h);

end % function

%------------------------------------------------------------------------------
% write *_grd.dat file
%------------------------------------------------------------------------------
function write_grid_file(obj, input_folder, casename)
  filename = strcat(input_folder, filesep, casename, '_grd.dat');
  fprintf('writing FVCOM grid file: %s\n', filename);

  file_h = fopen(filename, 'w');
  fprintf(file_h, 'Node Number = %10d\n', obj.Nv);
  fprintf(file_h, 'Cell Number = %10d\n', obj.Ne);

  for i = 1:obj.Ne
    fprintf(file_h, '%12d %12d %12d %12d %12d\n', i, obj.triangle_topology(i, 1:3), i);
  end

  for i = 1:obj.Nv
    fprintf(file_h, '%12d %f %f %f\n', i, obj.x(i), obj.y(i), obj.h(i));
  end

  fclose(file_h);

end % function

%------------------------------------------------------------------------------
% write *_obc.dat file
%------------------------------------------------------------------------------
function write_obc_file(obj, input_folder, casename)
  filename = strcat(input_folder, filesep, casename, '_obc.dat');
  fprintf('writing FVCOM obc file: %s\n', filename);

  % dump to file
  file_h = fopen(filename, 'w');
  Nboc = numel(obj.open_boundary);

  if (Nboc == 0)
    fprintf(file_h, 'OBC boundary number = %d\n', 0);
  else

    total_obn_num = length(unique([obj.open_boundary(:).vertex]));
    fprintf(file_h, 'OBC Node Number = %d\n', total_obn_num);
    vertex_id = 0;
    for i = 1:Nboc
      for j = 1:numel(obj.open_boundary(i).vertex)
        vertex_id = vertex_id + 1;
        fprintf(file_h, '%d %d %d\n', vertex_id, ...
          obj.open_boundary(i).vertex(j), ...
          obj.open_boundary(i).type ...
        );
      end
    end

  end
  fprintf(file_h, '\n');
  fclose(file_h);
end % function

%------------------------------------------------------------------------------
% Dump coriolis file
%------------------------------------------------------------------------------
function write_cor_file(obj, input_folder, casename)
  filename = strcat(input_folder, filesep, casename, '_cor.dat');
  fprintf('writing FVCOM cor file: %s\n', filename);

  file_h = fopen(filename, 'w');
  fprintf(file_h, 'Node Number = %d\n', obj.Nv);

  for i = 1:obj.Nv
    fprintf(file_h, '%f %f %f\n', obj.x(i), obj.y(i), obj.lat(i));
  end

  fclose(file_h);

end % function

%------------------------------------------------------------------------------
% Dump sigma file
%------------------------------------------------------------------------------
function write_sigma_file(obj, input_folder, casename, varargin)
  % write sigma file
  % INPUT:
  %
  %
  if (nargin == 3)
    type = 'Uniform';
    nsiglev = 10;
  else
    type = varargin{1};
    nsiglev = varargin{2};
  end

  filename = strcat(input_folder, filesep, casename, '_sigma.dat');

  % dump to *_sigma.dat file
  file_h = fopen(filename, 'w');
  fprintf(file_h, '%s %d\n', 'NUMBER OF SIGMA LEVELS = ', nsiglev);

  switch type
    case 'Uniform'
      fprintf(file_h, '%s\n', 'SIGMA COORDINATE TYPE = UNIFORM');
  end

  fclose(file_h);
end % function

%------------------------------------------------------------------------------
% Dump sigma file
%------------------------------------------------------------------------------
function write_sponge_file(obj, input_folder, casename)
  filename = strcat(input_folder, filesep, casename, '_spg.dat');
  fprintf('writing FVCOM sponge file: %s\n', filename);

  % dump to file
  file_h = fopen(filename, 'w');
  Nboc = numel(obj.open_boundary);

  if (Nboc == 0)
    fprintf(file_h, 'Sponge Node Number = %d\n', 0);
  else

    total_obn_num = length(unique([obj.open_boundary(:).vertex]));
    fprintf(file_h, 'Sponge Node Number = %d\n', total_obn_num);

    for i = 1:Nboc
      for j = 1:numel(obj.open_boundary(i).vertex)
        fprintf(file_h, '%d %f %f \n', ...
          obj.open_boundary(i).vertex(j), ...
          obj.open_boundary(i).radius(j), ...
          obj.open_boundary(i).coeff(j));
      end
    end

  end
  fprintf(file_h, '\n');
  fclose(file_h);
end % function
