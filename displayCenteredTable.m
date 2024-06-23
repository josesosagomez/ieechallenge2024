function displayCenteredTable(T)
    % Get the number of rows and columns
    [numRows, numCols] = size(T);
    % Prepare a format specifier for each column based on its width
    colWidths = zeros(1, numCols);
    for i = 1:numCols
        colData = T{:, i};
        if i == 1
            colWidths(i) = max(cellfun(@length, colData));
        else
            colWidths(i) = max(cellfun(@(x) length(num2str(x)), num2cell(colData)));
        end

        colWidths(i) = max(colWidths(i), length(T.Properties.VariableNames{i}));
    end
    % Create the header
    header = '';
    colWidths = [20,20,20];
    for i = 1:numCols
        header = [header, pad(T.Properties.VariableNames{i}, colWidths(i), 'both'), ' | '];
    end
    fprintf("\n");
    disp("-----------------------------------------------------------------------------");
    disp(header);
    disp("-----------------------------------------------------------------------------");
    % Print each row
    colWidths = [23,23,23];
    for j = 1:numRows
        rowStr = '';
        for i = 1:numCols
            cellData = T{j, i};
            if i == 1
                formattedData = cellData{1};
            else
                formattedData = num2str(cellData);
            end
            rowStr = [rowStr, pad(formattedData, colWidths(i), 'both'), '   '];
        end
        disp(rowStr);
    end
    disp("-----------------------------------------------------------------------------");
    fprintf("\n");
end