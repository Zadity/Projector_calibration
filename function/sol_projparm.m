clear all

addpath function
load Calib_Results
load('pts.mat')
Kcam = KK;

% IM2=imread('IM_2','bmp');
% IM2bw=im2bw(rgb2gray(IM2));
% corners = corner(IM2bw,'sensitivityFactor',0.001)-0.5;
% [ll,tmp]=min(corners(:,1));[rr,tmp]=max(corners(:,1));
% [bb,tmp]=min(corners(:,2));[uu,tmp]=max(corners(:,2));
% incor=find(corners(:,1)~=ll & corners(:,1)~=rr & corners(:,2)~=bb & corners(:,2)~=uu);
% temp=[-corners(incor,1) corners(incor,2)];
% inner_corners=sortrows(temp);
% inner_corners=[-inner_corners(:,1) inner_corners(:,2)];
% points_2d(1:2,:)=inner_corners';

% I = imread('IM_2.bmp');
% points_2d = corner_pts( I,800,600,6,14 );
% figure(5)
% imshow(I)
% hold on
% scatter(points_2d(1,:),points_2d(2,:),'r+')

[nx, ny, nz] = size(XP);

active_number = ones(1,nz); % 作用=1,不作用=0
% active_number = [1 0 1 1 1 1 1 0 1 1 1 1]; 

% find 3d lines
XPP = [];
for i  = 1:nz
    if active_number(i)==1
        A = XP(:,:,i);
        A = reshape(A,4*ny,1);
        XPP = [XPP A];
    end
end
index = find(active_number==1);
XP = XP(:,:,index);
N = N(:,index);
[nx, ny, nz] = size(XP);

Meanpts = zeros(3,ny);
v = zeros(3,ny);
for i = 1:ny
    Meanpts(:,i) = mean(XPP(4*(i-1)+1:4*(i-1)+3,:),2);
    Y = XPP(4*(i-1)+1:4*(i-1)+3,:)-Meanpts(:,i)*ones(1,nz);
    [V,D]=eig(Y*Y');
    
    [~,ii]=max(abs(diag(D)));
    v(:,i) = V(:,ii);
end

% 算出投影機在相機座標下的位置
Temp1 = zeros(3,1);
Temp2 = zeros(3,3);
for i = 1:ny
    Temp1 = Temp1 + (eye(3)-v(:,i)*v(:,i)')*Meanpts(:,i);
    Temp2 = Temp2 + (eye(3)-v(:,i)*v(:,i)');
end
O = Temp2\Temp1;

% find normal vector
v = Meanpts - O*ones(1,ny);
norm_v = sqrt(sum(v.^2,1));
v = v./(ones(3,1)*norm_v);
Z = sum(v,2)/ny;
Z = Z/norm(Z);
% [V,D]=eig(v*v');
% [~,ii]=max(abs(diag(D)));
% Z = V(:,ii);
% norm_v = sqrt(sum(v.^2,1));
% v = v./(ones(3,1)*norm_v);
save('tempdata.mat','points_2d','v','Meanpts','proj_square_data')

OZ_init = [O;Z];
O_optim = optimset('Display','iter','Algorithm','sqp','MaxIter',1000,'Tolx',1e-06);
OZ_new = fminunc(@sol_in_parms, OZ_init,O_optim);
[error_before_fmin,~,~,~,~] = sol_in_parms(OZ_init);
[error_after_fmin,Kproj,pxx,pyy,planepoint] = sol_in_parms(OZ_new);
O_proj = OZ_new(1:3);
Z_new = OZ_new(4:6);
O2 = O_proj+Z_new;
d_O = norm(O_proj); % 相機-投影機距離

% % plot
% figure
% plot3(0,0,0,'ro')
% hold on
% plot3(O_proj(1),O_proj(3),-O_proj(2),'ro')
% hold on
% plot3(planepoint(1,:),planepoint(3,:),-planepoint(2,:),'b*')
% for i = 1:nz
%     hold on
%     YYx = zeros(7,7);
%     YYy = zeros(7,7);
%     YYz = zeros(7,7);
%     
%     YYx(:) = XP(1,:,i);
%     YYy(:) = XP(2,:,i);
%     YYz(:) = XP(3,:,i);
%     mesh(YYx,YYz,-YYy)
%   plot3(XP(1,:,i),XP(2,:,i),XP(3,:,i),'bo')
% end
% hold on
% plot3(O2(1),O2(2),O2(3),[O2(1) O2(1)+pxx(1)],[O2(2) O2(2)+pxx(2)],[O2(3) O2(3)+pxx(3)]);
% hold on
% plot3(O2(1),O2(2),O2(3),[O2(1) O2(1)+pyy(1)],[O2(2) O2(2)+pyy(2)],[O2(3) O2(3)+pyy(3)]);
xlabel('X');
ylabel('Z');
zlabel('Y');
axis equal

pzz = cross(pxx,pyy);
pp = [dot(O_proj,pxx);dot(O_proj,pyy);dot(O_proj,pzz)];
R_ptoc = [pxx pyy pzz];
T_ptoc = O_proj;
R_ctop = R_ptoc';
T_ctop = -pp;
RT_ptoc = [R_ptoc T_ptoc];
RT_ctop = [R_ctop T_ctop];

checkinvproj
disp('intrinsic parameters of projector')
Kproj
disp('Projector location')
O_proj
disp('error of re-projection in 3D')
derror3
save('cal_result.mat','O_proj','Kproj','RT_ptoc','RT_ctop','Kcam')
