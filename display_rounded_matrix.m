function display_rounded_matrix(matrix, precision, outputFile)
  %precision can be a single number, applied to all, or a 
  %matrix of values to be applied to the columns. 
	%Modified the space_between_columns variable by Gonzalo Rodríguez Prieto (8-Apr-2013)
	%Again mod. space_between_columns (08-Jul-2013)

  space_between_columns = " ";
  format_part = "%10.";

  precision_format = cell(columns(precision), 1);
  for i = 1:columns(precision),
    precision_format{i,1} = strcat(format_part, num2str(precision(1,i)), "f");
  end

  if (nargin == 3 && outputFile != 0)
    if (rows(precision) == 1 && columns(precision) == 1)
      rows = rows(matrix);
      cols = columns(matrix);
      format = strcat(format_part, num2str(precision), "f");
      for i = 1:rows
        for j = 1:cols
          fprintf(outputFile, sprintf(format, matrix(i,j)));
          if (j ~= cols)
            fprintf(outputFile, space_between_columns);
          end
        end
        if i ~= rows
          fprintf(outputFile, "\n");
        end
      end
      fprintf(outputFile, "\n");
    elseif (rows(precision) == 1 && columns(precision) == columns(matrix))
      %here we have to custom make the rounding
      rows = rows(matrix);
      cols = columns(matrix);
      for i = 1:rows
        for j = 1:cols
          fprintf(outputFile, sprintf(precision_format{j,1}, matrix(i,j)));
          if (j ~= cols)
            fprintf(outputFile, space_between_columns);
          end
        end
        if i ~= rows
          fprintf(outputFile, "\n");
        end
      end
      fprintf(outputFile, "\n");
    else
      disp("STOP!, you invoked display_rounded_matrix with bad parameters");
    end

  elseif (nargin == 3 && outputFile == 0)
%print to screen instead

if (rows(precision) == 1 && columns(precision) == 1)
      rows = rows(matrix);
      cols = columns(matrix);
      format = strcat(format_part, num2str(precision), "f");
      for i = 1:rows
        for j = 1:cols
          printf(sprintf(format, matrix(i,j)));
          if (j ~= cols)
            printf(space_between_columns);
          end
        end
        if i ~= rows
          printf("\n");
        end
      end
      printf("\n");
    elseif (rows(precision) == 1 && columns(precision) == columns(matrix))
      %here we have to custom make the rounding
      rows = rows(matrix);
      cols = columns(matrix);
      for i = 1:rows
        for j = 1:cols
          %format = strcat(format_part, num2str(precision(1,j)), "f");
          format = [format_part num2str(precision(1,j)) "f"];
          printf(sprintf(format, matrix(i,j)));
          if (j ~= cols)
            printf(space_between_columns);
          end
        end
        if i ~= rows
          printf("\n");
        end
      end
      printf("\n");
    else
      disp("STOP!, you invoked display_rounded_matrix with bad parameters");
    end

  elseif (nargin == 2)
    display_rounded_matrix(matrix, precision, 0);
  else
    disp("STOP!, you invoked display_rounded_matrix with wrong number of arguments");
  end
end
