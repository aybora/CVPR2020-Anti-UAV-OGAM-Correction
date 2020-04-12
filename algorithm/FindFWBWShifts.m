
function fwbwShifts = FindFWBWShifts(dataDir, annotation, fileName, range, debugMode)

    if nargin < 5, debugMode = 0; end
    
    center = annotation.center;
    bbox = annotation.bbox;
    marked = annotation.marked;
    
    numFrames = size(center, 1);

    fwShiftEst  = zeros(numFrames, 2);
    bwShiftEst  = zeros(numFrames, 2);
    fwScoreInit = zeros(numFrames, 1);
    bwScoreInit = zeros(numFrames, 1);
    fwScore     = zeros(numFrames, 1);
    bwScore     = zeros(numFrames, 1);

    % perform forward estimate
    I = imread([dataDir '' num2str(1) '.jpg']);

    for k = 2 : numFrames

        disp(k)
        
        if ~marked(k), continue; end
        
        J = imread([dataDir '' num2str(k) '.jpg']);
        
        if ~marked(k - 1), I = J; continue; end

        b = bbox(k - 1, :);

        template = I(b(2) : b(2) + b(4) - 1, b(1) : b(1) + b(3) - 1, 1);
        
        templateCenter = center(k - 1, :) - b(1:2);

        for i = 1:5
            [fwShiftEst(k, :), fwScore(k), fwScoreInit(k), estLT, satAlarm] = CorrelationMatching(template, templateCenter, J(:,:,1), center(k, :), range * i);

            if ~satAlarm, break; end
        end

        if debugMode
            
            disp(['fw: ' num2str(k)])
            
            match = J(estLT(2) : estLT(2) + b(4) - 1, estLT(1) : estLT(1) + b(3) - 1, 1);

            dispIMG = [template, match; match, uint8(double(template) - double(match) + 128)];

            figure(1), hold off, imshow(dispIMG), title(['frame: ' num2str(k) ', press any key to continue..'])

            pause(0.01);
        end
        
        I = J;
    end

    % perform backward estimate
    I = imread([dataDir '' num2str(numFrames) '.jpg']);

    for k = numFrames - 1 : -1 : 1

        disp(k)
        
        if ~marked(k), continue; end
        
        J = imread([dataDir '' num2str(k) '.jpg']);
        
        if ~marked(k + 1), I = J; continue; end
        
        b = bbox(k + 1, :);

        template = I(b(2) : b(2) + b(4) - 1, b(1) : b(1) + b(3) - 1, 1);
        
        templateCenter = center(k + 1, :) - b(1:2);

        for i = 1:5
            [bwShiftEst(k + 1, :), bwScore(k + 1), bwScoreInit(k + 1), estLT, satAlarm] = CorrelationMatching(template, templateCenter, J(:,:,1), center(k, :), range * i);

            if ~satAlarm, break; end
        end

        if debugMode
            
            disp(['fw: ' num2str(k)])
            
            match = J(estLT(2) : estLT(2) + b(4) - 1, estLT(1) : estLT(1) + b(3) - 1, 1);

            dispIMG = [template, match; match, uint8(double(template) - double(match) + 128)];

            figure(1), hold off, imshow(dispIMG), title(['frame: ' num2str(k) ', press any key to continue..'])

            pause(0.01);
        end
        
        I = J;
    end

    save([dataDir '' fileName], 'fwShiftEst', 'bwShiftEst', 'fwScore', 'bwScore', 'fwScoreInit', 'bwScoreInit')
    
    fwbwShifts.fwShiftEst = fwShiftEst;
    fwbwShifts.bwShiftEst = bwShiftEst;
    fwbwShifts.fwScore = fwScore;
    fwbwShifts.bwScore = bwScore;
    fwbwShifts.fwScoreInit = fwScoreInit;
    fwbwShifts.bwScoreInit = bwScoreInit;

end