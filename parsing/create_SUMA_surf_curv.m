function create_SUMA_surf_curv(subject)
% generate individual SUMA surfaces and curvature
% yiwen 20.01.2016

% clear all
% conn_analysis_defaults
%
% cd(rootpath); % take the rootpath as current directory of matlab
%
% % allSubjects = [controls; focals; ige; spanish]; % pool the names together
% allSubjects = new;
%
%dataDir = fullfile(rootpath,'results','02-head-anatomy');
dataDir = fullfile('./','source_space','FS');
%
% nSubject = length(allSubjects); % number of subjects
%
% for iSubject = 1:length(allSubjects)
%     subject = allSubjects{iSubject};

SubjectDir = fullfile(dataDir, [subject '-FS']);
disp(['creating SUMA inf_200 surface ' subject]);

SUMADir = fullfile(SubjectDir,'MEG','SUMA');
CurvDir = fullfile(SubjectDir,'bem','SUMA');

if exist(fullfile(SUMADir,'sourcespace_S_SUMA_inf_200.mat'),'file')==2
    load(fullfile(SUMADir,'sourcespace_S_SUMA_inf_200.mat'));
else
    
    % read in the partially inflated ld10 brain surface mesh file processed from SUMA
    file_LH = fullfile(CurvDir,'std.10.lh.inf_200.gii');
    file_RH = fullfile(CurvDir,'std.10.rh.inf_200.gii');
    if exist(file_LH,'file')==2
        sourcespace_S_SUMA_inf_200 = ft_read_headshape({file_LH file_RH }, 'format', 'gifti');
    else
        %load(fullfile(rootpath,'utilities','SUMA_sourcespace')); % load the template SUMA sourcespace
        file_LH = fullfile(CurvDir,'std.10.lh.inf_200.asc');
        file_RH = fullfile(CurvDir,'std.10.rh.inf_200.asc');
        [S, v, f] = read_asc(file_LH);
        sourcespace_S_SUMA_inf_200 = SUMA_sourcespace;
        sourcespace_S_SUMA_inf_200.pnt = v(:,1:3);
        sourcespace_S_SUMA_inf_200.tri = f(:,1:3);
        [S, v, f] = read_asc(file_RH);
        sourcespace_S_SUMA_inf_200.pnt = [sourcespace_S_SUMA_inf_200.pnt; v(:,1:3)];
        sourcespace_S_SUMA_inf_200.tri = [sourcespace_S_SUMA_inf_200.tri; f(:,1:3)+S(2)];
    end
    
    % trisurf(sourcespace_S_SUMA_inf_200.tri,sourcespace_S_SUMA_inf_200.pnt(:,1),sourcespace_S_SUMA._inf_200pnt(:,2),sourcespace_S_SUMA_inf_200.pnt(:,3));
    
    %         sourcespace_S_SUMA_inf_200 = ft_convert_units(sourcespace_S_SUMA_inf_200, 'cm');
    %         load(fullfile(SUMADir,'transformationM.mat'));
    %
    %         sourcespace_S_SUMA_inf_200 = ft_transform_geometry(T, sourcespace_S_SUMA_inf_200);
    
    save(fullfile(SUMADir,'sourcespace_S_SUMA_inf_200.mat'), 'sourcespace_S_SUMA_inf_200');
    
end

disp(['creating SUMA ld10 curvature for each hemisphere ' subject]);

% separate left and right hemisphere
if isfield(sourcespace_S_SUMA_inf_200,'pnt') % created from old fieldtrip version
    sourcespace_S_SUMA_inf_200_LH = sourcespace_S_SUMA_inf_200;
    sourcespace_S_SUMA_inf_200_LH.pos = sourcespace_S_SUMA_inf_200.pnt(1:1002,:);
    sourcespace_S_SUMA_inf_200_LH.tri = sourcespace_S_SUMA_inf_200.tri(1:2000,:);
    sourcespace_S_SUMA_inf_200_LH = rmfield(sourcespace_S_SUMA_inf_200_LH,{'brainstructure','brainstructurelabel','pnt'});
    
    sourcespace_S_SUMA_inf_200_RH = sourcespace_S_SUMA_inf_200;
    sourcespace_S_SUMA_inf_200_RH.pos = sourcespace_S_SUMA_inf_200.pnt(1003:2004,:);
    sourcespace_S_SUMA_inf_200_RH.tri = sourcespace_S_SUMA_inf_200.tri(2001:4000,:);
    sourcespace_S_SUMA_inf_200_RH.tri = sourcespace_S_SUMA_inf_200_RH.tri-1002;
    sourcespace_S_SUMA_inf_200_RH = rmfield(sourcespace_S_SUMA_inf_200_RH,{'brainstructure','brainstructurelabel','pnt'});
    
else
    sourcespace_S_SUMA_inf_200_LH = sourcespace_S_SUMA_inf_200;
    sourcespace_S_SUMA_inf_200_LH.pos = sourcespace_S_SUMA_inf_200.pos(1:1002,:);
    sourcespace_S_SUMA_inf_200_LH.tri = sourcespace_S_SUMA_inf_200.tri(1:2000,:);
    sourcespace_S_SUMA_inf_200_LH = rmfield(sourcespace_S_SUMA_inf_200_LH,{'brainstructure','brainstructurelabel'});
    
    sourcespace_S_SUMA_inf_200_RH = sourcespace_S_SUMA_inf_200;
    sourcespace_S_SUMA_inf_200_RH.pos = sourcespace_S_SUMA_inf_200.pos(1003:2004,:);
    sourcespace_S_SUMA_inf_200_RH.tri = sourcespace_S_SUMA_inf_200.tri(2001:4000,:);
    sourcespace_S_SUMA_inf_200_RH.tri = sourcespace_S_SUMA_inf_200_RH.tri-1002;
    sourcespace_S_SUMA_inf_200_RH = rmfield(sourcespace_S_SUMA_inf_200_RH,{'brainstructure','brainstructurelabel'});
end

% add curvature data for each hemisphere
file_LH = fullfile(CurvDir,'std.10.lh.curv.niml.dset');
file_RH = fullfile(CurvDir,'std.10.rh.curv.niml.dset');

[curv] = read_SUMA_curvature(file_LH);
sourcespace_S_SUMA_inf_200_LH.curv = cell2mat(curv);
[curv] = read_SUMA_curvature(file_RH);
sourcespace_S_SUMA_inf_200_RH.curv = cell2mat(curv);

save(fullfile(SUMADir,'sourcespace_S_SUMA_inf_200_LH.mat'), 'sourcespace_S_SUMA_inf_200_LH');
save(fullfile(SUMADir,'sourcespace_S_SUMA_inf_200_RH.mat'), 'sourcespace_S_SUMA_inf_200_RH');
end
