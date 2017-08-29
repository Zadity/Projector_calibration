function [ corners ] = corner_pts( I,dX,dY,n_square,p )
x_c = (dX+1)/2;
y_c = (dY+1)/2;
nn = n_square/2;
ty = [nn-n_square:n_square-nn];
tx = -ty;
x = x_c*ones(1,n_square+1)+p.*tx;
y = y_c*ones(1,n_square+1)+p.*ty;
xx = kron(x,ones(1,n_square+1));
yy = repmat(y,1,n_square+1);
corners = [xx;yy];
end

