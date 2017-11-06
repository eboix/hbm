function class = sdp_classifier(obj)
    % obj is a hybrid_block_model object.
    % Use SDP to approximate min-bisection on giant.
    % TODO DOES NOT DEPEND ON obj.k.
    
  %  disp('Running sdp_classifier');
    
    class = base_giant_classifier(@block_model.classifiers.sdp_classifier_helper, obj, 'use_kmeans', 1);
        
end
