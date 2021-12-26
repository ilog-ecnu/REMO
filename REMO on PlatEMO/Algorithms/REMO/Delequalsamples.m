function [XXs,YYs] = Delequalsamples(XXs,YYs)
%DELEQUALSAMPLES 此处显示有关此函数的摘要
%   此处显示详细说明
    zerosindex = YYs ==0;
    XXs(zerosindex,:) = [];
    YYs(zerosindex) = [];
    
end

