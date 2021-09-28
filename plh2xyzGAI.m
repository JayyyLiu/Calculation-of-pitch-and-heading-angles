clear;
clc;
%%
%从椭球坐标（经纬度和海拔）转化成以椭球心为原点的笛卡尔（xyz）坐标
%其中笛卡尔坐标是以东经0°所对应的赤道半径作为x轴正方向
%在下面输入两个点的椭球坐标，整个脚本都计算的是以第一个点向第二个点调整的角度
 plh = [30.675869,104.100589,500;
        30.596196,103.912805,500;]; %分别对应两个点的纬度，经度和海拔，是需输入的值
    
 lat = plh(:,1)*pi/180; %纬度（弧度制）
 lon = plh(:,2)*pi/180; %经度（弧度制）
 hgt = plh(:,3); %海拔
   a = 6378137.0; %地球赤道半径 可依情况换成6378245
   b = 6356752.3; %地球极半径   可依情况换成6356863
       
if abs(lat) > pi/2 | abs(lon) > 2*pi %如果经纬度输入超出范围，则打印警告信息
   warning( 'In plh2xyz(), the input latitude and/or longitude may not be in units of radians.' );
end

e2 = (a^2-b^2)/(a^2); %离心率的平方
W  = sqrt(1.0-e2*((sin(lat)).^2)); %一个常用公式，了解即可
N  = a./W; %坐标点所在圆的曲率半径

pos(:,1) = ( N + hgt ) .* cos( lat ) .* cos( lon );   %得到x
pos(:,2) = ( N + hgt ) .* cos( lat ) .* sin( lon );   %得到y
pos(:,3) = ( ( 1.0 - e2 ) .* N + hgt ) .* sin( lat ); %得到z

%%
%求任意一点P0(x0,y0,z0)对于点P1(x1,y1,z1)的仰角w1
%P0对应最开始plh里的第一个点，P1对应里面的第二个点
%过P0点的切平面：x0*x/a^2+y0*y/a^2+z0*z/b^2-1=0
%过P0P1的直线：(x-x0)/(x1-x0)=(y-y0)/(y1-y0)=(z-z0)/(z1-z0)
x0=pos(1,1);y0=pos(1,2);z0=pos(1,3); %为写脚本简洁，34~36均用代数替代pos内元素
x1=pos(2,1);y1=pos(2,2);z1=pos(2,3);
upmn=(x1-x0)*x0/a^2+(y1-y0)*y0/a^2+(z1-z0)*z0/b^2; %仰角cos值的分子
downmn=sqrt(((x1-x0).^2+(y1-y0).^2+(z1-z0).^2)*((x0^2+y0^2)/a^4+z0^2/b^4)); %仰角cos值的分母

if pos(1,3)>=pos(2,3) %分两种情况讨论仰角
    w1=90-acosd(upmn/downmn); %w1即为所求的仰角
else
    w1=acosd(upmn/downmn)-90;
end
w1 %所得到的仰角

%%
%调整方向角度w2
pos1(:,1) = N .* cos( lat ) .* cos( lon );   %pos1为P0和P1所在的零海拔地面的xyz坐标（忽略海拔）
pos1(:,2) = N .* cos( lat ) .* sin( lon );   
pos1(:,3) = ( 1.0 - e2 ) * N .* sin( lat ); 
xx0=pos1(1,1);yy0=pos1(1,2);zz0=pos1(1,3);
xx1=pos1(2,1);yy1=pos1(2,2);zz1=pos1(2,3);

P1OC=acosd(abs(zz1)/sqrt(xx1^2+yy1^2+zz1^2)); %54~56行：为最后的二面角计算辅助角
EOF=plh(2,2)-plh(1,2);
P0OP1=acosd((xx0*xx1+yy0*yy1+zz0*zz1)/sqrt((xx0^2+yy0^2+zz0^2)*(xx1^2+yy1^2+zz1^2)));
C0P0P1=asind(sind(P1OC)*sind(EOF)/sind(P0OP1)); %所求方位角的值，方位角为一个二面角
w2=abs(C0P0P1); %所求方位角大小的绝对值
if plh(2,1)>=plh(1,1) & plh(2,2)>=plh(1,2) %分四种情况讨论方位角
    ww=char('The azimuth is from North to East,degree is', num2str(w2),...
        'and heading angle is',num2str(w2));
elseif plh(2,1)>=plh(1,1) & plh(2,2)<plh(1,2)
    ww=char('The azimuth is from North to West,degree is', num2str(w2),...
        'and heading angle is',num2str(360-w2));
elseif plh(2,1)<plh(1,1) & plh(2,2)<plh(1,2)
    ww=char('The azimuth is from South to West,degree is', num2str(w2),...
        'and heading angle is',num2str(w2+180));
else
    ww=char('The azimuth is from South to East,degree is', num2str(w2),...
        'and heading angle is',num2str(180-w2));
end
    w2 %所得到的方位角
    ww %打印：从南（北）向东（西）转向 以及航向角度数
