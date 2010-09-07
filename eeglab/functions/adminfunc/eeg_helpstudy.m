% eeg_helpstudy() - Help file for EEGLAB

function noname();

command = { ...
'pophelp(''compute_ersp_times.m'');' ...
'pophelp(''neural_net.m'');' ...
'pophelp(''pop_chanplot.m'');' ...
'pophelp(''pop_clust.m'');' ...
'pophelp(''pop_clustedit.m'');' ...
'pophelp(''pop_erpparams.m'');' ...
'pophelp(''pop_erspparams.m'');' ...
'pophelp(''pop_loadstudy.m'');' ...
'pophelp(''pop_preclust.m'');' ...
'pophelp(''pop_precomp.m'');' ...
'pophelp(''pop_savestudy.m'');' ...
'pophelp(''pop_specparams.m'');' ...
'pophelp(''pop_study.m'');' ...
'pophelp(''robust_kmeans.m'');' ...
'pophelp(''ss_std_envtopo.m'');' ...
'pophelp(''std_centroid.m'');' ...
'pophelp(''std_changroup.m'');' ...
'pophelp(''std_chaninds.m'');' ...
'pophelp(''std_chantopo.m'');' ...
'pophelp(''std_checkset.m'');' ...
'pophelp(''std_clustread.m'');' ...
'pophelp(''std_comppol.m'');' ...
'pophelp(''std_createclust.m'');' ...
'pophelp(''std_dipplot.m'');' ...
'pophelp(''std_editset.m'');' ...
'pophelp(''std_envtopo.m'');' ...
'pophelp(''std_erp.m'');' ...
'pophelp(''std_erpplot.m'');' ...
'pophelp(''std_ersp.m'');' ...
'pophelp(''std_erspplot.m'');' ...
'pophelp(''std_filecheck.m'');' ...
'pophelp(''std_findoutlierclust.m'');' ...
'pophelp(''std_interp.m'');' ...
'pophelp(''std_itcplot.m'');' ...
'pophelp(''std_loadalleeg.m'');' ...
'pophelp(''std_mergeclust.m'');' ...
'pophelp(''std_movecomp.m'');' ...
'pophelp(''std_moveoutlier.m'');' ...
'pophelp(''std_plot.m'');' ...
'pophelp(''std_plotcurve.m'');' ...
'pophelp(''std_plottf.m'');' ...
'pophelp(''std_preclust.m'');' ...
'pophelp(''std_precomp.m'');' ...
'pophelp(''std_propplot.m'');' ...
'pophelp(''std_readdata.m'');' ...
'pophelp(''std_readerp.m'');' ...
'pophelp(''std_readersp.m'');' ...
'pophelp(''std_readitc.m'');' ...
'pophelp(''std_readspec.m'');' ...
'pophelp(''std_readtopo.m'');' ...
'pophelp(''std_readtopoclust.m'');' ...
'pophelp(''std_rejectoutliers.m'');' ...
'pophelp(''std_renameclust.m'');' ...
'pophelp(''std_savedat.m'');' ...
'pophelp(''std_selcomp.m'');' ...
'pophelp(''std_selsubject.m'');' ...
'pophelp(''std_spec.m'');' ...
'pophelp(''std_specplot.m'');' ...
'pophelp(''std_stat.m'');' ...
'pophelp(''std_topo.m'');' ...
'pophelp(''std_topoplot.m'');' ...
'pophelp(''toporeplot.m'');' ...
};
vartext = { ...
'compute_ersp_times.m' ...
'neural_net.m' ...
'pop_chanplot.m' ...
'pop_clust.m' ...
'pop_clustedit.m' ...
'pop_erpparams.m' ...
'pop_erspparams.m' ...
'pop_loadstudy.m' ...
'pop_preclust.m' ...
'pop_precomp.m' ...
'pop_savestudy.m' ...
'pop_specparams.m' ...
'pop_study.m' ...
'robust_kmeans.m' ...
'ss_std_envtopo.m' ...
'std_centroid.m' ...
'std_changroup.m' ...
'std_chaninds.m' ...
'std_chantopo.m' ...
'std_checkset.m' ...
'std_clustread.m' ...
'std_comppol.m' ...
'std_createclust.m' ...
'std_dipplot.m' ...
'std_editset.m' ...
'std_envtopo.m' ...
'std_erp.m' ...
'std_erpplot.m' ...
'std_ersp.m' ...
'std_erspplot.m' ...
'std_filecheck.m' ...
'std_findoutlierclust.m' ...
'std_interp.m' ...
'std_itcplot.m' ...
'std_loadalleeg.m' ...
'std_mergeclust.m' ...
'std_movecomp.m' ...
'std_moveoutlier.m' ...
'std_plot.m' ...
'std_plotcurve.m' ...
'std_plottf.m' ...
'std_preclust.m' ...
'std_precomp.m' ...
'std_propplot.m' ...
'std_readdata.m' ...
'std_readerp.m' ...
'std_readersp.m' ...
'std_readitc.m' ...
'std_readspec.m' ...
'std_readtopo.m' ...
'std_readtopoclust.m' ...
'std_rejectoutliers.m' ...
'std_renameclust.m' ...
'std_savedat.m' ...
'std_selcomp.m' ...
'std_selsubject.m' ...
'std_spec.m' ...
'std_specplot.m' ...
'std_stat.m' ...
'std_topo.m' ...
'std_topoplot.m' ...
'toporeplot.m' ...
};
textgui( vartext, command,'fontsize', 15, 'fontname', 'times', 'linesperpage', 18, 'title',strvcat( 'Study processing functions', '(Click on blue text for help)'));
icadefs; set(gcf, 'COLOR', BACKCOLOR);h = findobj('parent', gcf, 'style', 'slider');set(h, 'backgroundcolor', GUIBACKCOLOR);return;
