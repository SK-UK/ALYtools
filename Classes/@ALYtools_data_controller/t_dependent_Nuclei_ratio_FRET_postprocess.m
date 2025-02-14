function fig = t_dependent_Nuclei_ratio_FRET_postprocess(obj,in_fig,output_directory,~) 

     if ~isdir(output_directory), disp('wrong output directory, expect no output'), end
     
     fig = in_fig;

     [sX,sY,sC,sZ,nFovs] = size(fig);

% for saving - don't override!!!     
        fname = obj.current_filename;
        fname = strrep(fname,'.OME.tiff','');
        fname = strrep(fname,'.ome.tiff','');        
        fname = strrep(fname,'.OME.tif','');
        fname = strrep(fname,'.ome.tiff','');        
        fname = strrep(fname,'.tif','');
        fname = strrep(fname,'.lsm','');            
          
% % % %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot intensity
if 3==sC
    d_vals = zeros(1,nFovs);
    a_vals = zeros(1,nFovs);
    for k=1:nFovs
        ud = single(fig(:,:,1,1,k));
        ua = single(fig(:,:,2,1,k));
        nukes = fig(:,:,3,1,k);
        d_sample = ud(nukes==1);
        d_sample = single(d_sample(:));
        a_sample = ua(nukes==1);
        a_sample = single(a_sample(:));
        d_vals(k) = median(d_sample(:));
        a_vals(k) = median(a_sample(:));
    end
    h = figure;
    plot(1:nFovs,d_vals,'b.-',1:nFovs,a_vals,'r.-')
    xlabel('frame #');
    ylabel('intensity');
    legend({'donor','acceptor'})
    grid on;
    ax_new=gca;
    set(ax_new,'Position','default');
    legend(ax_new,'-DynamicLegend');
    saveName = [output_directory filesep fname '_segmented_intensities.fig'];
    saveas(h,saveName,'fig');
    close(h);
elseif 5==sC
    d_vals = zeros(1,nFovs);
    a_vals = zeros(1,nFovs);
    ref_vals = zeros(1,nFovs);    
    for k=1:nFovs
        ud = single(fig(:,:,1,1,k));
        ua = single(fig(:,:,2,1,k));
        uref = single(fig(:,:,4,1,k));        
        nukes = fig(:,:,3,1,k);
        cells = fig(:,:,5,1,k);        
        d_sample = ud(nukes==1);
        d_sample = single(d_sample(:));
        a_sample = ua(nukes==1);
        a_sample = single(a_sample(:));
        ref_sample = uref(cells==1);
        ref_sample = single(ref_sample(:));        
        d_vals(k) = median(d_sample(:));
        a_vals(k) = median(a_sample(:));
        ref_vals(k) = median(ref_sample(:));        
    end
    h = figure;
    plot(1:nFovs,d_vals,'b.-',1:nFovs,a_vals,'r.-',1:nFovs,ref_vals,'k.-')
    xlabel('frame #');
    ylabel('intensity');
    legend({'donor','acceptor','ref'})
    grid on;
    ax_new=gca;
    set(ax_new,'Position','default');
    legend(ax_new,'-DynamicLegend');
    saveName = [output_directory filesep fname '_segmented_intensities.fig'];
    saveas(h,saveName,'fig');
    close(h);       
