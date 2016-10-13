function sudoku_solver_main(filename)

%This is a program that solves Sudoku puzzles that are provided in an image
%file
% Algorithm:
% 1. Read picture, convert to binary
% 2. Use Hough transform to find orientation and rotate if necessary
% 3. Find vertical and horizontal lines, identify cells
% 4. Find non-empty cells, export their contents
% 5. Use a neural network to identify the content of non-empty cells (what nu,ber it is)
% 6. Reconstruct the Sudoku matrix and solve it

%Clean up before run
close all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Options
    
%Image
image_path = fullfile(['images/',filename]);
%image_path = 'images/1_rot.jpg';

%Hough transform
sudoku_options.Rotate = 1; %image to be rotated by the angle found by the Hough transform
sudoku_options.HoughRhoRes = 1.0; %resolution of rho value
sudoku_options.HoughThetaRes = 1.0; %resolution of theta angle (degree)
sudoku_options.HoughNLines = 5; %number of horizontal lines to look for
sudoku_options.doHoughTransformPlot = 1; %plot Hough transform of image
sudoku_options.doHoughLinesImage = 1; %plot image with Hough lines

%Finding lines and cells
sudoku_options.PlotCells = 1; %plot image with cells and lines shown
sudoku_options.EmptyThreshold = 0.05; %Max fraction of black in empty cells
sudoku_options.Find_Line_Threshold=0.7; %Minimum length of black lines

sudoku_options.Plot_Solution=1; %plot solution at the end





%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Read image (binary)
    
[BinaryImage, OrigImage] = get_image(image_path);
     
%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Find orientation with Hough transform 
    
% Hough transform & get angle
if sudoku_options.Rotate
  Rotation_Angle = find_hough_angle(~BinaryImage,sudoku_options);
end

% Rotate image if necessary
if Rotation_Angle ~= 0
  OrigImage_old=OrigImage;
  OrigImage = imrotate(OrigImage,-Rotation_Angle,'bicubic','crop');
  OrigImage = imrotate(OrigImage_old,-Rotation_Angle);
  %make background white
  Mrot = ~imrotate(true(size(OrigImage_old)),-Rotation_Angle);
  OrigImage(Mrot&~imclearborder(Mrot)) = 255;
  
  figure;
  imshowpair(OrigImage_old,OrigImage,'montage')
  %less noisy to redo the binary image
  BinaryImage = logical(OrigImage>mean(OrigImage(:)));
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Find horizontal and vertical lines, identify cells

% Get horizontal line reference
%output struct: Cell
%   Cell.HBorders : horizontal borders
%   Cell.VBorders : horizontal borders
%   Cell.IsEmpty  : is it empty?
%   Cell.Value    : if not empty, what is the predicted value by CNN
Cells = find_cells(BinaryImage,OrigImage,sudoku_options);

%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Export cells

export_cells(Cells,BinaryImage,sudoku_options);

%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Call Convolution Neural Network (CNN)
    
Cells.Value=CNN_prediction(Cells.IsEmpty,sudoku_options);

%%%%%%%%%%%%%%%%%%%%%%%%%
    % Create Sudoku matrix and solve it

%create matrix
sudoku_matrix=reshape(Cells.Value(:),[9,9]);
%find solution
solution_matrix = direct_sudoku_solver(sudoku_matrix);

if sudoku_options.Plot_Solution
    %plot original
    figure;
    imshow(OrigImage);
    title('Sudoku Solution');
    hold on
    %Write solution
    for i=1:length(Cells.Value(:))
        if Cells.Value(i)==0
            textstring=num2str(solution_matrix(i));
            hcoord=mean(Cells.HBorders(i,:));
            vcoord=mean(Cells.VBorders(i,:));
            text(hcoord,vcoord,textstring,'Color','red','FontWeight','bold','FontSize', 14);
        end
    end
    printname = ['output/solution'];
    set(gcf,'PaperPositionMode','auto');
    print('-dpng',printname); 
end

end

