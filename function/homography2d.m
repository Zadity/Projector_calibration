function [ E ] = homography2d( x )
R = [x(1) x(2);x(3) x(4)];
% s = x(5);
s = [x(5) x(6);x(7) x(8)];
load('Hpoint2.mat')
D = s*R*invpts(1:2,:)-planepoint2;
DD = sqrt(sum(abs(D.^2),1));
E = sum(DD);
end

