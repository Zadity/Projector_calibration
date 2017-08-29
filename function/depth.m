function [ trueP ] = depth( Pcam,Pcam1,Pcam2,Pcam3,Pcam4,campoints,projpoints)
A1 = [Pcam(3,:)*campoints(1,1)-Pcam(1,:);Pcam(3,:)*campoints(2,1)-Pcam(2,:);Pcam1(3,:)*projpoints(1,1)-Pcam1(1,:);Pcam1(3,:)*projpoints(2,1)-Pcam1(2,:)];
A2 = [Pcam(3,:)*campoints(1,1)-Pcam(1,:);Pcam(3,:)*campoints(2,1)-Pcam(2,:);Pcam2(3,:)*projpoints(1,1)-Pcam2(1,:);Pcam2(3,:)*projpoints(2,1)-Pcam2(2,:)];
A3 = [Pcam(3,:)*campoints(1,1)-Pcam(1,:);Pcam(3,:)*campoints(2,1)-Pcam(2,:);Pcam3(3,:)*projpoints(1,1)-Pcam3(1,:);Pcam3(3,:)*projpoints(2,1)-Pcam3(2,:)];
A4 = [Pcam(3,:)*campoints(1,1)-Pcam(1,:);Pcam(3,:)*campoints(2,1)-Pcam(2,:);Pcam4(3,:)*projpoints(1,1)-Pcam4(1,:);Pcam4(3,:)*projpoints(2,1)-Pcam4(2,:)];
NA1 = [norm(A1(1,:)) norm(A1(2,:)) norm(A1(3,:)) norm(A1(4,:))];
NA2 = [norm(A2(1,:)) norm(A2(2,:)) norm(A2(3,:)) norm(A2(4,:))];
NA3 = [norm(A3(1,:)) norm(A3(2,:)) norm(A3(3,:)) norm(A3(4,:))];
NA4 = [norm(A4(1,:)) norm(A4(2,:)) norm(A4(3,:)) norm(A4(4,:))];
Anorm1=[A1(1,:)./NA1(1);A1(2,:)./NA1(2);A1(3,:)./NA1(3);A1(4,:)./NA1(4)];
Anorm2=[A2(1,:)./NA2(1);A2(2,:)./NA2(2);A2(3,:)./NA2(3);A2(4,:)./NA2(4)];
Anorm3=[A3(1,:)./NA3(1);A3(2,:)./NA3(2);A3(3,:)./NA3(3);A3(4,:)./NA3(4)];
Anorm4=[A4(1,:)./NA4(1);A4(2,:)./NA4(2);A4(3,:)./NA4(3);A4(4,:)./NA4(4)];

[~,~,V1]=svd(Anorm1);
[~,~,V2]=svd(Anorm2);
[~,~,V3]=svd(Anorm3);
[~,~,V4]=svd(Anorm4);
X = zeros(4,4);
X(:,1)=V1(:,end);
X(:,2)=V2(:,end);
X(:,3)=V3(:,end);
X(:,4)=V4(:,end);

w1 = Pcam1*X(:,1);
w2 = Pcam2*X(:,2);
w3 = Pcam3*X(:,3);
w4 = Pcam4*X(:,4);
w = [w1(3) w2(3) w3(3) w4(3)];
for i=1:4
    d(i) = (sign(det(Pcam(:,1:3)))*w(i) ) / (X(4,i)*norm(Pcam(3,1:3)));
end
d1 = (sign(det(Pcam1(:,1:3)))*w1(3) )/ (X(4,1)*norm(Pcam1(3,1:3)));
d2 = (sign(det(Pcam2(:,1:3)))*w2(3) )/ (X(4,2)*norm(Pcam2(3,1:3)));
d3 = (sign(det(Pcam3(:,1:3)))*w3(3) )/ (X(4,3)*norm(Pcam3(3,1:3)));
d4 = (sign(det(Pcam4(:,1:3)))*w4(3) )/ (X(4,4)*norm(Pcam4(3,1:3)));

if (d1>0)&(d(1)>0)
    trueP=Pcam1;
end
if (d2>0)&(d(2)>0)
    trueP=Pcam2;
end
if (d3>0)&(d(3)>0)
    trueP=Pcam3;
end
if (d4>0)&(d(4)>0)
    trueP=Pcam4;
end

end

