load('usps_resampled.mat'); 

%16x16 images, 9298 images total 

%test_labels 10x4649 (1 if number, -1 else)
%test_patterns 256*4649

%train_labels 10x4649 (1 if number, -1 else)
%train_patterns 256*4649

%view an image
% img1vec = train_patterns(:,1)
% img1mat = reshape(img1vec,[16,16])
% imshow(img1mat') %tranpose or image flipped (??? idk why - says so in Saito's lec)


%obtain all testing labels
testingLabels = [];
for i = 1:4649
    val = find(test_labels(:,i)==1);
    testingLabels(end+1) = val-1; %digits 0-9, not 1-10
end

%obtain all training labels
trainingLabels = [];
for i = 1:4649
    val = find(train_labels(:,i)==1);
    trainingLabels(end+1) = val-1;
end

%column indicies for each digit in train_labels

zeros_index = find(trainingLabels == 0);
ones_index = find(trainingLabels == 1);
twos_index = find(trainingLabels == 2);
threes_index = find(trainingLabels == 3);
fours_index = find(trainingLabels == 4);
fives_index = find(trainingLabels == 5);
sixs_index = find(trainingLabels == 6);
sevens_index = find(trainingLabels == 7);
eigths_index = find(trainingLabels == 8);
nines_index = find(trainingLabels == 9);

%columns for each digit
zero = train_patterns(:,zeros_index);
ones = train_patterns(:,ones_index);
twos = train_patterns(:,twos_index);
threes = train_patterns(:,threes_index);
fours = train_patterns(:,fours_index);
fives = train_patterns(:,fives_index);
sixs = train_patterns(:,sixs_index);
sevens = train_patterns(:,sevens_index);
eigths = train_patterns(:,eigths_index);
nines = train_patterns(:,nines_index);

%mean for each digit 
means = zeros(256,10);
means(:,1) = mean(zero,2);
means(:,2) = mean(ones,2);
means(:,3) = mean(twos,2);
means(:,4) = mean(threes,2);
means(:,5) = mean(fours,2);
means(:,6) = mean(fives,2);
means(:,7) = mean(sixs,2);
means(:,8) = mean(sevens,2);
means(:,9) = mean(eigths,2);
means(:,10) = mean(nines,2);

test_class = NaN(1,4649); % store classification should be 1x4649
for i=1:4649
    J = Inf; %initialize large distance between matricies
    label = nan;
    for j=1:10 %for each handwritten digit, find the closest mean
        new_J = norm(test_patterns(:,i) - means(:,j)); 
        if new_J < J
            J = new_J;
            label = j-1;
        end
    end
    %classify handwritten digit
    test_class(i) = label;
end 

%confusion matrix 
confusionMatrix = confusionmat(testingLabels,test_class);
%testingLabels: 1x4649
%test_class: 1x4649

accuracy_percent = (sum(diag(confusionMatrix))/sum(confusionMatrix,"ALL"))*100;
%-----------------------Where K-means begins-----------------------------

%idx = for each data point, the cluster number its in
% class_kmeans(i)  = digit classification for the cluster 

