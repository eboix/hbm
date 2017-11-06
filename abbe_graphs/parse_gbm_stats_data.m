function parse_gbm_stats_data(datatable)

import block_model.utility.*;
import export_fig.*;

tempdir = 'tmpfiles';
clear_and_create_tempdir(tempdir);
fignames = {};

numfig = 1;
for c = 10
    
    rowc = [datatable.thresh_c{:}];
    temptablec = datatable(rowc == c,:);
    if(height(temptablec) == 0), continue; end;
    for d = 1:1:3
        
        
        rowd = [temptablec.center_dist{:}];
        temptable = temptablec(rowd == d,:);
        if(height(temptable) == 0), continue; end;
        
        classifiers = ...
            {{@sdp_classifier, 'sdp'}, ...
            {@adj_classifier, 'adj'}, ...
            {@lap_classifier, 'lap'}, ...
            {@sym_norm_lap_classifier, 'normlap'}, ...
            {@nb_classifier, 'nb'}, ...
            {@pow_adj_classifier, 'graphpow (adj)'}, ...
            {@optimal_gbm_classifier, 'best possible'}};
        
        fh = figure;
        hold on
        for class_num = 1:length(classifiers)
            class_name = classifiers{class_num};
            class_name = class_name{2};
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
            h = plot(log10(x_vals),y_vals,'DisplayName',class_name);
            h.LineWidth = 2;
            
        end
        
        % Make it look like a Miro painting.
        hXLabel = xlabel('$\log_{10}$(Number of Vertices)','interpreter','latex','FontName','Times');
        hYLabel = ylabel('Agreement on Giant','interpreter','latex','FontName','Times');
        ylim([0.5 1]);
        hTitle  = title (sprintf('\\parbox{4in}{\\centering \\textbf{Classifier Performance on GBM} \\\\ edge threshold $= \\frac{%d}{\\sqrt{n}}$, center distance $= %.3f$}', c, d),'interpreter','latex','FontName','Times');
        
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
end
append_pdfs('parse_gbm_stats_plots.pdf', fignames{:});
end