end
% PARAMETERS USED TO CALCULATE FRET MOLAR FRACTION
% excitation exctinction coefficient
eps_A = obj.t_dependent_Nuclei_ratio_FRET_eps_A;
eps_D = obj.t_dependent_Nuclei_ratio_FRET_eps_D;
% optical system transmission
t_A  = obj.t_dependent_Nuclei_ratio_FRET_t_A;
t_D  = obj.t_dependent_Nuclei_ratio_FRET_t_D;
% quantum yield at room temperature
Q_A = obj.t_dependent_Nuclei_ratio_FRET_Q_A; % [ns] EYFP  
Q_D = obj.t_dependent_Nuclei_ratio_FRET_Q_D; % [ns] ECFP  
% lifetimes
tau_A = obj.t_dependent_Nuclei_ratio_FRET_tau_A; % [ns] EYFP  
tau_D = obj.t_dependent_Nuclei_ratio_FRET_tau_D; % [ns] ECFP 
% FRETting donor lifetime
tau_FRET = obj.t_dependent_Nuclei_ratio_FRET_tau_FRET; % [ns] - HIGH FRET
% spectral leakage coefficients
K_DA = obj.t_dependent_Nuclei_ratio_FRET_K_DA;
K_AD = obj.t_dependent_Nuclei_ratio_FRET_K_AD;
% ratio of excitation intensities in the donor and acceptor absorption bands, phi = IexD/IexA
phi = obj.t_dependent_Nuclei_ratio_FRET_phi;
% fraction of functional donor and acceptor
b_A = obj.t_dependent_Nuclei_ratio_FRET_b_A ; 
b_D = obj.t_dependent_Nuclei_ratio_FRET_b_D;
%
E = 1 - tau_FRET/tau_D;
A = 1/phi*(b_A/b_D)*(t_A/t_D)*(eps_A/eps_D)*(Q_A/Q_D);
B = b_A*E*Q_A/Q_D; % 1/Q_D correction is in accordance with "no Q_D factor for sensitized emisssion"
C = b_A*E;
% then beta_FRET = (Z-A)./(B+Z*C); where Z is FRET ratio calculated with bleed-through corrected intensities
% PARAMETERS USED TO CALCULATE FRET MOLAR FRACTION

% nucleus size
% donor intensity
% acceptor intensity
% intensity ratio
% Pearson correlation
% # neighbours (by SOI)
% cell density (by Delaunay) 
% FRET molar fraction 

obj.imgdata = []; % helps with memory

lab_nukes = zeros(sX,sY,nFovs);
%parfor k=1:nFovs
for k=1:nFovs
    nukes = single(fig(:,:,3,1,k));    
    lab_nukes(:,:,k) = bwlabel(nukes);
end

if 5==sC
    lab_cells = zeros(sX,sY,nFovs);
    % parfor k=1:nFovs
    for k=1:nFovs        
        cells = single(fig(:,:,5,1,k));    
        lab_cells(:,:,k) = bwlabel(cells);
    end
    %
    nuc_to_cell_luts = cell(nFovs,1);
    % parfor k=1:nFovs
    for k=1:nFovs        
        LN = lab_nukes(:,:,k);
        LC = lab_cells(:,:,k);
        nnucs = max(LN(:));
        lut_k = zeros(1,nnucs);
        for n=1:nnucs
            s = LC(LN==n);
            lut_k(1,n) = s(1);
        end
        nuc_to_cell_luts{k} = lut_k;
    end            
end

% all Z calculations are bound to the frame
NUCDATA = cell(1,nFovs);

track_mate_input = zeros(sX,sY,1,1,nFovs);

