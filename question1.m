%% Step One: get the first three images from each person (30 total)
images_per_subject = 3;
number_of_subjects = 10;
image_set = {};
listings = dir( fullfile('./','images') );

for i = 1 : images_per_subject
    for j = 1 : number_of_subjects
        if(j<10)
            img_pt1 = horzcat( 'user0',num2str(j),'_' );
        else
            img_pt1 = horzcat( 'user',num2str(j),'_' );
        end
        
        if(i<10)
            img_pt2 = horzcat( '0',num2str(i),'.bmp' );
        else
            img_pt2 = horzcat(num2str(i),'.bmp');
        end
        
        image_location = fullfile( './','images',horzcat(img_pt1,img_pt2) );
        image_set{end+1}=image_location;
        
    end
end

%% Step Two: Read each image

S=[];
figure;

for i = 1 : numel(image_set)
    img = imread(image_set{i});
    subplot(ceil(sqrt(numel(image_set))),ceil(sqrt(numel(image_set))),i);
    imshow(img);
    if i==3
        title('Training set','fontsize',18)
    end
    drawnow;
    [irow, icol]=size(img);    % get the number of rows (N1) and columns (N2)
    temp=reshape(img',irow*icol,1);    % creates a (N1*N2)x1 vector
    S=[S temp];    % S is a N1*N2xM matrix after finishing the sequence
end

% A = [];  
% m = mean(S,2); % The average face
% for i = 1 : size(S,2)
%     temp = double(S(:,i)) - m; % Computing the difference image for each image in the training set Ai = Ti - m
%     A = [A temp]; % Merging all centered images
% end
% 
% L = A'*A; % L is the surrogate of covariance matrix C=A*A'.
% [V D] = eig(L); % Diagonal elements of D are the eigenvalues for both L=A'*A and C=A*A'.
% 
% L_eig_vec = [];
% for i = 1 : size(V,2) 
%     if( D(i,i)>1 )
%         L_eig_vec = [L_eig_vec V(:,i)];
%     end
% end
% 
% Eigenfaces = A * L_eig_vec; % A: centered image vectors
% 
% [ row, col ] = find( D ); % Get eigenvalues
% return;



% 
%% Step Three: Normalize images
um = 100;
ustd = 80;
% Normalize all of the images
for i=1:size(S,2)
    temp=double(S(:,i));
    m=mean(temp);
    st=std(temp);
    S(:,i)=(temp-m)*ustd/st+um;
end

% NOTE: step is just for debugging
figure;
for i = 1 : numel(image_set)
    img=reshape(S(:,i),icol,irow);
    img = img';
    subplot(ceil(sqrt(numel(image_set))),ceil(sqrt(numel(image_set))),i);
    imshow(img);
    drawnow;
    if i==3
        title('Normalized Training Set','fontsize',18)
    end
end

% Change image for manipulation
dbx = []; % A matrix
for i = 1 : numel(image_set)
    temp = double( S(:,i) );
    dbx = [dbx temp];
end

%% Covariance matrix : C = A'A, L = AA'
A=dbx';
L=A*A';
% vv are the eigenvector for L
% dd are the eigenvalue for both L=dbx'*dbx and C=dbx*dbx';
[vv dd]=eig(L);
% Sort and eliminate those whose eigenvalue is zero
v=[];
d=[];
for i=1:size(vv,2)
    if(dd(i,i)>1e-4)
        v=[v vv(:,i)];
        d=[d dd(i,i)];
    end
end

% Do sorting
[B index]=sort(d);
ind=zeros(size(index));
dtemp=zeros(size(index));
vtemp=zeros(size(v));
len=length(index);
for i=1:len
    dtemp(i)=B(len+1-i);
    ind(i)=len+1-index(i);
    vtemp(:,ind(i))=v(:,i);
end
d=dtemp;
v=vtemp;

%% Time to do work on the eigenVectors
%Normalization of eigenvectors
for i=1:size(v,2) %access each column
    kk=v(:,i);
    temp=sqrt(sum(kk.^2));
    v(:,i)=v(:,i)./temp;
end

%Eigenvectors of C matrix
u=[];
for i=1:size(v,2)
    temp=sqrt(d(i));
    u=[u (dbx*v(:,i))./temp];
end

%Normalization of eigenvectors
for i=1:size(u,2)
    kk=u(:,i);
    temp=sqrt(sum(kk.^2));
    u(:,i)=u(:,i)./temp;
end

%% Show the eigenfaces
figure;
for i=1:size(u,2)
    img=reshape(u(:,i),icol,irow);
    img=img';
    img=histeq(img,255);
    subplot(ceil(sqrt(numel(image_set))),ceil(sqrt(numel(image_set))),i)
    imshow(img)
    drawnow;
    
    if i==3
        title('Eigenfaces','fontsize',18)
    end
end

% Get the weight of each face
omega = [];
for h=1:size(dbx,2)
    WW=[]; 
    for i=1:size(u,2)
        t = u(:,i)'; 
        WeightOfImage = dot(t,dbx(:,h)');
        WW = [WW; WeightOfImage];
    end
    omega = [omega WW];
end

return;