clear;clc;
data = importdata('F:\JX_T_Pre_RH_ST\19612018_TEM.xls');
[r_begin,c_begin] = find(data.data == 19810101);
[r_end,c_end] = find(data.data == 20101231);
tem = [];
tem(:,1) = data.data(r_begin:r_end,1);
tem(:,3:87) = data.data(r_begin:r_end,2:86);
tem(:,33) = []; tem(:,56)=[];

%----------------时间转化----------------
char_date = int2str(tem(:,1));
formatIn = 'yyyymmdd';
tem(:,2) = datenum(char_date,formatIn);

%--------缺测处理-------------
for i = 1:length(tem)
    for j = 3:85
        if tem(i,j) > 100
            tem(i,j) = NaN;
        end
    end
end

%---------------提取月日-----------------
for i = 1 : length(tem) 
    mmdd(i,1) = floor(mod(tem(i,1),10000)/100);
    mmdd(i,2) = mod(tem(i,1),100); 
end

%-------------同月同日气温累加-------------
for sta = 3 : 85 %各站计算
    temp(1:12,1:31) = 0;  n = 0;
    for i = 1 : 12  %各月
        for j = 1 : 31  %各日
            count = 0;
            for m = 1 : length(tem)
                if mmdd(m,1) == i & mmdd(m,2) == j
                    temp(i,j) = tem(m,sta) + temp(i,j);
                    count = count + 1;
                end
            end
        end
    end
    eval(['V',num2str(sta-2),'=','temp','/','count',';']);%常年气温序列
end

%-------------五点滑动平均-------------

for sta = 1 : 83  %整理成一列的数据，便于五点滑动平均计算
    n = 1;
    for i = 1 : 12
        for j = 1 : 31
            if eval(['V',num2str(sta),'(i,j)']) == 0
            else
                eval(['VV',num2str(sta),'(n,1)','=','V',num2str(sta),'(i,j)',';']);
                n = n + 1;
            end
        end
    end
end

for sta = 1 : 83
    for i = 5 : 365
        eval(['ave5tem',num2str(sta),'(i,1)','= mean(VV',num2str(sta),'(i-4:i,1));']);
    end
end


%-------------常年入春时间-------------
for sta = 1 : 83
    for i = 5 : 361
        if eval(['ave5tem',num2str(sta),'(i:i+4,1)']) >= 10
            date(sta,1) = i;
            for j = (i-4) : (i+4)
                if eval(['VV',num2str(sta),'(j,1)']) >= 10
                    date(sta,2) = j;
                    break
                end
            end
            break
        end
    end
end


%-------------常年入夏时间-------------
for sta = 1 : 83
    for i = 5 : 361
        if eval(['ave5tem',num2str(sta),'(i:i+4,1)']) >= 22
            date(sta,3) = i;
            for j = (i-4) : (i+4)
                if eval(['VV',num2str(sta),'(j,1)']) >= 22
                    date(sta,4) = j;
                    break
                end
            end
            break
        end
    end
end

%-------------常年入秋时间-------------
for sta = 1 : 83
    for i = 244 : 361
        if eval(['ave5tem',num2str(sta),'(i:i+4,1)']) < 22
            date(sta,5) = i;
            for j = (i-4) : (i+4)
                if eval(['VV',num2str(sta),'(j,1)']) < 22
                    date(sta,6) = j;
                    break
                end
            end
            break
        end
    end
end

%-------------常年入冬时间-------------
for sta = 1 : 83
    for i = 305 : 361
        if eval(['ave5tem',num2str(sta),'(i:i+4,1)']) < 10
            date(sta,7) = i;
            for j = (i-4) : (i+4)
                if eval(['VV',num2str(sta),'(j,1)']) < 10
                    date(sta,8) = j;
                    break
                end
            end
            break
        end
    end
end

%-------起始日转换成日期--------
for i = 2:2:8
    for j = 1 : 83
    DateNumber = date(j,i) - 1 + tem(1,2);
    formatOut = 'mmdd';
    Datenum(j,i/2) = str2num(datestr(DateNumber,formatOut));
%    datenum(j,i/2)={datestr(DateNumber,formatOut)};
    end
end

%------各季平均日数----------
for i = 1 : 83
    date(i,9) = date(i,4)-date(i,2);
    date(i,10) = date(i,6)-date(i,4);
    date(i,11) = date(i,8)-date(i,6);
    date(i,12) = 365 - sum(date(i,9:11));
end

%------------各站最早入春时间-----------
% 
% tem5 = zeros(10950,85);
% tem5(:,1:2) = tem(:,1:2);
% for i = 5 : length(tem)
%     for j = 3 : 85
%         tem5(i,j) = sum(tem(i-4:i,j))/5;%-------------5点滑动平均----------
%     end
% end
% 
% for j = 3 : 85
%     r = 1;
%     for i = 5 : length(tem) - 4
%         if tem5(i:i+4,j) >= 10 & floor(mod(tem5(i,1),10000)/100) >= 1 & floor(mod(tem5(i,1),10000)/100) <= 3 %各站历年满足入春的条件
%             spring(r,j-2) = tem5(i,1);
%             r = r + 1;
%         end
%     end
% end
% 
% %------二次判断------
% for j = 1 : 83
%     temp1 = spring(1,j);
%     for i = 1 : 1279
%         if spring(i,j) == 0
%             break
%         else
%             chartemp = num2str(spring(i,j));
%             if str2num(chartemp(6:8)) <= temp1
%                 temp1 = str2num(chartemp(6:8));
%             end
%         end
%     end
%     chun(1,j) = temp1;
% end



