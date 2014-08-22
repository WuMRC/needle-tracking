%% STEP 1 - Get video file
% Get video for analysis
% load('VID_20140811_110050.mat');


%%

[videoInfo.filename, videoInfo.pathname] = ...
    uigetfile('*.mp4;*.avi','Pick a video file');

addpath(genpath(videoInfo.pathname));

videoFile = VideoReader(videoInfo.filename);

%% STEP 2 - Look through frames/regions of interest
implay(videoInfo.filename)

% Select region of interest
figure, imshow(read(videoFile,1))

hBox = imrect;
roiPosition = wait(hBox);

% roiPosition;
roi_xind = round([roiPosition(2), roiPosition(2), ...
    roiPosition(2)+roiPosition(4), roiPosition(2)+roiPosition(4)]);
roi_yind = round([roiPosition(1), roiPosition(1)+roiPosition(3), ...
    roiPosition(1)+roiPosition(3), roiPosition(1)]);
close

video = read(videoFile);
videoROI = permute(video(roi_xind(1):roi_xind(3),...
    roi_yind(1):roi_yind(2),1,:),[1, 2, 4, 3]);



%% STEP 4 - Displacement Analysis

[nRows, nCols, nFrames] = size(videoROI);

fps = 24;
time = 0:(1/fps):((nFrames-1)/fps);

distancePerPixel = 0.057727273; % in mm
edgeLength = (0:1:nCols-1)*distancePerPixel;



level = graythresh(videoROI(:,:,1));



BW = zeros(nRows,nCols,nFrames);
BWflip = zeros(nCols,nRows,nFrames);
topEdge = zeros(nCols,nFrames);
displacement = zeros(nCols,nFrames);
displacementS = zeros(nCols,nFrames);
displacementSS = zeros(nCols,nFrames);

kalmanGain = 0.95;
videoROI_FILT = kalmanStackFilter(single(videoROI),kalmanGain);

framesToAnalyze = nFrames;

for indFrames = 1:framesToAnalyze%nFrames
    level = graythresh(videoROI(:,:,indFrames));
    BW(:,:,indFrames) = im2bw(videoROI(:,:,indFrames),level);
%     BWflip(:,:,indFrames) = imrotate(BW(:,:,indFrames),90);
    for indCol = 1:nCols
        topWall = find(BWflip(:,indCol,indFrames)==0,1,'first');
        
        if size(topWall,1) == 1
            topEdge(indCol,indFrames) = topWall;
        elseif size(topWall,1) == 0
            topEdge(indCol,indFrames) = NaN;
        end
        topEdgeSMOOTH(indCol,indFrames) = smooth(topEdge(indCol,indFrames),5);
    
    end
    displacement(:,indFrames) = (topEdgeSMOOTH(:,indFrames) ...
        - topEdgeSMOOTH(:,1))*distancePerPixel;
    displacementS(:,indFrames) = smooth(displacement(:,indFrames),20);
end

for indCol = 1:nCols
    % Delete if you have changed the size of framesToAnalyze
    displacementSS(indCol,:) = smooth(displacementS(indCol,:),3);
end
    

%%
 
framesToAnalyze = 10*fps;
framesToStart = 0.5*fps;

mesh( time(framesToStart:framesToAnalyze), edgeLength,displacementS(:,framesToStart:framesToAnalyze))

xlabel('Time [s]')
ylabel('Length Along Edge [mm]')
zlabel('Displacement [µm]')
