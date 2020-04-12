
function annotation = ConvertAnnotation2Mat(dataDir)
        
    numFrames = 1000;

    bbox = zeros(numFrames, 4);
    center = zeros(numFrames, 2);
    marked = zeros(numFrames, 1);

    W = 640;
    H = 512;

    for k = 1 : numFrames

        fid = fopen([dataDir '' num2str(k) '.txt'],'r');

        if fid == -1, k = k - 1; break; end

        data = fscanf(fid,'%f');
        fclose(fid);

        if size(data, 1) > 0

            C = data(2:3)' .* [W H];
            S = data(4:5)' .* [W H];

            bbox(k, :) = round([C - S/2, S]);
            center(k, :) = C;
            
            if bbox(k, 1) > 5  && bbox(k, 2) > 5 && (bbox(k, 1) + bbox(k, 3) - 1) < (W - 5) && (bbox(k, 2) + bbox(k, 4) - 1) < (H - 5) 
                marked(k) = 1;
            else
                center(k, :) = 0;
                bbox(k, :) = 0;
            end

        end
    end

    bbox = bbox(1 : k, :);
    center = center(1 : k, :);
    marked = marked(1 : k, :);

    save([dataDir 'annotationPass0.mat'], 'bbox', 'center', 'marked')
    
    annotation.bbox = bbox;
    annotation.center = center;
    annotation.marked = marked;

end