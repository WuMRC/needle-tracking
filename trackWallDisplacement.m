%% STEP 1 - Get video file
% Get video for analysis
% load('VID_20140811_110050.mat');


%%

[videoInfo.filename, videoInfo.pathname] = ...
    uigetfile('*.mp4;*.avi','Pick a video file');

addpath(genpath(videoInfo.pathname));

videoFile = VideoReader(videoInfo.filename);

%% STEP 2 - Look through frames/regions of interest
% implay(videoInfo.filename)

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



BW = zeros(nRows,nCols-6,nFrames);
% BWflip = zeros(nCols,nRows,nFrames);
vesselWidth = zeros(nRows,nFrames);
vesselWidthSMOOTH = zeros(nRows,nFrames);
bottomEdge = zeros(nRows,nFrames);
bottomEdgeSMOOTH = zeros(nRows,nFrames);
topEdge = zeros(nRows,nFrames);
topEdgeSMOOTH = zeros(nRows,nFrames);
% displacement = zeros(nCols,nFrames);
% displacementS = zeros(nCols,nFrames);
% displacementSS = zeros(nCols,nFrames);

% kalmanGain = 0.95;
% videoROI_FILT = kalmanStackFilter(single(videoROI),kalmanGain);

framesToAnalyze = nFrames;

for indFrames = 1:framesToAnalyze%nFrames
    level = graythresh(videoROI(:,:,indFrames));
    BW(:,:,indFrames) = im2bw(videoROI(:,1:nCols-6,indFrames),level);
%     BWflip(:,:,indFrames) = imrotate(BW(:,:,indFrames),90);
    for indRows = 1:nRows
        bottomWall = find(BW(indRows,:,indFrames)==0,1,'first');
        if size(bottomWall,1) == 1
            bottomEdge(indRows,indFrames) = bottomWall;
        elseif size(bottomWall,1) == 0
            bottomEdge(indRows,indFrames) = NaN;
        end
        bottomEdgeSMOOTH(indRows,indFrames) = ...
            smooth(bottomEdge(indRows,indFrames),20);
        
        topWall = find(BW(indRows,:,indFrames)==0,1,'last');
        if size(topWall,1) == 1
            topEdge(indRows,indFrames) = topWall;
        elseif size(topWall,1) == 0
            topEdge(indRows,indFrames) = NaN;
        end
        topEdgeSMOOTH(indRows,indFrames) = ...
            smooth(topEdge(indRows,indFrames),20);
%         
        vesselWidth(indRows,indFrames) = (topEdgeSMOOTH(indRows,indFrames)...
            - bottomEdgeSMOOTH(indRows,indFrames)).*distancePerPixel;
        
        if vesselWidth(indRows,indFrames) >= 400
            vesselWidth(indRows,indFrames) = NaN;
        elseif vesselWidth(indRows,indFrames) <= 0.5
            vesselWidth(indRows,indFrames) = NaN;
        end

    end
    
    vesselWidthSMOOTH(:,indFrames) = ...
        smooth(vesselWidth(:,indFrames),10);
     
    
%     displacement(:,indFrames) = (topEdgeSMOOTH(:,indFrames) ...
%         - topEdgeSMOOTH(:,1))*distancePerPixel;
%     displacementS(:,indFrames) = smooth(displacement(:,indFrames),20);
end

% vesselWidth = (topEdgeSMOOTH - bottomEdgeSMOOTH).*distancePerPixel;
% vesselWidth(vesselWidth>=1.4) = NaN;
% vesselWidth(vesselWidth<=0.4) = NaN;



% for indRows = 1:nCols
%     % Delete if you have changed the size of framesToAnalyze
%     displacementSS(indRows,:) = smooth(displacementS(indRows,:),3);
% end
    

%%
 
framesToAnalyze = 390;
framesToStart = 10;

mesh( time(framesToStart:framesToAnalyze), edgeLength,displacementS(:,framesToStart:framesToAnalyze))

xlabel('Time [s]')
ylabel('Length Along Edge [mm]')
zlabel('Displacement [µm]')

%%


mesh(bottomEdgeSMOOTH(1:350,1:390))
xlabel('Time [s]')
ylabel('Length Along Edge [mm]')
zlabel('Displacement [µm]')

figure, mesh(topEdgeSMOOTH(1:350,1:350))
xlabel('Time [s]')
ylabel('Length Along Edge [mm]')
zlabel('Displacement [µm]')

%%
figure, mesh(vesselWidth(1:350,75:400))
xlabel('Frame [#]')
ylabel('Vessel Width [mm]')
zlabel('Displacement [µm]')


%%

figure, plot(smooth(bottomEdgeSMOOTH(88,:),24))
hold on, plot(smooth(topEdgeSMOOTH(88,:),24),'r')



%%
time = (0:nFrames-1)./fps;
figure, plot(time(200:500),smooth(vesselWidth(113+9,200:500),25),...
    'Color',[0 0 0],'LineWidth',2)
hold on, plot(time(200:500),smooth(vesselWidth(91,200:500),25),...
    'Color', [0.25 0.25 0.25],'LineWidth',2)
plot(time(200:500),smooth(vesselWidth(113-52,200:500),25),...
    'Color', [0.5 0.5 0.5],'LineWidth',2)
