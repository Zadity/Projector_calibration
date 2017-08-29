function [ D,Kproj,pxx,pyy,planepoint ] = sol_in_parms( parm )
O = parm(1:3);
Z = parm(4:6);
load tempdata.mat
[nx, ny] = size(points_2d);

v = Meanpts - O*ones(1,ny);
norm_v = sqrt(sum(v.^2,1));
v = v./(ones(3,1)*norm_v);

% �D�X�������Υ����W���I
O2 = O+Z;
t = 1./(v'*Z);
tt = repmat(t',3,1);
vt = tt.*v;
planepoint = O*ones(1,ny)+vt;

% �w�q�s�y�� �y���ܴ�
px = [planepoint(:,proj_square_data(1)^2/2)-O2];
%px = [planepoint(:,24)-O2];
pxx = px/norm(px); % new coordinate
pyy = cross(Z,pxx);
Mpoints = planepoint-O2*ones(1,ny);
% sol = zeros(2,ny);
A = [pxx pyy Z];

for i = 1:ny
    b = Mpoints(:,i);
    temp = A\b; % (x,y,1):�HO2������ pxx pyy����
    planepoint2(1:2,i)=temp(1:2,1);
end

% ��least square�⤺���Ѽ�
L = [];
LL = [];
for i = 1:ny
    L = [L;planepoint2(1,i),planepoint2(2,i),1,0,0;0,0,0,planepoint2(2,i),1];
    LL = [LL;points_2d(1,i);points_2d(2,i)];
end
Kparm = L\LL;
Kproj = [Kparm(1) Kparm(2) Kparm(3);0 Kparm(4) Kparm(5);0 0 1];

d = [points_2d;ones(1,ny)] - Kproj*[planepoint2;ones(1,ny)];
D = norm(d,'fro');%sum(sqrt(sum(d.^2,1)));

end

