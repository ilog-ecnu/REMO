function [XXs,YYs] = Delequalsamples(XXs,YYs)
%DELEQUALSAMPLES �˴���ʾ�йش˺�����ժҪ
%   �˴���ʾ��ϸ˵��
    zerosindex = YYs ==0;
    XXs(zerosindex,:) = [];
    YYs(zerosindex) = [];
    
end

