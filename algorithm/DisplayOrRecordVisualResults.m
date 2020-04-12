

function DisplayOrRecordVisualResults(dataDir, videoName, annotation0, annotation1, displayRaw)

    
    if displayRaw
        colors = {'red', 'cyan', 'yellow'};
    else
        colors = {'green', 'red'};
    end
    
center0 = annotation0.center;
bbox0   = annotation0.bbox;
marked  = annotation0.marked;

if isempty(annotation1), markAlternative = 0;
else                     markAlternative = 1;
end

if markAlternative
    center1 = annotation1.center;
    bbox1   = annotation1.bbox;

    center2 = annotation1.centerRaw;
    bbox2   = annotation1.bboxRaw;
end

if ~isempty(videoName)
    video = VideoWriter([dataDir '' videoName], 'Motion JPEG AVI');
    video.FrameRate = 10;
    open(video);
end

for k = 1 : length(marked)
    
    I = imread([dataDir '' num2str(k) '.jpg']);
        
    J = insertShape(I, 'Rectangle', bbox0(k, :), 'LineWidth', 1, 'Color', colors{1});
    
    
    J = insertMarker(J, center0(k, :), '+', 'color', colors{1}, 'size', 5);
    
    if markAlternative
        
        J = insertShape(J, 'Rectangle', bbox1(k, :), 'LineWidth', 1, 'Color', colors{2});
        J = insertMarker(J, center1(k, :), '+', 'color', colors{2}, 'size', 5);

        if displayRaw
            J = insertShape(J, 'Rectangle', bbox2(k, :), 'LineWidth', 1, 'Color', colors{3});
            J = insertMarker(J, center2(k, :), '+', 'color', colors{3}, 'size', 5);
        end
    end
    
    if ~isempty(videoName)
        writeVideo(video, J);
    else
        figure(1), hold off, imshow(J), 
        title(k)
        pause()
    end
    
end

if ~isempty(videoName)
    close(video);
end

end