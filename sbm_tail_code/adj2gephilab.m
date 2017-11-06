function adj2gephilab(filename,adj,varargin)
% Export graph and optional attributes to spreadsheets for Gephi to use.
% in Gephi via Data Laboratory.
% INPUTS:
%           filename: string for the prefix name of the two files .csv
%           adj: the adjacency matrix
%           Optional: Any number of
%                     (attribute name, length-n attribute vector) pairs.
% OUTPUTS:
%            Two spreadsheets: filename_node.xlsx, filename_edge.xlsx
%            that can be imported into Gephi.
% Based on code by Fabio Vanni: https://www.mathworks.com/matlabcentral/fileexchange/51146-adj2gephilab

nodecsv=[filename,'_node.xlsx'];
edgecsv=[filename,'_edge.xlsx'];
n=size(adj,1);

tic
% Node spreadsheet.
num_params = length(varargin);
assert(mod(num_params,2) == 0);

param_vals = cellfun(@(x) reshape(x,[n,1]), varargin(2:2:end),'UniformOutput',false);
param_vals = [param_vals{1:end}];

node_header = [{'Id'} varargin(1:2:end)];
node_body = num2cell([(1:n)' param_vals]);

[status, msg] = xlswrite(nodecsv,[node_header; node_body]);
if (~status)
    error(['Writing node file was unsuccessful. ' msg.message]);
end
toc

tic
% Edge spreadsheet.
edge_header = {'Source','Target'};
edge_list=num2cell(adj_matrix_to_list(adj));

if (~xlswrite(edgecsv, [edge_header; edge_list]))
    error('Writing edge file was unsuccessful.');
end
toc
end

% Helper function.
function edge_list = adj_matrix_to_list(temp_adj)
assert(issymmetric(temp_adj)); % Undirected graph.
temp_adj = triu(temp_adj);
assert(all(nonzeros(temp_adj) == 1)); % Unweighted graph.

temp_n=size(temp_adj,1); % number of nodes
edges=find(temp_adj>0); % indices of all edges
[i,j]=ind2sub([temp_n,temp_n],edges); % node indices of edge e
edge_list = [i j];
end