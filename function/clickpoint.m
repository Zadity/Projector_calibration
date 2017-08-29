% clear all

addpath function
load Calib_Results

PI = input('請輸入投影pattern檔名: ','s'); % propixel_28.bmp
I = imread(PI);
[p_data] = input('請輸入投影patternt尺寸[長,寬,方格數,每格pixel數]: '); % [800,600,6,28]
points_2d = corner_pts( I,p_data(1),p_data(2),p_data(3),p_data(4) );
figure(5)
imshow(I)
hold on
scatter(points_2d(1,:),points_2d(2,:),'g+')
camera_resolution = [nx ny];
projector_resolution = [p_data(1) p_data(2)];
proj_square_data = [p_data(3) p_data(4)];

mode = input('校正投影機的照片是否同相機校正照片?是請輸入0,否請輸入1: ');
if mode ==1
im_name = input('輸入照片檔名(舉例:IMG_1.JPG,則輸入IMG_): ','s');% ['z1_'];
im_fmt = input('輸入照片副檔名(舉例:IMG_1.JPG,則輸入.JPG): ','s');% ['.JPG'];
end
calib_image_num = input('Total image number: ');

colors = 'brgkcm';
% image_name = input('Projected image name: ','s');
% PP = double(rgb2gray(imread(image_name)));
% [ny_projim,nx_projim] = size(PP);
% [ProjectedGrid_2dpoints_projectorFrame,dumb,n_sq_x,n_sq_y] = extract_grid(PP);%,wintx,winty,fc,cc,kc,dX,dY);

disp('Window size for corner finder (wintx and winty):');
wintx = input('wintx ([] = 41) = ');
if isempty(wintx), wintx = 41; end;
wintx = round(wintx);
winty = input('winty ([] = 41) = ');
if isempty(winty), winty = 41; end;
winty = round(winty);

fprintf(1,'Window size = %dx%d\n',2*wintx+1,2*winty+1);
i=calib_image_num;
for k= 1:i
    %   extrinsic_computation;
    % Return:
    % Rc_ext rotation matrix of the reference from the camera to the plane.
    % Tc_ext translation from the camera frame to the grid frame in camera
    if mode==0
        II = double(rgb2gray(imread([calib_name,num2str(image_numbers(k)),'.',format_image])));
    elseif mode==1
        calib_name = [im_name,num2str(k),im_fmt];
        II = double((imread(calib_name)));
    end
    
    % 有旋轉才要
%     II = imrotate(II,90);
    
    display(['Processing Image number ' num2str(k)]);
    %     ProjectedGrid_2dpoints_cameraPlane = extract_grid(III,wintx,winty,fc,cc,kc,dX,dY); % 投影影像座標
    ProjectedGrid_2dpoints_cameraPlane = extract_grid(II,wintx,winty); % 投影影像座標
    projpoints_in_cameraplane(:,:,k) = ProjectedGrid_2dpoints_cameraPlane(:,:); % 相機擷取的投影平面
    
    m = size(ProjectedGrid_2dpoints_cameraPlane,2);
    ProjectedGrid = [ProjectedGrid_2dpoints_cameraPlane;ones(1,m)];
    eval(['XX_cam = X_' num2str(k) ';']);
    %     eval(['omc_cam = omc_' num2str(k) ';']);
    eval(['Rcam = Rc_' num2str(k) ';']);
    eval(['Tcam = Tc_' num2str(k) ';']);
    eval(['n_sq_x = n_sq_x_' num2str(k) ';']);
    eval(['n_sq_y = n_sq_y_' num2str(k) ';']);
    
    YY_cam = Rcam * XX_cam + Tcam * ones(1,length(XX_cam));
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
    n = v3;
    n = n./norm(n);
    N(:,k) = n; 
    
    c = v3'*YY_cam(:,1);
    ProjectedGrid_cam = [1 -alpha_c 0;0 1 0;0 0 1]*[1/fc(1) 0 0;0 1/fc(2) 0;0 0 1]*[1 0 -cc(1);0 1 -cc(2);0 0 1]*ProjectedGrid; % 投影平面透過相機參數反算
    s = c./(v3'*ProjectedGrid_cam);
    ProjectedGrid_3dpoints = ProjectedGrid_cam.*(ones(3,1)*s);
    %     v3'*YY_cam-c
%     YY(:,:,k) = YY_cam; % 棋盤格在相機空間座標
    
    figure(4);
    hhh= mesh(YYx,YYz,-YYy);
    set(hhh,'edgecolor',colors(rem(k-1,6)+1),'linewidth',1);
    text(uu(1),uu(3),-uu(2),num2str(k),'fontsize',14,'color',colors(rem(k-1,6)+1));
    hold on
    plot3(ProjectedGrid_3dpoints(1,:),ProjectedGrid_3dpoints(3,:),-ProjectedGrid_3dpoints(2,:),'.')
    
    XP(:,:,k) = [ProjectedGrid_3dpoints;ones(1,m)]; % projected 3Dpoints on camera coordinate
    
%     invprojerror = invproj_error( ProjectedGrid_3dpoints,YY_cam,k,D );
%     eval(['invproj_error_' num2str(k) ' = invprojerror;']);

end
save('pts.mat','points_2d','projpoints_in_cameraplane','XP','N','camera_resolution','projector_resolution','proj_square_data')