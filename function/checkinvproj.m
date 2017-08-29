% clear all
% 
% addpath function
% load('pts.mat')
% load('projdata.mat')
% 
% [nx, ny, nz] = size(XP);
% 
% Kproj = [Kparm(1) Kparm(2) Kparm(3);0 Kparm(4) Kparm(5);0 0 1];
% invKproj = inv(Kproj);
% invpts = invKproj*points_2d(:,:);

proj_plane = inv(Kproj)*[points_2d;ones(1,ny)];
ttt = RT_ctop'*proj_plane;
proj_plane2 =ttt(1:3,:)-(R_ptoc*T_ctop)*ones(1,ny);
v_new = proj_plane2-O_proj*ones(1,ny);
norm_v = sqrt(sum(v_new.^2,1));
v_new = v_new./(ones(3,1)*norm_v);

figure
plot3(O_proj(1),O_proj(2),O_proj(3),'ro')
hold on
plot3(0,0,0,'go')
hold on
plot3(proj_plane2(1,:),proj_plane2(2,:),proj_plane2(3,:),'b*')
for i = 1:nz
  hold on  
  plot3(XP(1,:,i),XP(2,:,i),XP(3,:,i),'bo')
end
xlabel('X');
ylabel('Y');
zlabel('Z');
for i = 1:nz
    XPP = XP(1:3,:,i);
    n = N(:,i); % 讀取透過相機校正算出來的normal資料
    
    % 求出平面及平面上交點
    t = dot(XPP(:,1)-O_proj,n)./(v_new'*n);
    tt = repmat(t',3,1);
    vt = tt.*v_new;
    planepoint = O_proj*ones(1,ny)+vt;
    newXP(:,:,i) = planepoint;
    
    hold on
    plot3(planepoint(1,:),planepoint(2,:),planepoint(3,:),'rx')
    axis equal
    %     for j = 1:ny
    %         hold on
    %         t = -500:500:3000;
    %         plot3(v(1,j)*t+O_new(1),v(2,j)*t+O_new(2),v(3,j)*t+O_new(3),'g')
    %     end
    
    derror(:,:,i) = XPP-planepoint;
    derror2(i)=norm(derror(:,:,i),'fro');
    %derror2(i) = sum(sqrt(sum(derror(:,:,i).^2,2))); % 跟相機校正點座標的誤差
end
%derror3 = sum(derror2);
derror3=norm(derror2);
% figure
% plot3(derror(1,:,1),derror(2,:,1),derror(3,:,1),'y.')
% hold on
% plot3(derror(1,:,2),derror(2,:,2),derror(3,:,2),'yo')
% hold on
% plot3(derror(1,:,3),derror(2,:,3),derror(3,:,3),'b.')
% hold on
% plot3(derror(1,:,4),derror(2,:,4),derror(3,:,4),'bo')
% hold on
% plot3(derror(1,:,5),derror(2,:,5),derror(3,:,5),'r.')
% hold on
% plot3(derror(1,:,6),derror(2,:,6),derror(3,:,6),'ro')
% hold on
% plot3(derror(1,:,7),derror(2,:,7),derror(3,:,7),'g.')
% hold on
% plot3(derror(1,:,8),derror(2,:,8),derror(3,:,8),'go')
% hold on
% plot3(derror(1,:,9),derror(2,:,9),derror(3,:,9),'c.')
% hold on
% plot3(derror(1,:,10),derror(2,:,10),derror(3,:,10),'co')
% hold on
% plot3(derror(1,:,11),derror(2,:,11),derror(3,:,11),'k.')
