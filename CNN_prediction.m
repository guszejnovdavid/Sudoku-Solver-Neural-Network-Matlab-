function Values=CNN_prediction(IsEmpty,sudoku_options)

%Uses Convolution Neural Network (CNN) to find values of numbers in the
%exported figures

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Load trained CNN or train ne if it does not exist
cnnMatFile = fullfile('Trained_CNN_classifier.mat');
if ~exist(cnnMatFile, 'file')
    disp('Classifier not avaiéable, training new one...');
    train_CNN(); %Train
end
load(cnnMatFile);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Predict Image values

Values=zeros(1,81); %assuming 3x3x3 Sudoku
for i=1:length(Values) %all cells
    %construct filename
    filename = fullfile('output','components', [num2str(i) '.png']);
    if exist(filename, 'file') && ~IsEmpty(i) 
        % Pre-process the images as required for the CNN
        img = readAndPreprocessImage(filename);
        % Extract image features using the CNN
        imageFeatures = activations(convnet, img, featureLayer);
        % Make a prediction using the classifier
        label = predict(classifier, imageFeatures);
        %Convert to numerical value
        Values(i)=label; 
    end
end

disp('Numerical values assigned');


end
