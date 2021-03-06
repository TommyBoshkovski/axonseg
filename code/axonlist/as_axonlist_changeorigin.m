function axonlist=as_axonlist_changeorigin(axonlist,neworigin)
% EXAMPLE : as_axonlist_changeorigin(listcell{1,1}.seg,size(listcell{1,1}.img), [100 100])

if ~isempty(axonlist)
    if ~isempty(axonlist(1).Centroid)
        % change centroids
        centroids=cat(1,axonlist.Centroid);
        centroids(:,1)=centroids(:,1)+neworigin(1);
        centroids(:,2)=centroids(:,2)+neworigin(2);
        centroidscell=mat2cell(centroids,ones(size(centroids,1),1));
        [axonlist.Centroid]=deal(centroidscell{:});
        
        % N pixels
        Npx = zeros(length(axonlist),1);
        for ial=1:length(axonlist)
            Npx(ial) = length(axonlist(ial).data);
        end
        % change data
        if isfield(axonlist,'data')
            data=cat(1,axonlist.data);
            data(:,1)=data(:,1)+neworigin(1); data(:,2)=data(:,2)+neworigin(2);
            datacell=mat2cell(data,Npx);
            [axonlist.data]=deal(datacell{:});
        end
    end
end