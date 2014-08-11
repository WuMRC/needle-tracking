

% Get video for analysis
[needleVideoInfo.filename, needleVideoInfo.pathname] = ...
    uigetfile('*.mp4;*.avi','Pick a video file');
needleVideo = VideoReader(needleVideoInfo.filename);


% Select region of interest
figure, imshow(read(needleVideo,1))

hBox = imrect;
roiPosition = wait(hBox);

% roiPosition;
roi_yind = round([roiPosition(1), roiPosition(1)+roiPosition(3), ...
    roiPosition(1)+roiPosition(3), roiPosition(1)]);
roi_xind = round([roiPosition(2), roiPosition(2), ...
    roiPosition(2)+roiPosition(4), roiPosition(2)+roiPosition(4)]);
close

% Create region of interest image
% imageroi = I(roi_xind(1):roi_xind(3),roi_yind(1):roi_yind(2),:,1);


clear x1 x2 img1 img2 motion img12 motionMag
%%



for indFrame = 1:needleVideo.NumberOfFrames-1
    img1 = read(needleVideo,indFrame);
    img2 = read(needleVideo,indFrame+1);
    
    x1(:,:,indFrame) = rgb2gray(img1(roi_xind(1):roi_xind(3),...
        roi_yind(1):roi_yind(2),:));
    x2(:,:,indFrame) = rgb2gray(img2(roi_xind(1):roi_xind(3),...
        roi_yind(1):roi_yind(2),:));
end



%%

blockSize = 5;

hbm = vision.BlockMatcher('ReferenceFrameSource', 'Input port',...
    'BlockSize', [blockSize, blockSize]);
hbm.OutputValue = ...
    'Horizontal and vertical components in complex form';

for ind = 1:10
% image1 = x1(:,:,ind);
% image2 = x2(:,:,ind);

halphablend = vision.AlphaBlender;

motion(:,:,ind) = step(hbm, x1(:,:,ind), x2(:,:,ind));
img12 = step(halphablend, x2(:,:,ind), x1(:,:,ind));
motionMag(:,:,ind) = sqrt(double(real(motion(:,:,ind)).^2 ...
    + imag(motion(:,:,ind)).^2));

end




%%
Fr 
img12 = step(halphablend, x2(:,:,2), x1(:,:,2));

[X, Y] = meshgrid(1:blockSize:size(x1, 2),...
    1:blockSize:size(x1, 1));
imshow(img12); hold on;

imag1 = motion(:,:,2);
imag2 = motion(:,:,2);

quiver(X(:), Y(:), real(imag2(:)), imag(imag2(:)), 0); hold off;



%%
opticalFlow = vision.OpticalFlow('Method','Lucas-Kanade',...
    'ReferenceFrameSource','Input port');
for indFrame = 1:100
    V = double(step(opticalFlow, x1(:,:,indFrame),...
        x2(:,:,indFrame+1)));
    velocityField(:,:,indFrame) = V;
%     Vnorm(:,:,indFrame) = V(:,:,indFrames)./max(max(V(:,:,indFrame)));
end














