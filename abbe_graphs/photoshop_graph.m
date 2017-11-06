import block_model.hybrid_block_model;

classifiers = ...
    { ...
    {@adj_classifier, 'adj'}, ...
%     {@lap_classifier, 'lap'}, ...
%     {@sym_norm_lap_classifier, 'normlap'} ...
    };
   

for class_num = 1:length(classifiers)
    
a = 2.2;
b = -sqrt(4*a + 1) + a + 1;
a = a - 0.01; % Go slightly below KS threshold, so recovery is possible at large n.
    
        class_pair = classifiers{class_num};
        class_func = class_pair{1};
        class_name = class_pair{2};
        class_fail_pic(class_func,class_name,200000,a,b);
end