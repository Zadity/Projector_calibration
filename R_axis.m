clear all
close all
clc
load('Calib_Results.mat')

% 中心點
y = [];
im_name = input('輸入照片檔名(舉例:IMG_1.JPG,則輸入IMG_): ','s');% ['z1_'];
im_fmt = input('輸入照片副檔名(舉例:IMG_1.JPG,則輸入.JPG): ','s');% ['.JPG'];
s = input('輸入點選幾張圓心: ');
for i = 1:s
    figure
    word = [im_name,num2str(i),im_fmt];
    I = imrotate(imread(word),90);
    imshow(I)
    zoom on
    pause()
    zoom off
    x = ginput(1);
    y = [y;x];
    hold on
    scatter(x(1),x(2),'r+')
end
II = imrotate(imread(word),90);
figure
imshow(II)
hold on
scatter(y(:,1),y(:,2),'r+')
save('temp_click_center.mat','y')
centers = [mean(y(:,1));mean(y(:,2));1];
hold on
scatter(centers(1),centers(2),'g+')

%%
% 畫平面
k = input('calib image number: ');
N = [];
figure
for i = k:k+3

eval(['XX_cam = X_' num2str(i) ';']);
eval(['Rcam = Rc_' num2str(i) ';']);
eval(['Tcam = Tc_' num2str(i) ';']);
eval(['n_sq_x = n_sq_x_' num2str(i) ';']);
eval(['n_sq_y = n_sq_y_' num2str(i) ';']);

YY_cam = Rcam * XX_cam + Tcam * ones(1,length(XX_cam));
[mx,my] = size(YY_cam);

uu = [-dX;-dY;0]/2;
uu = Rcam * uu + Tcam;

YYx = zeros(n_sq_x+1,n_sq_y+1);
YYy = zeros(n_sq_x+1,n_sq_y+1);
YYz = zeros(n_sq_x+1,n_sq_y+1);
YYx(:) = YY_cam(1,:);
YYy(:) = YY_cam(2,:);
YYz(:) = YY_cam(3,:);

v1 = YY_cam(:,2) - YY_cam(:,1);
v2 = YY_cam(:,2+n_sq_x) - YY_cam(:,1);
v3 = cross(v1,v2);
c = v3'*YY_cam(:,1);
n = v3./norm(v3);
N = [N n];
plot3(YY_cam(1,25),YY_cam(3,25),-YY_cam(2,25),[YY_cam(1,25) YY_cam(1,25)+100*n(1)],[YY_cam(3,25) YY_cam(3,25)+100*n(3)],[-YY_cam(2,25) -YY_cam(2,25)-100*n(2)])

hhh= mesh(YYx,YYz,-YYy);
axis equal
hold on

end
hold on
plot3(0,0,0,'bo');
NV = N(:,4);

% 算中心點
centerpts = inv(KK)*centers; % X:長邊pixel Y:短邊pixel
ss = c./(v3'*centerpts);
center_3dpoints = centerpts.*(ones(3,1)*ss)

hold on
plot3(center_3dpoints(1),center_3dpoints(3),-center_3dpoints(2),'ro');
hold on
plot3(center_3dpoints(1),center_3dpoints(3),-center_3dpoints(2),[center_3dpoints(1) center_3dpoints(1)+100*NV(1)],[center_3dpoints(3) center_3dpoints(3)+100*NV(3)],[-center_3dpoints(2) -center_3dpoints(2)-100*NV(2)])

save('axis','NV','center_3dpoints')