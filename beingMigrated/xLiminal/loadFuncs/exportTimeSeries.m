% loads in average time-series from each run, for each subject, from V1
%
%   Save out a .mat file of the average time-series
%   vector of the modulation direction, and the temporal structure of the
%   different frequencies (i.e. the design of the experiment).
%
%
%% set up variables
%output
dbDir = '/Users/giulia/Dropbox-Aguirre-Brainard-Lab/MELA_analysis/HCLV_Photo_7T';


%input
data_dir = '/data/jag/MELA/MOUNT_SINAI/';

subj_names = { ...
    'HERO_asb1' ...
    'HERO_gka1'...
    };

sessions = { ...
    '041416' ...
    '041516' ...
    };

hemis = { ...
    'lh' ...
    'rh' ...
    };
F_surfs = { ...  % functional surfaces
    's5.wdrf.tf.surf.lh.nii.gz' ...
    's5.wdrf.tf.surf.rh.nii.gz' ...
    };

A_surfs = { ...  % anatomical surfaces
    'lh.areas.anat.nii.gz' ...
    'rh.areas.anat.nii.gz' ...
    };

%%
for nn = 1: length(subj_names) % for every subject
    subj_name = subj_names{nn};
    for ss = 1: length(sessions) % for every session
        session = sessions{ss};
        
        session_dir = fullfile(data_dir, subj_name,session); % path to current session directory
        
        stim_dir = fullfile(session_dir,'Stimuli'); % path to stimulus folder
        
        anat_dir = fullfile(session_dir,'anat_templates'); % path to the anatomical surfaces
        
        [d] = find_bold(session_dir); % find bold runs
        
        
        for hh = 1: length(A_surfs)
            A_surf = A_surfs{hh};
            hemi = hemis {hh};
            
            % load anatomical surface
            anat = fullfile(anat_dir,A_surf);
            a = load_nifti(anat);
            V1ind = find(abs(a.vol)==1);
            
            
            for bb = 1: length(d)
                bold_dir = d{bb};
                
                
                % load functional surface
                F_surf = F_surfs{hh};
                func = fullfile(session_dir, bold_dir, F_surf);
                f = load_nifti(func);
                
                % Get the average time-series
                tmpF = squeeze(f.vol);
                avgTC = mean(tmpF(V1ind,:));
                
                % Save out a .mat file
                
                outDir = fullfile(dbDir,'mriTemporalFitting_data', subj_name);
                if ~exist(outDir,'dir')
                    mkdir(outDir);
                end

                outFile = fullfile(outDir, [hemi '_'  bold_dir '.mat']);
                save(outFile,'avgTC');
            end
        end 
    end
end
        
    
        
        

        
     
        

