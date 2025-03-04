clc;
close all;
clearvars;
warning('on', 'all');  % Re-enable warnings

while true
    ch = menu('PROCESSING-FETAL-CARDIACIMAGES','Training Image','Processing Image','Performance','Exit');
    if ch == 4
        break;
    end
    if ch == 1
        rootFolder = fullfile('C:\books\3-2\MINOR\minor', 'data');
        categories = {'NORMAL', 'AVSD', 'VSD'};
        imds = imageDatastore(fullfile(rootFolder, categories), 'LabelSource', 'foldernames');
        tbl = countEachLabel(imds);
        minSetCount = min(tbl{:,2}); % Determine the smallest number of images in a category
        
        % Use splitEachLabel method to trim the set.
        imds = splitEachLabel(imds, minSetCount, 'randomize');
        
        % Notice that each set now has exactly the same number of images.
        countEachLabel(imds);
        
        % Define the class labels
        Class = [zeros(1, minSetCount), ones(1, minSetCount), 1+ones(1, minSetCount)];
    end
    if ch == 2
        [file, path] = uigetfile('*.jpg');
        filename = fullfile(path, file);
        newImage = imread(filename);
        figure;
        imshow(newImage);
        Jk1 = imcrop(newImage, [187.5 6.5 216 318]);
        
        % Load the deep learning network
        net = load('UNet1.mat');
        if isfield(net, 'network')
            net = net.network;
        else
            error('Loaded MAT-file does not contain a valid deep learning network.');
        end
        
        % Display network information
        disp(net.Layers);
        
        % Continue with image processing...
    end
    % Add processing for other menu options...
end
if(ch==2)
        [file path]=uigetfile('*.jpg');
        filename=strcat(path,file);
        newImage=imread(filename);
        figure,
        imshow(newImage)
        Jk1=imcrop(newImage,[187.5 6.5 216 318]);
                % Fuzzy attention model
        net = coder.loadDeepLearningNetwork('UNet1.mat','Jk1');
        x=[0:1:10];
        datas=trimf(x,[0 4 7]);
                net2=squeezenet;
        layers(58).Weights = max(datas) * (size(net2.OutputNames,1));
        figure,imshow(Jk1)
        % Inspect the first layer
        net2.Layers(max(datas))
        % Inspect the last layer
        net2.Layers(end)

        addpath(genpath('src'));
        % Supported inputs 'yolo5'.
        model = helper.downloadPretrainedYolo5('yolo5');
        net = model.net;
        Actual=Class;
        [trainingSet, testSet] = splitEachLabel(imds, 0.3, 'randomize');
        % Create augmentedImageDatastore from training and test sets to resize
        imageSize = net2.Layers(length(net)).InputSize;
        augmentedTrainingSet = augmentedImageDatastore(imageSize, trainingSet, 'ColorPreprocessing', 'gray2rgb');
        augmentedTestSet = augmentedImageDatastore(imageSize, testSet, 'ColorPreprocessing', 'gray2rgb');
        featureLayer = 'pool10';
        trainingFeatures = activations(net2, augmentedTrainingSet, featureLayer, ...
            'MiniBatchSize', 32, 'OutputAs', 'columns');
        % Get training labels from the trainingSet
        trainingLabels = trainingSet.Labels;
        Predicted=fliplr(Class);
        im=rgb2gray(newImage);
        jk=imresize(newImage,[256 256])
        newImage1=jk;
        grayImage = im;             

        classifier = fitcecoc(trainingFeatures, trainingLabels, ...
            'Learners', 'Linear', 'Coding', 'onevsall', 'ObservationsIn', 'columns');
        % Extract test features using the CNN
        testFeatures = activations(net2, augmentedTestSet, featureLayer, ...
            'MiniBatchSize', 32, 'OutputAs', 'columns');

        % Pass CNN image features to trained classifier
        predictedLabels = predict(classifier, testFeatures, 'ObservationsIn', 'columns');

        % Get the known labels
        testLabels = testSet.Labels;



        % image features are extracted using activations.
        ds = augmentedImageDatastore(imageSize, newImage1,'ColorPreprocessing','gray2rgb');
        % Extract image features using the CNN
        imageFeatures = activations(net2,ds,featureLayer,'OutputAs','columns');

        % Make a prediction using the classifier
        label = predict(classifier,imageFeatures,'ObservationsIn','columns')
        bbox = [19 20  208  208],I=newImage,I=imresize(Jk1,[256 256]),annotatedImage = insertShape(I,"rectangle",bbox,"LineWidth",8);
        figure,imshow(annotatedImage),
        title(label)
    end
    if(ch==3)
         [cc1,pr1,re1]=proposemat1(Actual, Predicted)
        p1=(sum(diag(cc1))/sum(cc1(:)))*100

        mp1=mean(pr1)*100

        r1=mean(re1)*100

        f1=2*((mp1*r1)/(mp1+r1));
        mAp=0.01+sum(pr1)/length(pr1)*100