for k=1:nFovs
    tic
    ud = single(fig(:,:,1,1,k));
    ua = single(fig(:,:,2,1,k));
    if 5==sC
        uref = single(fig(:,:,4,1,k));
    end
    %
        try                    
            intensity_ratio = zeros(sX,sY);
            %
            L = lab_nukes(:,:,k);
            stats = regionprops(L,'Centroid','Area','Solidity','Perimeter','Eccentricity','Orientation');
            nnucs = max(L(:));
            %
            if 3==sC
                nuc_data = zeros(nnucs,11+5); % 11-th is molar fraction estimate + 5 nuc shape
            elseif 5==sC
                nuc_data = zeros(nnucs,15+5); % cyto area, cyto intensity ref, nuc intensity ref, and nuc/cyt ratio + 5 nuc shapes
                LC = lab_cells(:,:,k);
                lut_k = nuc_to_cell_luts{k};
            end
                
            XC = zeros(1,nnucs);
            YC = zeros(1,nnucs);
            
            for n=1:nnucs
                sample_a = single(ua(L==n));
                sample_d = single(ud(L==n));
                %
                nuc_data(n,1)=length(sample_a(:)); % area
                nuc_data(n,2)=0;
                %
                nuc_data(n,3)=corr(sample_a(:),sample_d(:),'type','Pearson');
                    mean_sample_a = mean(sample_a(:));
                    mean_sample_d = mean(sample_d(:));
                nuc_data(n,4)=mean_sample_a/mean_sample_d;
                nuc_data(n,5)=mean_sample_a;
                nuc_data(n,6)=mean_sample_d;
                nuc_data(n,7) = stats(n).Centroid(2);
                nuc_data(n,8) = stats(n).Centroid(1);                
                %
                XC(n)=stats(n).Centroid(2);
                YC(n)=stats(n).Centroid(1);
                %
                intensity_ratio(L==n)=mean_sample_a/mean_sample_d;

                % via corrected intensities
                IA = mean_sample_a - K_DA*mean_sample_d;
                ID = mean_sample_d - K_AD*mean_sample_a;
                Z = IA/ID;
                try
                    beta_FRET = (Z-A)./(B+Z*C);
                catch
                    beta_FRET = 0;
                end
%                 FRET_molar_fracton(L==n) = beta_FRET;
                nuc_data(n,11) = beta_FRET;                
                
                track_mate_input(round(XC(n)),round(YC(n)),1,1,k) = 1;
                
                if 5==sC
                    sample_ref_nuc = single(uref(L==n)); 
                    cell_lab = lut_k(n);
                    sample_ref_cell = single(uref(L~=n & LC==cell_lab));
                    area_ref_cell = single(uref(LC==cell_lab));
                    nuc_data(n,12) = length(area_ref_cell(:));
                    if ~isempty(sample_ref_cell)
                        nuc_data(n,13) = mean(sample_ref_cell(:));                        
                    else
                        nuc_data(n,13) = mean(sample_ref_nuc(:)); %??
                    end                        
                    nuc_data(n,14) = mean(sample_ref_nuc(:));
                    nuc_data(n,15) = nuc_data(n,14)/nuc_data(n,13);
                end 
                
                % nuclear shape factors
                if 3==sC
                    I0=11;
                elseif 5==sC
                    I0=15;
                end
                % solidity, perimeter, eccentricity, orientation
                nuc_data(n,I0+1) = stats(n).Solidity;
                nuc_data(n,I0+2) = (stats(n).Perimeter)^2/4/pi/stats(n).Area;
                nuc_data(n,I0+3) = stats(n).Eccentricity;
                nuc_data(n,I0+4) = stats(n).Orientation;
                nuc_data(n,I0+5) = rand; % RESERVED
                % nuclear shape
            end
            
            % adjacency matrices (symmetric)
                    % FOR SPEED ONLY
                    AJM_density = adjacency_matrix(XC,YC,'Delaunay');
                    AJM_nnghb = adjacency_matrix(XC,YC,'SOI');            
            % reasonable looking, but but slow
            % AJM_density = adjacency_matrix(XC,YC,'Gabriel');
            % AJM_nnghb = AJM_density;

            % distance matrix
            DM = squareform(pdist([XC' YC']));
            % number of neighbours vector
            NNGHB = sum(AJM_density,1);
            iNNGHB = 1./NNGHB; % matrix containing inverse #nnghb
            %
            % correct AJM_density for distances that are too long...
            AJM_density_fixed = AJM_density;
            dmax = 250/obj.microns_per_pixel; % 250 microns in pixels
            for kk=1:nnucs
                for jj=1:nnucs
                    if DM(kk,jj)>dmax
                        AJM_density_fixed(kk,jj)=0;
                    end
                end
            end
