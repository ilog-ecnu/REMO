function [XXs,Ls] = GetRelationPairs(Input,Catalog)
% ����ԭ����������ϵ�����ݲ�ƽ����������


% C1C1,C2C2  : 0
% C1C2       : 1
% C2C1       : -1


    C1_index = Catalog ==1;
    C2_index = Catalog ~=1;
    
    
    C1C1 = combvec(Input(Catalog ==1,:)',Input(Catalog ==1,:)')';
    C1C2 = combvec(Input(Catalog ==1,:)',Input(Catalog ~=1,:)')';
    C2C1 = combvec(Input(Catalog ~=1,:)',Input(Catalog ==1,:)')';
    C2C2 = combvec(Input(Catalog ~=1,:)',Input(Catalog ~=1,:)')';
    
    % ɾ��x1x1������
    t_ind = combvec(1:sum(C1_index),1:sum(C1_index));
    t_equ_ind = t_ind(1,:) == t_ind(2,:);
    C1C1(t_equ_ind,:) = [];
    
    t_ind = combvec(1:sum(C2_index),1:sum(C2_index));
    t_equ_ind = t_ind(1,:) == t_ind(2,:);
    C2C2(t_equ_ind,:) = [];

    % ������������
    t_num = ceil(size(C1C2,1)/2);
    if size(C1C1,1) > t_num && size(C2C2,1) > t_num
        C1C1 = C1C1(randperm(size(C1C1,1),t_num),:);
        C2C2 = C2C2(randperm(size(C2C2,1),t_num),:);
    elseif size(C1C1,1) < t_num
        C2C2 = C2C2(randperm(size(C2C2,1),t_num*2-size(C1C1,1)),:);      % ��C2C2 ����C1C1
    elseif size(C2C2,1) < t_num
        C1C1 = C1C1(randperm(size(C1C1,1),t_num*2-size(C2C2,1)),:);      % ��C1C1 ����C2C2
    end
        
    
    XXs = [C1C1;C2C2;C1C2;C2C1];
    Ls  = [zeros(size(C1C1,1),1);zeros(size(C2C2,1),1);...
        ones(size(C1C2,1),1);-1.*ones(size(C2C1,1),1)];



end