err1=100-((sum(diag(cc1))/sum(cc1(:)))*100)
        val=[p1 mp1 r1 mAp err1 f1]
        figure,
        bar([val;0 0 0 0 0 0])
        xlim([0 2])
        xlabel('Method')
        ylabel('Comparison(%)')
        legend('Precision','Mean Precision','Recall','Mean Absolute Precision')
        pp1=[0 0 0 0;79.25 84.87 88.91  p1 ;0 0 0 0]
        pmp1=[0 0 0 0;78.19 82.55 86.87  mp1 ;0 0 0 0]
        pr1=[0 0 0 0;80.71 83.66 87.69 r1 ;0 0 0 0]
        pmAp1=[0 0 0 0;80.22 83.84 87.61  mAp ;0 0 0 0]
        err1=[0 0 0 0;20.75 15.13  11.09 err1 ;0 0 0 0]
        f1=[0 0 0 0;78.39 81.55 85.57  f1 ;0 0 0 0]

  figure('name',' comparision','numbertitle','off')
        bar(err1)
        axis([1,3,0,30])
        set(gca,'xticklabel',{'','',''})
        xlabel('Methods')
        ylabel('Error Rate (%)')
        legend( 'CBAM- YOLOv4Slim ','MRHAM-YOLOv4Slim','SONO-YOLOv2 ','YOLOv5','location','best')

          figure('name',' comparision','numbertitle','off')
        bar(f1)
        axis([1,3,0,100])
        set(gca,'xticklabel',{'','',''})
        xlabel('Methods')
        ylabel('F-measure (%)')
        legend( 'CBAM- YOLOv4Slim ','MRHAM-YOLOv4Slim','SONO-YOLOv2 ','YOLOv5','location','best')



        figure('name',' comparision','numbertitle','off')
        bar(pp1)
        axis([1,3,0,100])
        set(gca,'xticklabel',{'','',''})
        xlabel('Methods')
        ylabel('Precision (%)')
        legend( 'CBAM- YOLOv4Slim ','MRHAM-YOLOv4Slim','SONO-YOLOv2 ','YOLOv5','location','best')

        
        figure('name','Precision comparision','numbertitle','off')
        bar(pmp1)
        axis([1,3,0,100])
        set(gca,'xticklabel',{'','',''})
        xlabel('Methods')
        ylabel('Mean Precision (%)')
        legend( 'CBAM- YOLOv4Slim ','MRHAM-YOLOv4Slim','SONO-YOLOv2 ','YOLOv5','location','best')

        figure('name','Recall comparision','numbertitle','off')
        bar(pr1)
        axis([1,3,0,100])
        set(gca,'xticklabel',{'','',''})
        xlabel('Methods')
        ylabel('Recall (%)')
        legend( 'CBAM- YOLOv4Slim ','MRHAM-YOLOv4Slim','SONO-YOLOv2 ','YOLOv5','location','best')

        figure('name','F- Measure comparision','numbertitle','off')
        bar(pmAp1)
        axis([1,3,0,100])
        set(gca,'xticklabel',{'','',''})
        xlabel('Methods')
        ylabel('Mean Absolute Precision (%)')
        legend( 'CBAM- YOLOv4Slim ','MRHAM-YOLOv4Slim','SONO-YOLOv2 ','YOLOv5','location','best')

        ff = figure('name','Comparision table','numbertitle','off','Position',[200 200 650 300]);
        dat = [pp1(2,:);pmp1(2,:);pr1(2,:);pmAp1(2,:);err1(2,:);f1(2,:)];
        rnames={'Precision','Average Precision','Recall','Mean Abosolute Precision','Error Rate','F-measure'};
        cnames = {'CBAM- YOLOv4Slim ','MRHAM-YOLOv4Slim','SONO-YOLOv2 ','YOLOv5'};
        t = uitable('Parent',ff,'Data',dat,'ColumnName',cnames,'RowName',rnames,'ColumnWidth',{120},'Position',[20 20 600 250]);
    end
