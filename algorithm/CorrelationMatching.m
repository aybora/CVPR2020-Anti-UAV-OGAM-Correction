
# author: kutalmisince

function [estShift, score, scoreInit, LT, satAlarm] = CorrelationMatching(template, templateCenter, I, estCenter, range)
    
    % convert template to double
    template = double(template);
        
    % conver image to double
    I = double(I);
    
    % get the size of the template
    [H, W, ~] = size(template);
    
    % get the size of the image
    [height, width, ~] = size(I);
    
    % normalize template
    template = (template(:) - mean(template(:))) / std(template(:), 1);
    
    % allocate space for score
    score = zeros(2 * range + 1);
    
    % round the estimated center
    estLT = estCenter - [W H] / 2;
    estLTR = round(estLT);
    
    % for the given range
    for i = -range : range
        for j = -range : range
            
            % set left-top and right bottom
            LT = estLTR + [i, j];
            RB = LT + [W H] - 1;
            
            % check whether LT and RB are both in the image
            if LT(1) < 1 || RB(1) > width || LT(2) < 1 || RB(2) > height
                % set score to -2 for the candidate positions out of the image
                s = -2;
            else
                % get the matching patch
                match = I(LT(2) : RB(2), LT(1) : RB(1), :);
                
                % normalize the patch
                match = (match - mean(match(:))) / std(match(:), 1);

                % find cross correlation
                s = template' * match(:) / (W * H);
                
            end
            
            % set the score
            score(j + range + 1, i + range + 1) = s;
        end
    end
    
    % find the peak
    [maxVal, maxIND] = max(score(:));
    
    % convert to 2d index
    [y, x] = ind2sub(size(score), maxIND);
    
    if min(x, y) == 1 || max(x, y) == (2 * range + 1)
        satAlarm = 1;
    else
        satAlarm = 0;
    end
    
    yEst = y;
    xEst = x;
    
    LT = estLTR + [x y] - (range + 1);
    
    % get subpixel estimate
    if y > 1 && y < 2 * range + 1
        
        A = [1 -1 1; 0 0 1; 1 1 1];
        b = [score(y - 1, x); score(y, x); score(y + 1, x)];
        
        if sum(b == -2) == 0
            p = A \ b;
            yEst = y - p(2) / (2 * p(1));
        end
    end
    
    if x > 1 && x < 2 * range + 1
        A = [1 -1 1; 0 0 1; 1 1 1];
        b = [score(y, x - 1); score(y, x); score(y, x + 1)];
        
        if sum(b == -2) == 0
            p = A \ b;
            xEst = x - p(2) / (2 * p(1));
        end
    end
    
    foundCenter = estLTR + [xEst, yEst] - (range + 1) + templateCenter;
    estShift = foundCenter - estCenter;
    scoreInit = score(range + 1, range + 1);
    score  = maxVal;
end
