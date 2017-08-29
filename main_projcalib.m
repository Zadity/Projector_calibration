addpath function

cell_list = {};
fig_number = 1;

title_figure = 'Projector Calibration - Select mode of operation:';

cell_list{1,1} = {'click the corner of image','clickpoint;'};
cell_list{2,1} = {'calibration','sol_projparm;'};
cell_list{3,1} = {'compute axis','R_axis;'};
cell_list{4,1} = {'Exit',['disp(''Bye.''); close(' num2str(fig_number) ');']};

show_window(cell_list,fig_number,title_figure,290,18,0,'clean',12);