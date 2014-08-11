

% Get video for analysis
[needleVideoInfo.filename, needleVideoInfo.pathname] = ...
    uigetfile('*.mp4;*.avi','Pick a video file');

needleVideoFile = VideoReader(needleVideoInfo.filename);

% Select region of interest
figure, imshow(read(needleVideoFile,1))

% needleVideo = read(needleVideoFile);

hBox = imrect;
roiPosition = wait(hBox);

% roiPosition;
roi_xind = round([roiPosition(2), roiPosition(2), ...
    roiPosition(2)+roiPosition(4), roiPosition(2)+roiPosition(4)]);
roi_yind = round([roiPosition(1), roiPosition(1)+roiPosition(3), ...
    roiPosition(1)+roiPosition(3), roiPosition(1)]);
close

% Create region of interest image
% imageroi = I(roi_xind(1):roi_xind(3),roi_yind(1):roi_yind(2),:,1);



clear x1 x2 img1 img2 motion img12 motionMag
%%

% Block matching
blockSize = 5;
halphablend = vision.AlphaBlender;
hbm = vision.BlockMatcher('ReferenceFrameSource', 'Input port',...
    'BlockSize', [blockSize, blockSize]);
hbm.OutputValue = ...
    'Horizontal and vertical components in complex form';

% Optical flow
opticalFlow = vision.OpticalFlow('Method','Lucas-Kanade',...
    'ReferenceFrameSource','Input port');


for indFrame = 1:25%needleVideo.NumberOfFrames-1
    % Read in the images from the video
    currentFrameData = read(needleVideoFile,indFrame);
    nextFrameData = read(needleVideoFile,indFrame+1);
    
    % Just look at the region of interest
    currentFrameDataROI(:,:,indFrame) = rgb2gray(currentFrameData(...
        roi_xind(1):roi_xind(3),...
        roi_yind(1):roi_yind(2),:));
    nextFrameDataROI(:,:,indFrame) = rgb2gray(nextFrameData(...
        roi_xind(1):roi_xind(3),...
        roi_yind(1):roi_yind(2),:));
    
    % Detect motion in the grid
    motion(:,:,indFrame) = step(hbm, ...
        currentFrameDataROI(:,:,indFrame), nextFrameDataROI(:,:,indFrame));
    
    img12(:,:,indFrame) = step(halphablend, ...
        nextFrameDataROI(:,:,indFrame), currentFrameDataROI(:,:,indFrame));
    
    velocityField(:,:,indFrame) = double(step(opticalFlow,...
        currentFrameDataROI(:,:,indFrame), ...
        nextFrameDataROI(:,:,indFrame)));


end


motionMag = sqrt(double(real(motion).^2 ...
    + imag(motion).^2));

motionAvg = mean(motion,3);
motionMagAvg = mean(motionMag,3);
img12Avg = mean(img12,3);
velocityFieldAvg = mean(velocityField,3);

[X, Y] = meshgrid(1:blockSize:size(currentFrameDataROI, 2),...
    1:blockSize:size(currentFrameDataROI, 1));
imagesc(img12Avg); hold on;

quiver(X(:), Y(:), real(motionAvg(:)), imag(motionAvg(:)), 0); hold off;