%             figure(22+k);            
%             ax=gca;
%             plot(XC,YC,'r.');
%             for kk=1:nnucs
%                 for jj=1:nnucs
%                     if kk<jj && 1==AJM_density(kk,jj)
%                         v1 = [XC(kk) XC(jj)];
%                         v2 = [YC(kk) YC(jj)];
%                         h=line(v1,v2);
%                         set(h,'Color','red');
%                         set(h,'LineStyle',':');
%                         set(h,'LineWidth',1);
%                         hold(ax,'on');
%                     end
%                     if kk<jj && 1==AJM_density_fixed(kk,jj)
%                         v1 = [XC(kk) XC(jj)];
%                         v2 = [YC(kk) YC(jj)];
%                         h=line(v1,v2);
%                         set(h,'Color','blue');
%                         hold(ax,'on');
%                     end
%                     if kk<jj && 1==AJM_nnghb(kk,jj)
%                         v1 = [XC(kk) XC(jj)];
%                         v2 = [YC(kk) YC(jj)];
%                         h=line(v1,v2);
%                         set(h,'Color','black');
%                         set(h,'LineStyle',':');
%                         set(h,'LineWidth',2);
%                         hold(ax,'on');
%                     end                           
%                  end
%             end
%             plot(ax,XC,YC,'r.');
%             hold(ax,'off');
%             daspect(ax,[1 1 1]);
%             axis(ax,[1 1024 1 1024])
%             disp('');
            % correct AJM_density for distances that are too long...            
            
            % for "natural" # neighbours
            NNGHB_NNGHB = sum(AJM_nnghb,1);
            %
            for n=1:nnucs
                % # neighbours
                nnghb = NNGHB_NNGHB(n);                                
                % estimate for cell density
                dstncs = DM(n,:).*AJM_density(n,:);
                dstncs = dstncs(0~=dstncs); % no zeros
                if ~isempty(dstncs)
                    davr = mean(dstncs);
                    density = (1 + iNNGHB(n))/(pi*davr^2);
                else
                    density = 0;
                end
                %
                nuc_data(n,9) = nnghb;
                nuc_data(n,10) = density;                
            end
            %            
            % replace binary segmentation in output for the A/D ratio multiplied by 100
            fig(:,:,3,1,k)=uint16(intensity_ratio*100);
            %
        catch ex
            disp(ex.message);
            disp(['glitch at index ' num2str(k)]);
        end
        %
        if isempty(nuc_data), continue, end
        %
        NUCDATA{k} = nuc_data;
        disp([num2str(k) ' ' num2str(toc)]);
end
%save('NUCDATA','NUCDATA'); %??

% gather statistics on frames
% 1 nuc_size 1
% 3 Pearson 2
% 6 D 3
% 5 A 4
% 4 FRET ratio 5
% 9 nnghb 6
% 10 cell density 7
% 11 FRET fraction 8 - without nuclear params, without 3rd channel
if 3==sC
    indices = [1 3 6 5 4 9 10 11, 12, 13, 14, 15, 16]; % 13 - 12/2020 layout
    NUC_STATS = zeros(nFovs,13,5); % mean, std, median, 025Q, 075Q
    for k=1:nFovs
        nuc_data = NUCDATA{k};
        % parfor j=1:numel(indices)
        for j=1:numel(indices)            
            index = indices(j);
            s = squeeze(nuc_data(:,index)); %sample
            s = s(~isinf(s));
            s = s(~isnan(s));        
            NUC_STATS(k,j,:) = [mean(s) std(s) median(s) quantile(s,.25) quantile(s,.75)];
        end
    end
