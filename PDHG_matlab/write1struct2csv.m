function [] = write1struct2csv(filename, title, results_struct, format)
    try
        field = fieldnames(results_struct);
        notitle_flag = false;
        if ~exist(filename,'file')
            notitle_flag = true;
        end
        fileID = fopen(filename, 'a');
        if fileID < 0
            disp('Fail to open file.');
        end

        % write title
        if notitle_flag
            for i = 1:length(title)-1
                fprintf(fileID,'%s,',title(i));
            end
            fprintf(fileID,'%s\n',title(end));
        end
        % write data
            for j = 1:size(field,1)-1
                fprintf(fileID,strcat(format(j),','),results_struct.(field{j}));
            end
            fprintf(fileID,strcat(format(length(title)),'\n'),results_struct.(field{size(field,1)}));
    catch
        fprintf("Fail to write file.\n");
    end
    fclose(fileID);
end