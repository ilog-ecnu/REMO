function Next = RSurrogateAssistedSelection(Ref,Input,wmax,Smodel)
%参数说明

%-------------
% net
% TrainIn_struct
% Ref
% Input : 当前种群 的 x 值
% gmax
% p_err


    Next  = GA([Input;Ref.decs],{1,15,1,5});
    i     = 0;
    while i < wmax
        [soerted_index,~]= model_select2(Smodel,Next);
        Input = Next(soerted_index(1:length(Ref)),:);
        Next      = GA([Input;Ref.decs],{1,15,1,5});
        
        i = i+size(Next,1);
    
    end
    [~,scores] = model_select2(Smodel,Next);
 %   [~,scores] = model_select(Smodel,Next);
    if sum(scores>3.9)<4
        [~,ind] = sort(scores,'descend');
        Next = Next(ind(1:4),:); 
    else
        Next = Next(scores>3.9,:);
    end
end


%% model selection


function [ind,scores] = model_select(Smodel,Next)
    model_x = Smodel.X;    
    C1_data = model_x(Smodel.Y ==1,:);
    C2_data = model_x(Smodel.Y ~=1,:);
    
    scores = zeros(1,size(Next,1));
    
    for i = 1:size(Next,1)
        C_SCORE = zeros(1,2);
        % 针对每一个数组
        Xi = repmat(Next(i,:),size(C1_data,1),1);
        C1_Xi = [C1_data,Xi];
        Xi_C1 = [Xi,C1_data];
        
        Xi = repmat(Next(i,:),size(C2_data,1),1);
        C2_Xi = [C2_data,Xi];
        Xi_C2 = [Xi,C2_data];
        
        TestIn_nor = mapminmax('apply',[C1_Xi;Xi_C1;C2_Xi;Xi_C2]',Smodel.mp_struct)';
        pre_out = Smodel.net(TestIn_nor')';
        
        
        
        pre_C1Xi = sum(pre_out(1:size(C1_Xi,1),:),1)./size(C1_Xi,1);
        C_SCORE(1) = C_SCORE(1) + pre_C1Xi(2)+pre_C1Xi(3);   % I类觉得和x 是同一类 + I类都觉得不如x   ---> 是 I
        C_SCORE(2) = C_SCORE(2) + pre_C1Xi(1);                % I类觉得比x 好   ---> 是II 类
        
        pre_XiC1 = sum(pre_out(size(C1_Xi,1)+1:size(C1_Xi,1)+size(Xi_C1,1),:),1)./size(Xi_C1,1);
        C_SCORE(1) = C_SCORE(1) + pre_XiC1(2) + pre_XiC1(1);   % x 觉得和I 是通一类 + x 觉得比I 类好   ---> 是  I
        C_SCORE(2) = C_SCORE(2) + pre_XiC1(3);                 % x 觉得不如  I 类       ----> 是 II 类
        
        pre_C2Xi = sum(pre_out(size(C1_Xi,1)+size(Xi_C1,1)+1:size(C1_Xi,1)+size(Xi_C1,1)+size(C2_Xi,1),:),1)./size(C2_Xi,1);
        C_SCORE(1) = C_SCORE(1) + pre_C2Xi(3);
        C_SCORE(2) = C_SCORE(2) + pre_C2Xi(2) + pre_C2Xi(1);
        
        pre_XiC2 = sum(pre_out(size(C1_Xi,1)+size(Xi_C1,1)+size(C2_Xi,1)+1:size(C1_Xi,1)+size(Xi_C1,1)+size(C2_Xi,1)+size(Xi_C2,1),:),1)./size(Xi_C2,1);
        C_SCORE(1) = C_SCORE(1) + pre_XiC2(1);
        C_SCORE(2) = C_SCORE(2) + pre_XiC2(2) + pre_XiC2(3);
        
        
        
        scores(i) = C_SCORE(1)-C_SCORE(2);
        
         
        
    end
    [~,ind] = sort(scores,'descend');

end



%% 
function [ind,scores] = model_select2(Smodel,Next)
    model_x = Smodel.X;    
    C1_data = model_x(Smodel.Y ==1,:);
    C2_data = model_x(Smodel.Y ~=1,:);
    
    C1_num = size(C1_data,1);
    C2_num = size(C2_data,1);
    Next_num = size(Next,1);
    
    
    scores = zeros(Next_num,2);
    
    all_testdata = zeros(2*(C1_num+C2_num)*Next_num,2*size(C1_data,2));
    for i = 1:size(Next,1)
        original = (i-1)*2*(C1_num+C2_num);
        Xi = repmat(Next(i,:),size(C1_data,1),1);
        all_testdata(original+1:original+C1_num,:) = [C1_data,Xi];  %C1_Xi
        all_testdata(original+1+C1_num:original+C1_num*2,:) = [Xi,C1_data]; %Xi_C1
        
        Xi = repmat(Next(i,:),size(C2_data,1),1);
        all_testdata(original+1+C1_num*2:original+C1_num*2+C2_num,:) = [C2_data,Xi]; %C2_Xi
        all_testdata(original+1+C2_num+C1_num*2:original+C2_num*2+C1_num*2,:)= [Xi,C2_data];%Xi_C2
        
    end
    
    TestIn_nor = mapminmax('apply',all_testdata',Smodel.mp_struct)';
    pre_out = Smodel.net(TestIn_nor')';  
    
    for i = 1:size(Next,1)
        C_SCORE = zeros(1,2);
        original = (i-1)*2*(C1_num+C2_num);
        pre_C1Xi = sum(pre_out(original+1:original+C1_num,:),1)./C1_num;
        C_SCORE(1) = C_SCORE(1) + pre_C1Xi(2)+pre_C1Xi(3);   % I类觉得和x 是同一类 + I类都觉得不如x   ---> 是 I
        C_SCORE(2) = C_SCORE(2) + pre_C1Xi(1);                % I类觉得比x 好   ---> 是II 类
        
        pre_XiC1 = sum(pre_out(original+1+C1_num:original+C1_num*2,:),1)./C1_num;
        C_SCORE(1) = C_SCORE(1) + pre_XiC1(2) + pre_XiC1(1);   % x 觉得和I 是通一类 + x 觉得比I 类好   ---> 是  I
        C_SCORE(2) = C_SCORE(2) + pre_XiC1(3);                 % x 觉得不如  I 类       ----> 是 II 类
        
        pre_C2Xi = sum(pre_out(original+1+C1_num*2:original+C1_num*2+C2_num,:),1)./C2_num;
        C_SCORE(1) = C_SCORE(1) + pre_C2Xi(3);
        C_SCORE(2) = C_SCORE(2) + pre_C2Xi(2) + pre_C2Xi(1);
        
        pre_XiC2 = sum(pre_out(original+1+C2_num+C1_num*2:original+C2_num*2+C1_num*2,:),1)./C2_num;
        C_SCORE(1) = C_SCORE(1) + pre_XiC2(1);
        C_SCORE(2) = C_SCORE(2) + pre_XiC2(2) + pre_XiC2(3);
        
        scores(i) = C_SCORE(1)-C_SCORE(2);
   
    end      
    [~,ind] = sort(scores,'descend');  
end

