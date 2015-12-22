% load biosemi64 into q (which has sensor locations in polar coordinates
% add fiducials then save

clear
close all
clc

% supply the layout of biosemi64 cap
cfg = []; 
cfg.layout   = 'biosemi64.lay';
%ft_layoutplot(cfg);
lay = ft_prepare_layout(cfg);
disp(lay.label);

%zeroline = 92/40*50;

lay.label{65,1} = 'EXG1';
lay{65,2} = zeroline; %ten percent under FPz
lay{161,3} = lay{104,3};


lay.label{66,1} = 'EXG2';
lay{161,2} = zeroline; %ten percent under FPz
lay{161,3} = lay{104,3};

lay.label{66,1} = 'EXG2';
lay{161,2} = zeroline; %ten percent under FPz
lay{161,3} = lay{104,3};

lay.label{66,1} = 'EXG2';
lay{161,2} = zeroline; %ten percent under FPz
lay{161,3} = lay{104,3};


lay.label{65,1} = 'nasion';
lay{161,2} = zeroline; %ten percent under FPz
lay{161,3} = lay{104,3};


lay.label{65,1} = 'nasion';
lay{161,2} = zeroline; %ten percent under FPz
lay{161,3} = lay{104,3};


lay.label{65,1} = 'nasion';
lay{161,2} = zeroline; %ten percent under FPz
lay{161,3} = lay{104,3};

lay.label{162,1} = 'inion';
lay{162,2} = zeroline; %ten percent under Oz
lay{162,3} = lay{23,3};

lay{163,1} = 'left';
lay{163,2} = -zeroline; %ten percent under T7
lay{163,3} = lay{137,3};

lay{164,1} = 'right';
lay{164,2} = zeroline; %ten percent under T8
lay{164,3} = lay{64,3};

save('Layout_fiducials',lay);


% construct 3D electrode positions

load Layout_fiducials.mat

ph = cell2mat(lay(:,2));
th = cell2mat(lay(:,3));

x = sin(ph*pi/180) .* cos(th*pi/180);
y = sin(ph*pi/180) .* sin(th*pi/180);
z = cos(ph*pi/180);

plot3(x, y, z, '.');
elec.label = lay(:,1);
elec.pnt = [x y z];

% scale to get into mm
elec.pnt = 100*elec.pnt;

vol = ft_read_vol('headmodel/standard_vol.mat');

%realign electrodes to headmodel
cfg = [];
cfg.method = 'interactive';
cfg.elec = elec;
cfg.headshape = vol.bnd(1); %1 = skin
elec = ft_electroderealign(cfg);

%save new electrodes
save elec160.mat elec 