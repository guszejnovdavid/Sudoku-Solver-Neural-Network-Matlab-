function [H_Refs,  V_Refs]=find_lines(BinaryImage, threshold)


% Reference rows are seleected to cover at least 1/3 of the figure
horLineRows = find(sum(BinaryImage,2) < size(BinaryImage,2)*(1-threshold));
% Find minima and maxima of unique rows
H_Refs.Min = find(abs(horLineRows(1:end-1)-horLineRows(2:end))~=1)'+1;
H_Refs.Min = [1 H_Refs.Min];
H_Refs.Min = horLineRows(H_Refs.Min);
H_Refs.Max = find(abs(horLineRows(1:end-1)-horLineRows(2:end))~=1)';
H_Refs.Max = [H_Refs.Max length(horLineRows)];
H_Refs.Max = horLineRows(H_Refs.Max);
H_Refs.Ind = 1:length(H_Refs.Min);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find vertical lines
    
% Reference rows are seleected to cover at least 1/3 of the figure
vertLineRows = (find(sum(BinaryImage,1) < size(BinaryImage,1)*(1-threshold)))';
% Find minima and maxima of unique rows
V_Refs.Min = find(abs(vertLineRows(1:end-1)-vertLineRows(2:end))~=1)'+1;
V_Refs.Min = [1 V_Refs.Min];
V_Refs.Min = vertLineRows(V_Refs.Min);
V_Refs.Max = find(abs(vertLineRows(1:end-1)-vertLineRows(2:end))~=1)';
V_Refs.Max = [V_Refs.Max length(vertLineRows)];
V_Refs.Max = vertLineRows(V_Refs.Max);
V_Refs.Ind = 1:length(V_Refs.Min);

end