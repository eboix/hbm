function parse_sbm_stats_data(datatable)

import block_model.utility.*;
import export_fig.*;

tempdir = 'tmpfiles';
clear_and_create_tempdir(tempdir);
fignames = {};

numfig = 1;
a_vals = 2.01:0.5:4.01;
for ai = 1:length(a_vals)
    a = a_vals(ai);
    b = -sqrt(4*a + 1) + a + 1;
    a = a - 0.01;
    
    rowa = [datatable.a{:}];
    temptable = datatable(rowa == a,:);
    if(height(temptable) == 0), continue; end;
    
    
% pow_adj_sbm.pdf, take a = 3, b \approx 0.399
%     classifiers = ...
%         {{@adj_classifier, 'adj'}, ...
%         {@lap_classifier, 'lap'}, ...
%         {'norm lap','randwalk'}, ...
%         {@nb_classifier, 'nb'}, ...
%         {'pow adj', 'pow (adj) none 0.3','no_clean',true,'pow_c',0.3}};
    
    % {@sym_norm_adj_classifier, 'normadj'}, ...
    %     classifiers = ...
    %         {
    % %         {@sdp_classifier, 'sdp'}, ...
    % %         {@lap_classifier, 'lap'}, ...
    % %         {@sym_norm_lap_classifier, 'normlap'}, ...
    %          {@adj_classifier, 'adj'}, ...
    %          {@nb_classifier, 'nb'}, ...
    %          {@pow_sym_norm_adj_classifier, 'normadj (1 clean, pow 0.15)','clean_c',1,'pow_c',0.15},...
    %          {@pow_sym_norm_lap_classifier, 'normlap (clean 3)','clean_c',3,'pow_c',0},...
    
    %         {@pow_adj_classifier, 'graphpow (adj)'}, ...
    % {@pow_adj_classifier, 'graphpow (adj) 2 0.15', 'clean_c',2,'pow_c',0.15},...
    %      {@pow_adj_classifier, 'graphpow (adj) 2 0.3','clean_c',2,'pow_c',0.3}, ...
    %      {@pow_adj_classifier, 'graphpow (adj) 2 0.5', 'clean_c',2,'pow_c',0.5}, ...
    %      {@pow_adj_classifier, 'graphpow (adj) 2 1','clean_c',2,'pow_c',1}, ...
    %      {@pow_adj_classifier, 'graphpow (adj) 2 2','clean_c',2,'pow_c',2}, ...
    %      ...
    %      {@pow_lap_classifier, 'graphpow (lap) 2 0.15', 'clean_c',2,'pow_c',0.15},...
    %      {@pow_lap_classifier, 'graphpow (lap) 2 0.3','clean_c',2,'pow_c',0.3}, ...
    %      {@pow_lap_classifier, 'graphpow (lap) 2 0.5', 'clean_c',2,'pow_c',0.5}, ...
    %      {@pow_lap_classifier, 'graphpow (lap) 2 1','clean_c',2,'pow_c',1}, ...
    %      {@pow_lap_classifier, 'graphpow (lap) 2 2','clean_c',2,'pow_c',2}, ...
    %      ...
    %      {@pow_sym_norm_lap_classifier, 'graphpow (norm lap) 2 0.15', 'clean_c',2,'pow_c',0.15},...
    %      {@pow_sym_norm_lap_classifier, 'graphpow (norm lap) 2 0.3','clean_c',2,'pow_c',0.3}, ...
    %      {@pow_sym_norm_lap_classifier, 'graphpow (norm lap) 2 0.5', 'clean_c',2,'pow_c',0.5}, ...
    %      {@pow_sym_norm_lap_classifier, 'graphpow (norm lap) 2 1','clean_c',2,'pow_c',1}, ...
    %      {@pow_sym_norm_lap_classifier, 'graphpow (norm lap) 2 2','clean_c',2,'pow_c',2}, ...
    %      ...
    %      {@pow_randwalk_classifier, 'graphpow (randwalk) 2 0.15', 'clean_c',2,'pow_c',0.15},...
    %      {@pow_randwalk_classifier, 'graphpow (randwalk) 2 0.3','clean_c',2,'pow_c',0.3}, ...
    %      {@pow_randwalk_classifier, 'graphpow (randwalk) 2 0.5', 'clean_c',2,'pow_c',0.5}, ...
    %      {@pow_randwalk_classifier, 'graphpow (randwalk) 2 1','clean_c',2,'pow_c',1}, ...
    %      {@pow_randwalk_classifier, 'graphpow (randwalk) 2 2','clean_c',2,'pow_c',2}, ...
    %      ...
    %      {@pow_nb_classifier, 'graphpow (nb) 2 0.15', 'clean_c',2,'pow_c',0.15},...
    %      {@pow_nb_classifier, 'graphpow (nb) 2 0.3','clean_c',2,'pow_c',0.3}, ...
    %      {@pow_nb_classifier, 'graphpow (nb) 2 0.5', 'clean_c',2,'pow_c',0.5}, ...
    %      {@pow_nb_classifier, 'graphpow (nb) 2 1','clean_c',2,'pow_c',1}, ...
    %      {@pow_nb_classifier, 'graphpow (nb) 2 2','clean_c',2,'pow_c',2}, ...
    %      {@pow_adj_classifier, 'pow (adj) none 0','no_clean',true,'pow_c',0},...
    %      {@pow_adj_classifier, 'pow (adj) none 0.15','no_clean',true,'pow_c',0.15},...
    %      {@pow_adj_classifier, 'pow (adj) none 0.3','no_clean',true,'pow_c',0.3}, ...
    %      {@pow_adj_classifier, 'pow (adj) none 0.5','no_clean',true,'pow_c',0.5}, ...
    %      {@pow_adj_classifier, 'pow (adj) none 1','no_clean',true,'pow_c',1}, ...
    %      {@pow_adj_classifier, 'pow (adj) none 2','no_clean',true,'pow_c',2}, ...
    %       ...
    %      {@pow_lap_classifier, 'pow (lap) none 0', 'no_clean',true,'pow_c',0},...
    %      {@pow_lap_classifier, 'pow (lap) none 0.15','no_clean',true,'pow_c',0.15},...
    %      {@pow_lap_classifier, 'pow (lap) none 0.3','no_clean',true,'pow_c',0.3}, ...
    %      {@pow_lap_classifier, 'pow (lap) none 0.5','no_clean',true,'pow_c',0.5}, ...
    %      {@pow_lap_classifier, 'pow (lap) none 1','no_clean',true,'pow_c',1}, ...
    %      {@pow_lap_classifier, 'pow (lap) none 2','no_clean',true,'pow_c',2}, ...
    %      {@pow_lap_classifier, 'lap (no clean)', 'no_clean',true,'pow_c',0},...
    %      {@pow_lap_classifier, 'lap (clean 1)','clean_c',1,'pow_c',0},...
    %      {@pow_lap_classifier, 'lap (clean 2)','clean_c',2,'pow_c',0},...
    %      {@pow_lap_classifier, 'lap (clean 3)','clean_c',3,'pow_c',0},...
    %     {@pow_nb_classifier, 'nb (no clean)', 'no_clean',true,'pow_c',0},...
    %     {@pow_nb_classifier, 'nb (clean 1)','clean_c',1,'pow_c',0},...
    %      {@pow_nb_classifier, 'nb (clean 2)','clean_c',2,'pow_c',0},...
    %      {@pow_nb_classifier, 'nb (clean 3)','clean_c',3,'pow_c',0},...
    %   {@pow_sym_norm_adj_classifier, 'normadj (no clean, pow 0.15)','no_clean','true','pow_c',0.15},...
    
    %   {@pow_sym_norm_adj_classifier, 'normadj (1 clean, no pow)','clean_c',1,'pow_c',0},...
    %      {@pow_sym_norm_lap_classifier, 'normlap (no clean)', 'no_clean',true,'pow_c',0},...
    %      {@pow_sym_norm_lap_classifier, 'normlap (clean 1)','clean_c',1,'pow_c',0},...
    %      {@pow_sym_norm_lap_classifier, 'normlap (clean 2)','clean_c',2,'pow_c',0},...
    
    fh = figure;
    hold on
    for class_num = 1:length(classifiers)
        class_cell = classifiers{class_num};
        class_func = class_cell{1};
        class_name = class_cell{2};
        lgd_name = class_name;
        if ischar(class_func) % Optional nickname for method.
            lgd_name = class_func;
        end
        temptable2 = temptable(strcmp(temptable.class_name,class_name),:);
        if(height(temptable2) == 0), continue; end;
        
        n_vals = [100:100:1000 2000:1000:10000 20000:10000:100000 200000];
        x_vals = [];
        y_vals = [];
        
        for ni = 1:length(n_vals)
            n = n_vals(ni);
            rown = [temptable2.n{:}];
            temptable3 = temptable2(rown == n,:);
            if height(temptable3) == 0
                continue
            else
                assert(height(temptable3) == 1);
                x_vals = [x_vals; n]; %#ok<AGROW>
                aggs = temptable3.giant_agreement(1);
                aggs = [aggs{:}];
                y_vals = [y_vals; mean(aggs)]; %#ok<AGROW>
            end
        end
        h = plot(log10(x_vals),y_vals,'DisplayName',lgd_name);
        h.LineWidth = 2;
        
    end
    
    % Make it look like a Miro painting.
    hXLabel = xlabel('$\log_{10}$(Number of Vertices)','interpreter','latex','FontName','Times');
    hYLabel = ylabel('Agreement on Giant','interpreter','latex','FontName','Times');
    ylim([0.5 1]);
    hTitle  = title ({'\textbf{Classifier Performance on SBM}',sprintf('\\hspace{3.2em} {$a = %.3f, b = %.3f$}', a, b),''},'interpreter','latex','FontName','Times');
    
    lgd = legend('show');
    lgd.Location = 'southwest';
    lgd.Interpreter = 'latex';
    
    set( gca                       , ...
        'FontName'   , 'Times' );
    set(gca,'TickLabelInterpreter','latex');
    
    set([lgd, gca]             , ...
        'FontSize'   , 10           );
    
    set( hTitle                    , ...
        'FontSize'   , 12          , ...
        'FontWeight' , 'bold'      );
    
    set(gca, ...
        'Box'         , 'off'     , ...
        'XMinorTick'  , 'off'      , ...
        'YMinorTick'  , 'off'      , ...
        'YGrid'       , 'on'      , ...
        'XColor'      , [.3 .3 .3], ...
        'YColor'      , [.3 .3 .3], ...
        'LineWidth'   , 1         );
    
    
    ylim([0 1]);
    figfilename = fullfile(tempdir, sprintf('f%d.pdf',numfig));
    set(fh, 'PaperPositionMode', 'auto');
    set(fh, 'PaperOrientation', 'landscape');
    print(fh,'-dpdf',figfilename);
    % export_fig(figfilename);
    close all
    fignames = [fignames {figfilename}]; %#ok<AGROW>
    numfig = numfig + 1;
end
append_pdfs('parse_sbm_stats_plots.pdf', fignames{:});
end