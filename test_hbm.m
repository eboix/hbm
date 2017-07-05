plotting = true; % OPTIONALLY plot the results of each trial.
saving = true; % OPTIONALLY save the results of each trial. Need to have a fig directory.

n = 200;
a = 3;
b = 1;
dvals = 0:0.1:2.5;
cvals = 15;
trials = 1;

res = zeros(length(dvals), length(cvals), trials);
pdfnames = {};
for di = 1:length(dvals)
    d = dvals(di);
    for ci = 1:length(cvals)
        c = cvals(ci);
        thresh = c/sqrt(n);
        for trialnum = 1:trials
            % n, prob_dist, t, centers, threshold, Q
            obj = hybrid_block_model(n, [1 1], 1, [-d 0; d 0], thresh, [a b; b a]./n);
            [giant_A,giant_mask,giant_rev,A,sparseg] = obj.get_giant_adj_matrix();
            giant_n = length(giant_A);
            
            %%%%%%%%%%%% NBWALKS CODE BEGINS %%%%%%%%%%%%%%%%%%
%             methodname = 'NB Walk';
%             fileprefix = 'nbwalk';
%             class = nb_classifier(obj);
            %%%%%%%%%%%% NBWALKS CODE ENDS %%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%%% SYM NORM ADJ CODE BEGINS %%%%%%%%%%%%%
%             methodname = 'Sym Norm Adj';
%             fileprefix = 'sym_norm_adj';
%             class = sym_norm_adj_classifier(obj,giant_A,giant_rev);
            %%%%%%%%%%% SYM NORM ADJ CODE ENDS %%%%%%%%%%%%%%%%
            
            %%%%%%%%%%% ADJ CODE BEGINS %%%%%%%%%%%%%%%%%%%%%%%
%             methodname = 'Adj';
%             fileprefix = 'adj';
%             class = adj_classifier(obj,giant_A,giant_rev);
            %%%%%%%%%%% ADJ CODE ENDS %%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%% LAP CODE BEGINS %%%%%%%%%%%%%%%%%%%%%%%
%             methodname = 'Lap';
%             fileprefix = 'lap';
%             class = lap_classifier(obj,giant_A,giant_rev);
            %%%%%%%%%%% LAP CODE ENDS %%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%% RAND WALK CODE BEGINS %%%%%%%%%%%%%%%%%
%             methodname = 'Rand Walk';
%             fileprefix = 'randwalk';
%             class = randwalk_classifier(obj,giant_A,giant_rev);
            %%%%%%%%%%% RAND WALK CODE ENDS %%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%% SDP CODE BEGINS %%%%%%%%%%%%%%%%%%%%%%%
            methodname = 'SDP';
            fileprefix = 'sdp';
            class = sdp_classifier(obj,giant_A,giant_mask);
            %%%%%%%%%%% SDP CODE ENDS %%%%%%%%%%%%%%%%%%%%%%%%%
            
            %%%%%%%%%%% HIGH DEG CODE BEGINS %%%%%%%%%%%%%%%%%%
%             methodname = 'High Deg';
%             fileprefix = 'high_deg';
%             class = high_deg_classifier(obj,giant_A,giant_mask);
            %%%%%%%%%%% HIGH DEG CODE ENDS %%%%%%%%%%%%%%%%%%%%
            

            [agreement, perm] = obj.classification_agreement(class);
            agreement = agreement*n/giant_n;
            if obj.t ~= 0
                [geo_map_agreement, ~] = obj.classification_agreement_geo_predictor(class);
                geo_map_agreement = geo_map_agreement*n/giant_n;
            end
            res(di,ci,trialnum) = agreement;
            if (plotting || saving) && obj.t ~= 0
                close all
                if plotting
                    figure
                else
                    figure('visible','off');
                end
                
                perm = [0; perm];
                obj.plot_classifications(perm(class(:)+1));            
                p=mtit(sprintf('%s: d=%0.2f, c=%0.2f, n=%d, t=%0.2f, a=%0.2f, b = %0.2f',methodname,d,c,n,obj.t,a,b),'xoff',0,'yoff',0.02,'fontsize',12);
                p2 = mtit(sprintf('Giant Agreement=%0.4f', agreement),'xoff',0,'yoff',-1.07);
                p3 = mtit(sprintf('Geoblock MAP Agreement=%0.4f', geo_map_agreement),'xoff',0,'yoff',-1.12);
                if saving
                    h = gcf;
                    set(h,'PaperOrientation','landscape');
                    pdfname = sprintf('figs\\%s_d%0.2f_c%0.2f_n%d_t%0.2f_a%0.2f_b%0.2f_trial%d.pdf',fileprefix,d,c,n,obj.t,a,b,trialnum);
                    pdfnames{length(pdfnames)+1} = pdfname;
                    % export_fig(pdfname,'-q101')
                    print('-fillpage',pdfname,'-dpdf')
                end
            end
        end

    end
end
if saving
    append_pdfs(sprintf('figs\\%s_n%d.pdf',fileprefix,n),pdfnames{:});
end