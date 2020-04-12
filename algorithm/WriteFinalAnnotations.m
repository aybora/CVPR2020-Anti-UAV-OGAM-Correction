
clear all
close all
clc

mainDir = '/Users/kutalmisince/Downloads/sacmalamalar/';


subDirectories = {'green', 'red','cyan', 'yellow'};


for s = 1 : length(subDirectories)

    % select the annotation file to be used
    if s == 1,      annotationFile = 'annotationPass0.mat';
    elseif s == 2,  annotationFile = 'annotationPass1.mat';
    else            annotationFile = 'annotationPass2.mat';
    end
    
    % set subDirectory
    myDir = [mainDir '' subDirectories{s}];
    
    % get the directory list
    dirList  = dir(myDir);

    % initate folder list
    folders = cell(length(dirList), 1);

    % set number of folders
    numFolders = 0;

    % get data folders
    for i = 1 : length(dirList)
        
        disp([num2str(s) ', ' num2str(i)])
        evalDir = [myDir '/' dirList(i).name];

        if dirList(i).name(1) == '.' || ~isdir(evalDir), continue; end

        annotationInit = load([evalDir '/' annotationFile]);

        if s ~= 4
            center = annotationInit.center;
            bbox = annotationInit.bbox;
            marked = annotationInit.marked;
        else
            center = annotationInit.centerRaw;
            bbox = annotationInit.bboxRaw;
            marked = annotationInit.marked;
        end

        save([evalDir '/annotation.mat'], 'center', 'bbox', 'marked');
        
        annotation.center = center;
        annotation.bbox = bbox;
        annotation.marked = marked;
        
        DisplayOrRecordVisualResults([evalDir '/'], 'FinalAnnotation.avi', annotation, [], 0);
    
    end
end
