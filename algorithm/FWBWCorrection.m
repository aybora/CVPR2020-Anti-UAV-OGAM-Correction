
function correctedAnnotation = FWBWCorrection(dataDir, annotation, fwbwShifts, fileName, debugMode)
    
    if nargin < 5
        debugMode = 0;
    end
       
    center = annotation.center;
    bbox = annotation.bbox;
    marked = annotation.marked;
    
    numFrames = size(center, 1);
    
    shiftEst = (fwbwShifts.fwShiftEst - fwbwShifts.bwShiftEst) / 2;
    shiftDiff = fwbwShifts.fwShiftEst + fwbwShifts.bwShiftEst;
    shiftEstC = zeros(numFrames, 2);
    
    score = min(fwbwShifts.fwScore,  fwbwShifts.bwScore);
    score(1)= 1;
    
    correctMatch = and(score > 0.7, max(abs(shiftDiff), [], 2) < 3);
    
    measurementAvailable = and(correctMatch, marked);
   
    dx = zeros(numFrames, 1);
    dy = zeros(numFrames, 1);
    
    k = 0;
    
    while k < numFrames
        
        n = find(measurementAvailable(k + 1 : end) == 0, 1, 'first');
        
        if isempty(n), n = numFrames; 
        else           n = n + k - 1;
        end
        
        shiftEstC(k + 1 : n, :) = cumsum(shiftEst(k + 1 : n, :), 1);
        
        A = [1 : n - k; ones(1, n - k)]';
        
        dx(k + 1 : n) = A * (pinv(A) * shiftEstC(k + 1 : n, 1));
        dy(k + 1 : n) = A * (pinv(A) * shiftEstC(k + 1 : n, 2));
        
        k = n + 1;
    end

    if debugMode
        figure, 
        subplot(2,1,1), plot(shiftEstC(:, 1)), title('cumsum x shift')
        hold on, plot(dx, 'r')
        subplot(2,1,2), plot(shiftEstC(:, 2)), title('cumsum y shift')
        hold on, plot(dy, 'r')
    end
    
    shiftEstFiltered = shiftEstC - [dx, dy];
    
    centerRaw = center + shiftEstC;
    bboxRaw = round([centerRaw - bbox(:, 3:4) / 2, bbox(:, 3:4)]);
    
    center = center + shiftEstFiltered;
    bbox = round([center - bbox(:, 3:4) / 2, bbox(:, 3:4)]);
    
    save([dataDir '' fileName], 'center', 'bbox', 'shiftEstFiltered', 'centerRaw', 'bboxRaw', 'marked');
    
    correctedAnnotation.center = center;
    correctedAnnotation.bbox = bbox;
    correctedAnnotation.shiftEstFiltered = shiftEstFiltered;
    correctedAnnotation.centerRaw = centerRaw;
    correctedAnnotation.bboxRaw = bboxRaw;
    correctedAnnotation.marked = marked;
end