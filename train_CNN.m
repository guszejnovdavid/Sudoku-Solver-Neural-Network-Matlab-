function train_CNN()
%Trains a Convolution Neural Network (CNN) to identify numbers, based on
%AlexNet CNN



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load Images

%Define image folder
rootFolder = fullfile('output\training');
%Categories
categories = {'1', '2','3', '4', '5','6', '7', '8', '9'};

% Create an ImageDatastore to help you manage the data. Because ImageDatastore operates 
% on image file locations, images are not loaded into memory until read, making it efficient
% for use with large image collections.

imds = imageDatastore(fullfile(rootFolder, categories), 'LabelSource', 'foldernames');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Download Pre-trained Convolutional Neural Network (CNN)
    
% Location of pre-trained "AlexNet"
cnnURL = 'http://www.vlfeat.org/matconvnet/models/beta16/imagenet-caffe-alex.mat';
% Store CNN model in a project folder
cnnMatFile = fullfile('imagenet-caffe-alex.mat');

if ~exist(cnnMatFile, 'file') % download only once
    disp('Downloading pre-trained CNN model...');
    websave(cnnMatFile, cnnURL);
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Load Pre-trained CNN
    
% Load MatConvNet network into a SeriesNetwork
convnet = helperImportMatConvNet(cnnMatFile);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    %Pre-process Images For CNN

% As mentioned above, convnet can only process RGB images that are 227-by-227. To avoid 
% re-saving all the images to this format, setup the imds read function, 
% imds.ReadFcn, to pre-process images on-the-fly. The imds.ReadFcn is called every time an
% image is read from the ImageDatastore.

% Set the ImageDatastore Read function
imds.ReadFcn = @(filename)readAndPreprocessImage(filename);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Prepare Training and Test Image Sets

%30% of data for training, 70% for testing, random selection
[trainingSet, testSet] = splitEachLabel(imds, 0.3, 'randomize');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Extract Training Features Using CNN
    
% Each layer of a CNN produces a response, or activation, to an input image. However,
% there are only a few layers within a CNN that are suitable for image feature extraction. 
% The layers at the beginning of the network capture basic image features, such as edges and
% blobs. These "primitive" features are then processed by deeper network layers, which 
% combine the early features to form higher level image features. These higher level features 
% are better suited for recognition tasks because they combine all the primitive features into
% a richer image representation.

% You can easily extract features from one of the deeper layers using the activations method. 
% Selecting which of the deep layers to choose is a design choice, but typically starting with
% the layer right before the classification layer is a good place to start. In convnet, the this 
% layer is named 'fc7'. Let's extract training features using that layer.

featureLayer = 'fc7';
trainingFeatures = activations(convnet, trainingSet, featureLayer, ...
    'MiniBatchSize', 32, 'OutputAs', 'columns');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    %Train A Multiclass SVM Classifier Using CNN Features

% Next, use the CNN image features to train a multiclass SVM classifier. A fast 
% Stochastic Gradient Descent solver is used for training by setting the fitcecoc
% function's 'Learners' parameter to 'Linear'. This helps speed-up the training
% when working with high-dimensional CNN feature vectors, which each have a
% length of 4096.

% Get training labels from the trainingSet
trainingLabels = trainingSet.Labels;

% Train multiclass SVM classifier using a fast linear solver, and set
% 'ObservationsIn' to 'columns' to match the arrangement used for training
% features.
classifier = fitcecoc(trainingFeatures, trainingLabels, ...
    'Learners', 'Linear', 'Coding', 'onevsall', 'ObservationsIn', 'columns');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%5
    %Evaluate Classifier
    
% Repeat the procedure used earlier to extract image features from testSet. 
% The test features can then be passed to the classifier to measure the accuracy 
% of the trained classifier.
    
% Extract test features using the CNN
testFeatures = activations(convnet, testSet, featureLayer, 'MiniBatchSize',32);

% Pass CNN image features to trained classifier
predictedLabels = predict(classifier, testFeatures);

% Get the known labels
testLabels = testSet.Labels;

% Tabulate the results using a confusion matrix.
confMat = confusionmat(testLabels, predictedLabels);

% Convert confusion matrix into percentage form
disp('Confidence matrix:');
confMat = bsxfun(@rdivide,confMat,sum(confMat,2))
    
% Display the mean accuracy
disp(['Mean accuracy of classifier: ' num2str(mean(diag(confMat))) ]);


%Save the newly trained classifier
save('Trained_CNN_classifier.mat','convnet','featureLayer','classifier' )
disp(['Newly trained CNN classifier saved as Trained_CNN_classifier.mat']);


end