else
% 12 total cell area (incl.nucleus)
% 13 cell intensity in reference channel
% 14 nucleus intensity in reference channel
% 15 intensity ratio nuc/cell in ref. channel
    indices = [1 3 6 5 4 9 10 11 12 13 14 15, 16, 17, 18, 19, 20];
    NUC_STATS = zeros(nFovs,17,5); % mean, std, median, 025Q, 075Q
    for k=1:nFovs
        nuc_data = NUCDATA{k};
        % parfor j=1:numel(indices)
        for j=1:numel(indices)            
            index = indices(j);
            s = squeeze(nuc_data(:,index)); %sample
            s = s(~isinf(s));
            s = s(~isnan(s));        
            NUC_STATS(k,j,:) = [mean(s) std(s) median(s) quantile(s,.25) quantile(s,.75)];
        end
    end    
end
% gather statistics on frames - end

clear('lab_cells');

% fix NUCDATA :)
%%%%%%%%%%%%%%%%%%%%%%%%%%%% that is legacy; should't happen
Z = NUCDATA;
cell_nums = zeros(1,numel(Z));
for k=1:numel(Z)
    if isempty(Z{k})
        Z{k}=Z{k-1};        
    end
    cell_nums(k)=length(Z{k});
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%

t = (0:numel(NUCDATA)-1)*obj.t_dependent_Nuclei_ratio_FRET_TIMESTEP;

% save N(t) curve
if ispc
    xlswrite([output_directory filesep fname ' cell numbers curve.xls'],[t' cell_nums']);
else
    xlwrite([output_directory filesep fname ' cell numbers curve.xls'],[t' cell_nums']);
end
        
% TRACKING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
          
     track_mate_input = track_mate_input*10000;
     smoothing_radius = 1;
     % parfor k=1:nFovs
     for k=1:nFovs         
        track_mate_input(:,:,1,1,k)=gsderiv(squeeze(track_mate_input(:,:,1,1,k)),smoothing_radius,0);
     end                       
     imp = copytoImagePlus(track_mate_input,'dimorder','XYCZT');
        % test image
        % imp = ij.IJ.openImage('http://fiji.sc/samples/FakeTracks.tif');
     %imp.show();
     %
        % Some of the parameters we configure below need to have
        % a reference to the model at creation. So we create an
        % empty model now.
        model = fiji.plugin.trackmate.Model();

        % Send all messages to ImageJ log window.
        % model.setLogger(fiji.plugin.trackmate.Logger.IJ_LOGGER)

        %------------------------
        % Prepare settings object
        %------------------------

        settings = fiji.plugin.trackmate.Settings();
        settings.setFrom(imp)

        % Configure detector - We use a java map
        settings.detectorFactory = fiji.plugin.trackmate.detection.LogDetectorFactory();
        map = java.util.HashMap();
        map.put('DO_SUBPIXEL_LOCALIZATION', true);
        %map.put('RADIUS', obj.TrackMate_RADIUS); % parameter excessive
            map.put('RADIUS',2);
        map.put('TARGET_CHANNEL', obj.TrackMate_TARGET_CHANNEL);
        map.put('THRESHOLD', obj.TrackMate_THRESHOLD);
        map.put('DO_MEDIAN_FILTERING', obj.TrackMate_DO_MEDIAN_FILTERING);
        settings.detectorSettings = map;

        % Configure spot filters - Classical filter on quality
        filter1 = fiji.plugin.trackmate.features.FeatureFilter('QUALITY', obj.TrackMate_QUALITY, true);
        settings.addSpotFilter(filter1)

        % Configure tracker
        settings.trackerFactory  = fiji.plugin.trackmate.tracking.sparselap.SparseLAPTrackerFactory();
        settings.trackerSettings = fiji.plugin.trackmate.tracking.LAPUtils.getDefaultLAPSettingsMap(); % almost good enough
        settings.trackerSettings.put('ALLOW_TRACK_SPLITTING', obj.TrackMate_ALLOW_TRACK_SPLITTING);
        settings.trackerSettings.put('ALLOW_TRACK_MERGING', obj.TrackMate_ALLOW_TRACK_MERGING);
        %
        %https://forum.image.sc/t/trackmate-memory-issue-when-run-in-matlab/3424
        settings.trackerSettings.put('LINKING_MAX_DISTANCE',obj.TrackMate_LINKING_MAX_DISTANCE); % pixels
        settings.trackerSettings.put('GAP_CLOSING_MAX_DISTANCE',obj.TrackMate_GAP_CLOSING_MAX_DISTANCE); % pixels
        settings.trackerSettings.put('MAX_FRAME_GAP', java.lang.Integer(obj.TrackMate_MAX_FRAME_GAP)); % frames
                                        
        % Configure track analyzers - Later on we want to filter out tracks 
        % based on their displacement, so we need to state that we want 
        % track displacement to be calculated. By default, out of the GUI, 
        % not features are calculated. 
        %
        % The displacement feature is provided by the TrackDurationAnalyzer.
        settings.addTrackAnalyzer(fiji.plugin.trackmate.features.track.TrackDurationAnalyzer())
        % Configure track filters - We want to get rid of the two immobile spots at 
        % the bottom right of the image. Track displacement must be above 10 pixels.
        filter2 = fiji.plugin.trackmate.features.FeatureFilter('TRACK_DISPLACEMENT', obj.TrackMate_TRACK_DISPLACEMENT, true); % pixels
        settings.addTrackFilter(filter2)

        %-------------------
        % Instantiate plugin
        %-------------------
        trackmate = fiji.plugin.trackmate.TrackMate(model, settings);

        %--------
        % Process
        %--------
        ok = trackmate.checkInput();
        if ~ok
            display(trackmate.getErrorMessage())
        end

        ok = trackmate.process();
        if ~ok
            display(trackmate.getErrorMessage())
        else
            % Echo results
            display(model.toString());
        end
        
        %----------------
        % Display results
        %----------------
%         selectionModel = fiji.plugin.trackmate.SelectionModel(model);
%         displayer =  fiji.plugin.trackmate.visualization.hyperstack.HyperStackDisplayer(model, selectionModel, imp);
%         %displayer =  fiji.plugin.trackmate.visualization.hyperstack.HyperStackDisplayer(model, selectionModel, copytoImagePlus(dum,'dimorder','XYZCT'));        
%         displayer.render()
%         displayer.refresh()

        % fname = [tempname,'.xml'];
        fullfname = [output_directory filesep fname '_RAW_TRACKMATE_OUTPUT' '.xml'];                        
        file = java.io.File(fullfname);
        fiji.plugin.trackmate.action.ExportTracksToXML.export(model, settings, file);        
        tracks = importTrackMateTracks(file,false);         
                        
        % DEBUG
%         icyvol = fig;                
%         for k=1:numel(tracks)
%             track = tracks{k};
%             for m=1:size(track,1)
%                 frame = track(m,1)+1;
%                 x = round(track(m,2))+1;
%                 y = round(track(m,3))+1;
%                 try
%                 icyvol(x,y,3,1,frame) = 255;
%                 catch
%                     disp([x y frame]);
%                 end
%             end
%         end                
%         icy_imshow(uint16(icyvol));    

clear('track_mate_input');

OK_tracks_indices = [];
min_track_length = 4;
% matching
        for k=1:numel(tracks)
            track = tracks{k};
            if 3==sC
                ext_track = zeros(size(track,1),11+5); %frame,x,y+13 params
            elseif 5==sC
                ext_track = zeros(size(track,1),15+5); %frame,x,y+17 params
            end
            %
            if size(track,1)>=min_track_length
                OK_tracks_indices = [OK_tracks_indices; k];
                        
            for m=1:size(track,1)
                frame = track(m,1)+1;
                x = round(track(m,2))+1;
                y = round(track(m,3))+1;
                %                                
                nuc_lab = lab_nukes(x,y,frame); % may be problems - 0s                              
                if  0==nuc_lab
                    disp('correcting orphan TrackMate point..');
                    % try to look for label nearby                    
                    w = round(5/obj.microns_per_pixel);
                    roix = max(1,x-w):min(sX,x+w);
                    roiy = max(1,y-w):min(sY,y+w);
                    L = squeeze(lab_nukes(:,:,frame));
                    s = L(roix,roiy);
                    nuc_lab = max(s(:)); % a bit risky..
                end                
                if 0 == nuc_lab, nuc_lab = 1; end % :) - last resort - shouldn't happen
                %
                    nuc_data = NUCDATA{frame};                                                
                    nucleus_size =          nuc_data(nuc_lab,1);
                    donor_intensity =       nuc_data(nuc_lab,6);
                    acceptor_intensity =    nuc_data(nuc_lab,5);
                    FRET_ratio =            nuc_data(nuc_lab,4);
                    Pearson_correlation =   nuc_data(nuc_lab,3);
                    nnghb =                 nuc_data(nuc_lab,9);
                    cell_density =          nuc_data(nuc_lab,10);
                    beta_FRET =             nuc_data(nuc_lab,11);
                    if 5==sC
                        cell_area = nuc_data(nuc_lab,12);
                        cell_intensity_ref = nuc_data(nuc_lab,13);
                        nuc_intensity_ref = nuc_data(nuc_lab,14);
                    end
                    
                    ext_track(m,1) = frame;
                    ext_track(m,2) = track(m,2);
                    ext_track(m,3) = track(m,3);
                    ext_track(m,7) = nucleus_size; 
                    ext_track(m,5) = donor_intensity;
                    ext_track(m,6) = acceptor_intensity; 
                    ext_track(m,4) = FRET_ratio; 
                    ext_track(m,8) = Pearson_correlation;
                    ext_track(m,9) = nnghb;
                    ext_track(m,10) = cell_density;
                    ext_track(m,11) = beta_FRET;
                    if 5==sC
                        ext_track(m,12) = cell_area;
                        ext_track(m,13) = cell_intensity_ref;
                        ext_track(m,14) = nuc_intensity_ref;
                        ext_track(m,15) = nuc_intensity_ref/cell_intensity_ref;
                    end
                    
% nuclear shape
                    if 3==sC
                        I0 = 11;
                    elseif 5==sC
                        I0 = 15;
                    end
                    solidity =              nuc_data(nuc_lab,I0+1);
                    shape_factor =          nuc_data(nuc_lab,I0+2);
                    eccentricity =          nuc_data(nuc_lab,I0+3);
                    orientation =           nuc_data(nuc_lab,I0+4);
                    ext_track(m,I0+1) = solidity;
                    ext_track(m,I0+2) = shape_factor;
                    ext_track(m,I0+3) = eccentricity;
                    ext_track(m,I0+4) = orientation;
                    ext_track(m,I0+5) = rand; % RESERVED
% nuclear shape
                                        
                 %
            end
            end % if track is not too short
            %
            tracks{k} = ext_track;
        end
        tracks = tracks(OK_tracks_indices);

fullfname = [output_directory filesep fname '_FRET_ratio_featured_TRACKMATE_OUTPUT.mat'];
dt = obj.t_dependent_Nuclei_ratio_FRET_TIMESTEP;
microns_per_pixel = obj.microns_per_pixel;
%

save(fullfname,'tracks','dt','microns_per_pixel','NUC_STATS','cell_nums');

% TRACKING %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% try
%     track_breaking_flag = true;
% t_dependent_Nuclei_ratio_FRET_TrackPlotter(tracks,... 
%     obj.t_dependent_Nuclei_ratio_FRET_TIMESTEP, ...
%     obj.microns_per_pixel, ...
%     fname, ...
%     track_breaking_flag);
% catch
%     disp('error when trying to initiate t_dependent_Nuclei_ratio_FRET_TrackPlotter');
% end
        fig = uint16(reshape(fig,[sX sY sC nFovs sZ]));  % XYCTZ                       
end
