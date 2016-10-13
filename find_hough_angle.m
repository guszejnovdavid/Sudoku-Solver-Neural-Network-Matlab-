%Finds the orientation of images using Hough transform

function [HAngle] = find_hough_angle(binaryImage,sudoku_options)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hough Transform
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
thetavalues=-40:sudoku_options.HoughThetaRes:40;
[H,theta,rho] = hough(binaryImage,'RhoResolution',sudoku_options.HoughRhoRes ,'Theta', thetavalues);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hough Transform Peaks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
HPeaks = houghpeaks(H,sudoku_options.HoughNLines);
HThetaPeaks = theta(HPeaks(:,2));
HRhoPeaks = rho(HPeaks(:,1));

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hough Transform Orientation Angle
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
HAngle = 0 - median(HThetaPeaks);
if HAngle == 180
  HAngle = 0;
end
if HAngle > 90
  HAngle = HAngle - 180;
end

disp(['Rotation angle: ' num2str(HAngle)]);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hough Transform Plot
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if sudoku_options.doHoughTransformPlot
  figure;
  ax1 = subplot(2,1,1);
  set(gcf,'Position',[800 100 500 800]);
  % Hough transform
  imshow(imadjust(mat2gray(H)),[],...
    'XData',theta,...
    'YData',rho,...
    'InitialMagnification','fit');
  xlabel('\theta (degrees)');
  ylabel('\rho');
  axis on;
  axis normal;
  hold on;
  colormap(hot);
  % Peaks
  plot(HThetaPeaks,HRhoPeaks,'s','color','black');
  
  % Histogram of peaks
  subplot(2,1,2);
  hist(HThetaPeaks,60);
  xlim(ax1.XLim);
  xlabel('\theta (degrees)');
  ylabel('Number of peaks');
  
  printname = ['output/houghtransform'];
  set(gcf,'PaperPositionMode','auto');
  print('-dpng',printname);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Hough Transform Plot with Peak Lines
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if sudoku_options.doHoughLinesImage
  % Get Hough Peak Lines
  lines = houghlines(binaryImage,theta,rho,HPeaks,'FillGap',5,'MinLength',5);
  
  % Original image
  figure;
  set(gcf,'Position',[0 0 500 800]);
  imshow(binaryImage);
  title('Original Image');
  
  % Image with peaks
  figure;
  set(gcf,'Position',[0 600 500 800]);
  imshow(binaryImage);
  title('Original Image with Hough Peak Lines');
  hold on
  
  for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    plot(xy(:,1),xy(:,2),'LineWidth',2,'Color','green');
    
    % Plot beginnings and ends of lines
    plot(xy(1,1),xy(1,2),'x','LineWidth',2,'Color','yellow');
    plot(xy(2,1),xy(2,2),'x','LineWidth',2,'Color','red');
  end
  
  printname = ['output/houghlines'];
  set(gcf,'PaperPositionMode','auto');
  print('-dpng',printname);
end

end
