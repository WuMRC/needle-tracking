
% Get video for analysis
[needleVideoInfo.filename, needleVideoInfo.pathname] = ...
    uigetfile('*.mp4;*.avi','Pick a video file');
addpath(genpath(needleVideoInfo.pathname))

needleVideoFile = VideoReader(needleVideoInfo.filename);

here's an example of change

% Select region of interest
figure, imshow(read(needleVideoFile,1))


hBox = imrect;
roiPosition = wait(hBox);

% roiPosition;
roi_xind = round([roiPosition(2), roiPosition(2), ...
    roiPosition(2)+roiPosition(4), roiPosition(2)+roiPosition(4)]);
roi_yind = round([roiPosition(1), roiPosition(1)+roiPosition(3), ...
    roiPosition(1)+roiPosition(3), roiPosition(1)]);
close


% Create region of interest image
needleVideo = read(needleVideoFile);
needleVideoROI = permute(needleVideo(...
    roi_xind(1):roi_xind(3),roi_yind(1):roi_yind(2),1,:), [1 2 4 3]);

imtool3D(needleVideoROI)