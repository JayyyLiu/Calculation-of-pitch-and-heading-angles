clear;
clc;
%%
%���������꣨��γ�Ⱥͺ��Σ�ת������������Ϊԭ��ĵѿ�����xyz������
%���еѿ����������Զ���0������Ӧ�ĳ���뾶��Ϊx��������
%������������������������꣬�����ű�����������Ե�һ������ڶ���������ĽǶ�
 plh = [30.675869,104.100589,500;
        30.596196,103.912805,500;]; %�ֱ��Ӧ�������γ�ȣ����Ⱥͺ��Σ����������ֵ
    
 lat = plh(:,1)*pi/180; %γ�ȣ������ƣ�
 lon = plh(:,2)*pi/180; %���ȣ������ƣ�
 hgt = plh(:,3); %����
   a = 6378137.0; %�������뾶 �����������6378245
   b = 6356752.3; %���򼫰뾶   �����������6356863
       
if abs(lat) > pi/2 | abs(lon) > 2*pi %�����γ�����볬����Χ�����ӡ������Ϣ
   warning( 'In plh2xyz(), the input latitude and/or longitude may not be in units of radians.' );
end

e2 = (a^2-b^2)/(a^2); %�����ʵ�ƽ��
W  = sqrt(1.0-e2*((sin(lat)).^2)); %һ�����ù�ʽ���˽⼴��
N  = a./W; %���������Բ�����ʰ뾶

pos(:,1) = ( N + hgt ) .* cos( lat ) .* cos( lon );   %�õ�x
pos(:,2) = ( N + hgt ) .* cos( lat ) .* sin( lon );   %�õ�y
pos(:,3) = ( ( 1.0 - e2 ) .* N + hgt ) .* sin( lat ); %�õ�z

%%
%������һ��P0(x0,y0,z0)���ڵ�P1(x1,y1,z1)������w1
%P0��Ӧ�ʼplh��ĵ�һ���㣬P1��Ӧ����ĵڶ�����
%��P0�����ƽ�棺x0*x/a^2+y0*y/a^2+z0*z/b^2-1=0
%��P0P1��ֱ�ߣ�(x-x0)/(x1-x0)=(y-y0)/(y1-y0)=(z-z0)/(z1-z0)
x0=pos(1,1);y0=pos(1,2);z0=pos(1,3); %Ϊд�ű���࣬34~36���ô������pos��Ԫ��
x1=pos(2,1);y1=pos(2,2);z1=pos(2,3);
upmn=(x1-x0)*x0/a^2+(y1-y0)*y0/a^2+(z1-z0)*z0/b^2; %����cosֵ�ķ���
downmn=sqrt(((x1-x0).^2+(y1-y0).^2+(z1-z0).^2)*((x0^2+y0^2)/a^4+z0^2/b^4)); %����cosֵ�ķ�ĸ

if pos(1,3)>=pos(2,3) %�����������������
    w1=90-acosd(upmn/downmn); %w1��Ϊ���������
else
    w1=acosd(upmn/downmn)-90;
end
w1 %���õ�������

%%
%��������Ƕ�w2
pos1(:,1) = N .* cos( lat ) .* cos( lon );   %pos1ΪP0��P1���ڵ��㺣�ε����xyz���꣨���Ժ��Σ�
pos1(:,2) = N .* cos( lat ) .* sin( lon );   
pos1(:,3) = ( 1.0 - e2 ) * N .* sin( lat ); 
xx0=pos1(1,1);yy0=pos1(1,2);zz0=pos1(1,3);
xx1=pos1(2,1);yy1=pos1(2,2);zz1=pos1(2,3);

P1OC=acosd(abs(zz1)/sqrt(xx1^2+yy1^2+zz1^2)); %54~56�У�Ϊ���Ķ���Ǽ��㸨����
EOF=plh(2,2)-plh(1,2);
P0OP1=acosd((xx0*xx1+yy0*yy1+zz0*zz1)/sqrt((xx0^2+yy0^2+zz0^2)*(xx1^2+yy1^2+zz1^2)));
C0P0P1=asind(sind(P1OC)*sind(EOF)/sind(P0OP1)); %����λ�ǵ�ֵ����λ��Ϊһ�������
w2=abs(C0P0P1); %����λ�Ǵ�С�ľ���ֵ
if plh(2,1)>=plh(1,1) & plh(2,2)>=plh(1,2) %������������۷�λ��
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
    w2 %���õ��ķ�λ��
    ww %��ӡ�����ϣ������򶫣�����ת�� �Լ�����Ƕ���
