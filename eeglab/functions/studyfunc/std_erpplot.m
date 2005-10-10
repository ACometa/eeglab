% cls_plotclusterp() - Commandline function, to visualizing cluster/s components ERP. 
%                   Either displays mean ERP of all requested clusters in the same figure, 
%                   with spectra for different conditions (if any) plotted in different colors. 
%                   Or displays ERP for each specified cluster in separate figures (per condition),  
%                   each containing the cluster component ERPs plus the average cluster ERP in bold.
%                   The ERP can be visualized only if component ERPs     
%                   were calculated and saved in the EEG datasets in the STUDY.
%                   These can be computed during pre-clustering using the GUI-based function
%                   pop_preclust() or the equivalent commandline functions eeg_createdata() 
%                   and eeg_preclust(). A pop-function that calls this function is pop_clustedit().
% Usage:    
%                   >> [STUDY] = cls_plotclusterp(STUDY, ALLEEG, key1, val1, key2, val2);  
% Inputs:
%   STUDY      - EEGLAB STUDY set comprising some or all of the EEG datasets in ALLEEG.
%   ALLEEG     - global EEGLAB vector of EEG structures for the dataset(s) included in the STUDY. 
%                     ALLEEG for a STUDY set is typically created using load_ALLEEG().  
%
% Optional inputs:
%   'clusters'   - [numeric vector]  -> specific cluster numbers to plot.
%                     'all'                         -> plot all clusters in STUDY.
%                     {default: 'all'}.
%   'mode'       - ['centroid'|'comps'] a plotting mode. In 'centroid' mode, the average ERPs 
%                     of the requested clusters are plotted in the same figure, with ERPs for  
%                     different conditions (if any) plotted in different colors. In 'comps' mode, ERPS
%                     for each specified cluster are plotted in separate figures (per condition), each 
%                     containing cluster component ERPs plus the average cluster ERP in bold.
%                     {default: 'centroid'}.
%   'figure'       - ['on'|'off'] for the 'centroid' mode option, plots on
%                     a new figure ('on')  or plots on current figure ('off').
%                     {default: 'on'}.
%
% Outputs:
%   STUDY    - the input STUDY set structure modified with plotted cluster 
%                     mean ERP, to allow quick replotting (unless cluster means 
%                     already exists in the STUDY).  
%
%   Example:
%                         >> [STUDY] = cls_plotclustspec(STUDY,ALLEEG, 'clusters', 2, 'mode', 'comps');
%                    Plots cluster 2 components spectra along with the mean spectra in bold. 
%
%  See also  pop_clustedit, pop_preclust, eeg_createdata, cls_plotcompspec         
%
% Authors:  Hilit Serby, Arnaud Delorme, Scott Makeig, SCCN, INC, UCSD, June, 2005

%123456789012345678901234567890123456789012345678901234567890123456789012

% Copyright (C) Hilit Serby, SCCN, INC, UCSD, June 07, 2005, hilit@sccn.ucsd.edu
%
% This program is free software; you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation; either version 2 of the License, or
% (at your option) any later version.
%
% This program is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with this program; if not, write to the Free Software
% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

function STUDY = cls_plotclusterp(STUDY, ALLEEG,  varargin)
icadefs;

% Set default values
cls = 2:length(STUDY.cluster); % plot all clusters in STUDY
mode = 'centroid'; % plot clusters centroid 
figureon = 1; % plot on a new figure
for k = 3:2:nargin
    switch varargin{k-2}
        case 'clusters'
            if isnumeric(varargin{k-1})
                cls = varargin{k-1};
                if isempty(cls)
                    cls = 2:length(STUDY.cluster);
                end
            else
                if isstr(varargin{k-1}) & strcmpi(varargin{k-1}, 'all')
                    cls = 2:length(STUDY.cluster);
                else
                    error('cls_plotclustersp: ''clusters'' input takes either specific clusters (numeric vector) or keyword ''all''.');
                end
            end
        case 'mode' % Plotting mode 'centroid' / 'comps'
            mode = varargin{k-1};
        case 'figure'
            if strcmpi(varargin{k-1},'off')
                figureon = 0;
            end
    end
end

tmp =[];
for k = 1: length(cls)
    % don't include 'Notclust' clusters
    if ~strncmpi('Notclust',STUDY.cluster(cls(k)).name,8) & ~strncmpi('ParentCluster',STUDY.cluster(cls(k)).name,13)
        tmp = [tmp cls(k)];
    end
end
cls = tmp;
clear tmp

Ncond = length(STUDY.condition);
if Ncond == 0
    Ncond = 1;
end
% Plot all the components in the cluster ('comps' mode)
if strcmpi(mode, 'comps')         
    for clus = 1: length(cls) % For each cluster requested
        len = length(STUDY.cluster(cls(clus)).comps);
        if ~isfield(STUDY.cluster(cls(clus)).centroid, 'erp')
            STUDY = cls_centroid(STUDY,ALLEEG, cls(clus) , 'erp');
        end
        % For ERP match polarity accross conditions
        for condi = 1: Ncond
            ave_erp(:,condi) = STUDY.cluster(cls(clus)).centroid.erp{condi};
            if  condi == Ncond
                [tmp Avepol] = comppol(ave_erp);
                clear tmp ave_erp
            end
        end
        for n = 1:Ncond
            try
                clusnval = cls_clusread(STUDY, ALLEEG, cls(clus),'erp',n);
            catch,
                warndlg2([ 'Some ERP information is missing, aborting'] , ['Abort - Plot ERP'] );   
                return;
           end
           figure
           orient tall
            ave_erp = STUDY.cluster(cls(clus)).centroid.erp{n};
            t = STUDY.cluster(cls(clus)).centroid.erp_t;
            [all_erp pol] = comppol(clusnval.erp');
            plot(t/1000,Avepol(n)*all_erp,'color', [0.5 0.5 0.5]);
            hold on
            plot(t/1000,Avepol(n)*ave_erp,'k','linewidth',2);
            xlabel('time [s]');
            ylabel('activations');
            title(['ERP, '  STUDY.cluster(cls(clus)).name ', ' STUDY.condition{n} ', ' num2str(length(unique(STUDY.cluster(cls(clus)).sets(1,:)))) 'Ss']);
            % Make common axis to all conditions
            if n == 1
                ylimits = get(gca,'YLim');
            else
                tmp = get(gca,'YLim');
                ylimits(1) = min(tmp(1),ylimits(1) );
                ylimits(2) = max(tmp(2),ylimits(2) );
            end
            if n == Ncond %set all condition figures to be on the same scale
                ofi = gcf;
                for condi = 1: Ncond
                    figure(ofi - condi + 1)
                    axis([t(1)/1000 t(end)/1000  ylimits(1)  ylimits(2) ]);
                    set(gcf,'Color', BACKCOLOR);
                    axcopy;
                end
            end
        end % finished one condition
    end % finished all requested clusters 
end % Finished 'comps' mode plot option
       
% Plot clusters mean spec/erp
if strcmpi(mode, 'centroid') 
    len = length(cls);
    rowcols(2) = ceil(sqrt(len)); rowcols(1) = ceil((len)/rowcols(2));
    if figureon
        try 
            % optional 'CreateCancelBtn', 'delete(gcbf); error(''USER ABORT'');', 
            h_wait = waitbar(0,['Computing ERP ...'], 'Color', BACKEEGLABCOLOR,'position', [300, 200, 300, 48]);
        catch % for Matlab 5.3
            h_wait = waitbar(0,['Computing ERP ...'],'position', [300, 200, 300, 48]);
        end
        figure
    end
    color_codes = {'b', 'r', 'g', 'c', 'm', 'y', 'k','b--', 'r--', 'g--', 'c--', 'm--', 'y--', 'k--','b-.', 'r-.', 'g-.', 'c-.', 'm-.', 'y-.', 'k-.'};
    orient tall
    for k = 1:len % Go through the clusters
        if ~isfield(STUDY.cluster(cls(k)).centroid, 'erp')
            STUDY = cls_centroid(STUDY,ALLEEG, cls(k) , 'erp');
        end
        if  (k == 1) 
            erp_min = min(STUDY.cluster(cls(k)).centroid.erp{1});
            erp_max = max(STUDY.cluster(cls(k)).centroid.erp{1});
        end
        if len ~= 1
            sbplot(rowcols(1),rowcols(2),k) ; 
        end
        hold on;
        for n = 1:Ncond
            if k == 1
                leg_color{n} = [STUDY.condition{n}];
            end
            % Compute ERP limits accross conditions and
            % across clusters (all on same scale)  
            erp_min = min(erp_min, min(STUDY.cluster(cls(k)).centroid.erp{n}));
            erp_max = max(erp_max, max(STUDY.cluster(cls(k)).centroid.erp{n}));
            ave_erp(:,n) = STUDY.cluster(cls(k)).centroid.erp{n};
            if n == Ncond
                [ave_erp pol] = comppol(ave_erp);
                t = STUDY.cluster(cls(k)).centroid.erp_t;
                a = [ STUDY.cluster(cls(k)).name ', ' num2str(length(unique(STUDY.cluster(cls(k)).sets(1,:)))) 'Ss'];
                for condi = 1: Ncond
                    plot(t/1000,ave_erp(:,condi),color_codes{condi},'linewidth',2);
                end
            end
            if n == Ncond
                a = [ STUDY.cluster(cls(k)).name ', '  num2str(length(unique(STUDY.cluster(cls(k)).sets(1,:)))) 'Ss' ];
                title(a);
                set(gcf,'Color', BACKCOLOR);
                set(gca,'UserData', leg_color);
                set(gcf,'UserData', leg_color);
                if figureon
                    waitbar(k/len,h_wait);
                end
            end
            if (k == len) & (n == Ncond)
                for clsi = 1:len % plot all on same scale
                    if len ~= 1
                        subplot(rowcols(1),rowcols(2),clsi) ; 
                    end
                    axis([t(1)/1000 t(end)/1000 erp_min erp_max]);
                    axcopy(gcf, 'leg_color = get(gca,''''UserData'''') ; legend(leg_color); xlabel(''''Time [sec]'''');ylabel(''''Activations'''') ;');
                end
                xlabel('Time [sec]');
                ylabel('Activations');
                if len ~= 1
                    maintitle = ['Average ICA ERP for several clusters across all conditions'];
                    a = textsc(maintitle, 'title'); 
                    set(a, 'fontweight', 'bold'); 
                else
                    a = [ STUDY.cluster(cls(k)).name ' ERP, '  num2str(length(unique(STUDY.cluster(cls(k)).sets(1,:)))) 'Ss' ];
                    title(a);
                end
                set(gcf,'Color', BACKCOLOR);
                legend(leg_color);
                if figureon
                    delete(h_wait);
                end
            end
        end % finished the different conditions
    end % finished all clusters 
end % finished 'centroid' plot mode