%set seed for initial cluster random locations
s=1;
rng(s);
tic %run time
k = 10;
[idx,C] = kmeans(test_patterns',k); 
% [idx,C] = kmeans(test_patterns',k,'Start','sample'); 

% C final centroid locations 10x256
% idx vector of predicted cluster indices: 4649x1

% Assigning clusters to digit
C_256x10 = C'; %reshape
class_kmeans = NaN(10,1); % store classification should be 10x1
for i=1:10
    J = Inf; % initialize large distance between centroids
    label = nan;
    for j=1:10 % for each cluster-mean, find the closest training mean
        new_J = norm(C_256x10(:,i) - means(:,j));
        if new_J < J
            J = new_J;
            label = j-1;
        end
    end
    class_kmeans(i) = label;
end
toc

%label index cluster for each data point as the corresponding digit 
test_class_kmeans = NaN(1,4649); 
for i=1:4649 
    test_class_kmeans(i) = class_kmeans(idx(i));
end

%confusion matrix 
confusionMatrix_kmeans = confusionmat(testingLabels,test_class_kmeans);
%accuracy: number correctly classified (diagonal) / total
accuracy_percent_kmeans = (sum(diag(confusionMatrix_kmeans))/sum(confusionMatrix_kmeans,"ALL"))*100;


accuracy_percent_kmeans

%% Kevin's code

s=1;
rng(s);

k = 10;
% Cluster indices are returned
[idx_train,C_train] = kmeans(transpose(train_patterns),k); % X: test data, C: final centroid locations
%C % final centroid locations 10x256

%idx  % vector of predicted cluster indices: 4649x1
%train_label_vec % vector of labels for all obs: 4649x1
train_label_vec = trainingLabels';
index_and_label = [idx_train train_label_vec];

labels=NaN(4649,10);
for i=1:4649
    for j=1:10
        if index_and_label(i,1)==j
            labels(i,j)=index_and_label(i,2);
        end
        if index_and_label(i,1)~=j
            labels(i,j)=NaN;
        end
    end
end

%training cluster labels
index_labels = NaN(1,10);
for i=1:10
    index_labels(i) = mode(labels(:,i));
end

%
[idx,C] = kmeans(transpose(test_patterns),k); % X: test data, C: final centroid locations
%C % final centroid locations 10x256
%idx  % vector of predicted cluster indices: 4649x1

% Assigning integer label to clusters 
    % tranpose(C): 256x10 % cluster mean locations
    % means: 256x10 % label mean locations
C_256x10 = C';
C_train_T = C_train';
class_kmeans = NaN(10,1); % store classification should be 10x1
for i=1:10
    J = Inf; % initialize large distance between centroids
    label = nan;
    for j=1:10 % for each cluster-mean, find the closest training mean
        new_J = norm(C_256x10(:,i) - C_train_T(:,j));
        if new_J < J
            J = new_J;
            label = index_labels(j);
        end
    end
    class_kmeans(i) = label;
end
toc

test_class_kmeans = NaN(1,4649); 
for i=1:4649 
    test_class_kmeans(i) = class_kmeans(idx(i));
end

%confusion matrix 
confusionMatrix_kmeans = confusionmat(testingLabels,test_class_kmeans);

%accuracy: number correctly classified (diagonal) / total
accuracy_percent_kmeans = (sum(diag(confusionMatrix_kmeans))/sum(confusionMatrix_kmeans,"ALL"))*100;




%% View means of digits
mean0 = reshape(means(:,1),[16,16]); %good
imshow(mean0');

mean1 = reshape(means(:,2),[16,16]); %good
imshow(mean1');

mean2 = reshape(means(:,3),[16,16]); %really bad
imshow(mean2');

mean3 = reshape(means(:,4),[16,16]); %good
imshow(mean3');

mean4 = reshape(means(:,5),[16,16]); %really bad
imshow(mean4');

mean5 = reshape(means(:,6),[16,16]); %decent
imshow(mean5');

mean6 = reshape(means(:,7),[16,16]); %decent
imshow(mean6');

mean7 = reshape(means(:,8),[16,16]); %good
imshow(mean7');

mean8 = reshape(means(:,9),[16,16]); %decent
imshow(mean8');

mean9 = reshape(means(:,10),[16,16]); %looks like a 7
imshow(mean9');

%% view cluster means 

img1 = reshape(C_256x10(:,1),[16,16]); %9 looks terrible
imshow(img1');

img2 = reshape(C_256x10(:,2),[16,16]); %0 looks good
imshow(img2');

img3 = reshape(C_256x10(:,3),[16,16]); %6 looks eh
imshow(img3');

img4 = reshape(C_256x10(:,4),[16,16]); %3 looks decent
imshow(img4');

img5 = reshape(C_256x10(:,5),[16,16]); %8 looks decent 
imshow(img5');

img6 = reshape(C_256x10(:,6),[16,16]); %0 
imshow(img6');

% imshow(img1mat') %tranpose or image flipped (??? idk why - says so in Saito's lec)


% img1mat = reshape(img1vec,[16,16]);
% imshow(img1mat') %tranpose or image flipped (??? idk why - says so in Saito's lec)


%confusion matrix 
%test_class_kmeans: 1x4649
%trainingLabels: 1x4649

%confusionMatrix_kmeans = confusionmat(trainingLabels,test_class_kmeans);
%accuracy_percent_kmeans = (sum(diag(confusionMatrix_kmeans))/sum(confusionMatrix_kmeans,"ALL"))*100;

% Finding distance from each centroid to point 
    %idx_2 = kmeans(training_patterns,k,'MaxIter',Inf,'Start',C)
    %idx_2

% 'MaxIter': specifying maximum # iterations, '1': number of max iterations
% 'Start' : Centroids from last iteration.


