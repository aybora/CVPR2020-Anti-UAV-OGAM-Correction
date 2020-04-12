
% set the pass number
passNumber = 1;

% set main directory
if passNumber == 1
    mainDir = '/Users/kutalmisince/Downloads/sacmalamalar/green';
else
    mainDir = '/Users/kutalmisince/Downloads/sacmalamalar/red';
end

% get directory list
dirList  = dir(mainDir);

% initate folder list
folders = cell(length(dirList), 1);

% set number of folders
numFolders = 0;

% get data folders
for i = 1 : length(dirList)
    dirName = dirList(i).name;
    
    if dirName(1) == '.' || ~isdir([mainDir '/' dirName ]), continue; end
    
    numFolders = numFolders + 1;
    
    folders(numFolders) = {dirName};
end

folders = folders(1 : numFolders);

% set debug mode
debugMode = 0;

for f = 1 : numFolders

    % set data directory
    dataDir = [mainDir '/' folders{f} '/']; %'./IR_20190925_130434_1_4/';

    % check whether annotations are recored in mat format or not
    if ~exist([dataDir 'annotationPass' num2str(passNumber - 1) '.mat'], 'file')
        % convert txt annotations to mat file and record
        annotationInit = ConvertAnnotation2Mat(dataDir);
    else
        % load annotations
        annotationInit = load([dataDir 'annotationPass' num2str(passNumber - 1) '.mat']);
    end

    % check whether fwbwShifhts are recorded or not
    if ~exist([dataDir 'fwbwShiftsPass' num2str(passNumber - 1) '.mat'], 'file')
        % find forward and backward shifts via cross correlation
        fwbwShifts = FindFWBWShifts(dataDir, annotationInit, ['fwbwShiftsPass' num2str(passNumber - 1) '.mat'], 20, debugMode);
    else
        % load fw/bw shifts
        fwbwShifts = load([dataDir 'fwbwShiftsPass' num2str(passNumber - 1) '.mat']);
    end

    % check whether corrected annotations are recorded or not
    if ~exist([dataDir 'annotationPass' num2str(passNumber) '.mat'], 'file')
        % perform forward backward correction
        annotationCorrected = FWBWCorrection(dataDir, annotationInit, fwbwShifts, ['annotationPass' num2str(passNumber) '.mat']);
    else
        % load corrected annotations
        annotationCorrected = load([dataDir 'annotationPass' num2str(passNumber) '.mat']);
    end

    DisplayOrRecordVisualResults(dataDir, ['CorrectionComparisonPass' num2str(passNumber) '.avi'], annotationInit, annotationCorrected, passNumber - 1);

end

return;


% check whether fwbwShifhts after 1st correction are recorded or not
if ~exist([dataDir 'fwbwShiftsPass1.mat'], 'file')
    disp('pass 2')
    % find forward and backward shifts via cross correlation
    fwbwShiftsPass1 = FindFWBWShifts(dataDir, annotationPass1, 'fwbwShiftsPass1.mat');
else
    % load fw/bw shifts
    fwbwShiftsPass1 = load([dataDir 'fwbwShiftsPass1.mat']);
end

% check whether 2nd correction applied and annotations are recorded or not
if ~exist([dataDir 'annotationPass2.mat'], 'file')
    % perform forward backward correction
    annotationPass2 = FWBWCorrection(dataDir, annotationPass1, fwbwShiftsPass1, 'annotationPass2.mat');
else
    % load corrected annotations
    annotationPass2 = load([dataDir 'annotationPass2.mat']);
end

% check whether fwbwShifhts after 1st correction are recorded or not
if ~exist([dataDir 'fwbwShiftsPass2.mat'], 'file')
    disp('pass 3')
    % find forward and backward shifts via cross correlation
    fwbwShiftsPass2 = FindFWBWShifts(dataDir, annotationPass2, 'fwbwShiftsPass2.mat');
else
    % load fw/bw shifts
    fwbwShiftsPass2 = load([dataDir 'fwbwShiftsPass2.mat']);
end

DisplayOrRecordVisualResults(dataDir, 'CorrectionComparison.avi');

% [avgShiftMag0, avgShiftMag1, avgShiftMag2, avgCorr0, avgCorr1, avgCorr2] = EvaluateNumericResults(dataDir);

% % find average shift magnitude before corrections
% shifts = (fwbwShifts.fwShiftEst - fwbwShifts.bwShiftEst) / 2;
% shifts = sum(shifts.^2, 2);
% 
% averageShiftMagnitudeBeforeCorrection = sqrt(mean(shifts));
% 
% % find average shift magnitude before corrections
% shifts = (fwbwShiftsCorrected.fwShiftEst - fwbwShiftsCorrected.bwShiftEst) / 2;
% shifts = sum(shifts.^2, 2);
% 
% averageShiftMagnitudeAfterCorrection = sqrt(mean(shifts));