%Find vertical and horizontal lines in figure, use them to identify cells

function export_cells(Cells,BinaryImage,sudoku_options)


for i=1:length(Cells.IsEmpty)
    if(~Cells.IsEmpty(i))
        Cell_Image=BinaryImage(Cells.VBorders(i,1):Cells.VBorders(i,2),Cells.HBorders(i,1):Cells.HBorders(i,2));
        %Find edge lines and remove them
            %horizontal
        h1=find(sum(Cell_Image,1)>0.5*size(Cell_Image,1),1,'first');
        h2=find(sum(Cell_Image,1)>0.5*size(Cell_Image,1),1,'last');
        if h1~=1
            Cell_Image(:,1:(h1-1))=1;
        end
        if h2~=size(Cell_Image,1)
            Cell_Image(:,(h2+1):size(Cell_Image,1))=1;
        end
            %vertical
        v1=find(sum(Cell_Image,2)>0.5*size(Cell_Image,2),1,'first');
        v2=find(sum(Cell_Image,2)>0.5*size(Cell_Image,2),1,'last');
        if v1~=1
            Cell_Image(1:(v1-1),:)=1;
        end
        if v2~=size(Cell_Image,1)
            Cell_Image((v2+1):size(Cell_Image,1),:)=1;
        end
        %Plot and export
        figure(42);
        imshow(Cell_Image);
        printname = ['output/components/',num2str(i)];
        set(gcf,'PaperPositionMode','auto');
        print(42,'-dpng',printname);
    end
end
    
close(42);
    
end