%Attempts to divide a graph?s vertices into clusters by using the dominant
%eigenvectors of the graph?s nonbacktracking walk matrix.
%G is a matrix listing all edges in the graph.
%More precisely, G has 2 columns and a row for each edge listing the vertices it is incident to.
%e is the number of edges in the graph.
%n is the number of vertices in the graph.
%k is the number of clusters to divide the graph into.
%This function outputs a list of length n that lists a number from 0 to k
%for each vertex. 1 to k are the communities, while vertices that are
%outside the main component get an entry of 0 in the output.
function C=graphCluster_olin(G,e,n,k)
%Computes the graph?s nonbacktracking walk matrix.
I1=spalloc(2*e,n,2*e);
I2=spalloc(2*e,n,2*e);

for i=1:e
I1(2*i-1,G(i,1))=1;
I1(2*i,G(i,2))=1;
I2(2*i-1,G(i,2))=1;
I2(2*i,G(i,1))=1;
end
B=I2*I1';
for i=1:e
B(2*i-1,2*i)=0;
B(2*i,2*i-1)=0;
end
%Finds the top k eigenvectors of the graph, or as many as it can if that is
%less than k.
flag=1;
maxV=k+1;
while flag>0
maxV=maxV-1;
[V,D,flag]=eigs(B,maxV);
end
%Convert the eigenvectors from vectors over the edges to vectors over the
%vertices, and deletes the entries corresponding to vertices outside the
%main community.
d=max(max(D));
V2=I1'*V;
indices=zeros(n,1);
count=n;
V2copy=V2;
for i=0:(n-1)
if V2(n-i,1)==0
V2=[V2(1:n-i-1,:);V2(n-i+1:count,:)];
indices=[indices(1:n-i-1,1);indices(n-i+1:count,1)];
count=count-1;
end
end

%Recalibrates the magnitudes of the vectors in an effort to make their
%magnitudes correspond to the usefulness of the information they provide.
%Also nullifies the first eigenvector (which is irrelevant under standard
%assumptions) and any eigenvector with a significantly complex eigenvalue
%(the useful eigenvectors should have real eigenvalues).
s0=V2'*V2;
s=zeros(maxV,maxV);
for i=1:maxV
l=D(i,i);
x=((d-l)^2+l*l)/(d*(l*l-d));
s(i,i)=sqrt((1+(1/x))/s0(i,i));
if D(i,i)==d
s(i,i)=0;
end
if abs(imag(D(i,i)))>.01
s(i,i)=0;
end
end
V2=V2*s;
%Runs kmeans to assign the vertices in the main component to communities.
[C,C2,dis]=kmeans([real(V2),imag(V2)],k,'replicates',10);
%Adds the vertices outside the main component back into the output as being
%in an unknown community.
for i=1:n
if V2copy(i,1)==0
C=[C(1:i-1);0;C(i:count)];
count=count+1;
end
end
end
