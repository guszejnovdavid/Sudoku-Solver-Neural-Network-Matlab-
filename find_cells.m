%Find vertical and horizontal lines in figure, use them to identify cells

function Cells = find_cells(BinaryImage,OrigImage,sudoku_options)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Find lines
    
[H_Refs,  V_Refs]=find_lines(BinaryImage,sudoku_options.Find_Line_Threshold);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Get cells

N_H_lines=length(H_Refs.Ind);
N_V_lines=length(V_Refs.Ind);
if mod(N_H_lines,3)~=1 || mod(N_V_lines,3)~=1
    disp('Error! Wrong number of lines!');
end
NCells=(N_H_lines-1)*(N_V_lines-1);
%Output Cells structure
%Cells.Puzzle_Ind=zeros(1,NCells); %which puzzle is it part of
Cells.HBorders=zeros(NCells,2); %horizontal borders
Cells.VBorders=zeros(NCells,2); %horizontal borders
Cells.IsEmpty=true(1,NCells); %is there a number there?
Cells.Value=zeros(1,NCells); %value of number (to be filled in by CNN)

index=0;
for i=1:(N_H_lines-1)
    for j=1:(N_V_lines-1)
        index=index+1;
        %Cells.Puzzle_Ind(index)=1+fix((i-1)/3)+fix((j-1)/3)*N_V_lines/3;
        Cells.HBorders(index,:)=[H_Refs.Max(i)+1, H_Refs.Min(i+1)-1];
        Cells.VBorders(index,:)=[V_Refs.Max(j)+1, V_Refs.Min(j+1)-1];
        %Check if it is empty
        Cell_Image=BinaryImage(Cells.VBorders(index,1):Cells.VBorders(index,2),Cells.HBorders(index,1):Cells.HBorders(index,2));
        ratio1=sum(Cell_Image(:)==1)/length(Cell_Image(:));
        if (ratio1>sudoku_options.EmptyThreshold) && (ratio1<(1-sudoku_options.EmptyThreshold))
            Cells.IsEmpty(index)=false;
        end
    end
end

%Plot cell borders on image
if sudoku_options.PlotCells
    figure;
    imshow(OrigImage);
    title('Cells and boundaries');
    hold on
    
    %Draw horizontal lines
    for i = 1:N_H_lines
         xy = [[1,H_Refs.Min(i)]; [length(OrigImage(:,1)),H_Refs.Min(i)]];
         plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
    end
         %Final line
         xy = [[1,H_Refs.Max(N_H_lines)]; [length(OrigImage(:,1)),H_Refs.Max(N_H_lines)]];
         plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
         
    %Draw vertical lines
    for i = 1:N_V_lines
         xy = [[V_Refs.Min(i),1]; [V_Refs.Min(i),length(OrigImage(:,2))]];
         plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','yellow');
    end
         %Final line
         xy = [[V_Refs.Max(N_V_lines),1]; [V_Refs.Max(N_V_lines),length(OrigImage(:,2))]];
         plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','yellow');
         
    %Denote empty cells
    
    for i = 1:NCells
        if Cells.IsEmpty(i)
            hcoord=mean(Cells.HBorders(i,:));
            vcoord=mean(Cells.VBorders(i,:));
            plot(hcoord,vcoord,'x','LineWidth',2,'Color','red');
        end
    end
    
    printname = ['output/cells'];
    set(gcf,'PaperPositionMode','auto');
    print('-dpng',printname);
    
end


end