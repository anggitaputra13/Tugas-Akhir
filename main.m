clc;
clear;
close all;

n=100;
xm=100;
ym=100;
sinkx=50;
sinky=50;
x=xlsread('node','A1:A100');
y=xlsread('node','B1:B100');

%Membentuk Topologi Awal%
for i=1:n
    figure(1)
    plot(xm,ym,x,y,'ob',sinkx,sinky,'*r');
    title 'Wireless Sensor Network';
    xlabel '(m)';
    ylabel '(m)';
    hold on;
    grid on;
end

%kmeans; %Memanggil function kmeans

%kmeanplus; %Memanggil function kmeanplus

%Ploting jumlah dead nodes
deadn1=load("TDN-kmeans.txt");
deadn2=load("TDN-kmeansplus.txt");
round=400;
figure(4)
plot(round,n,1:round,deadn1(1:round),'r',1:round,deadn2(1:round),'b');
title 'Jumlah Dead Node Selama Iterasi';
xlabel 'Round';
ylabel 'Dead Node';
hold on;
legend('kmeans++','kmeans');

%Ploting jumlah node hidup
na1=load("TNA-kmeans.txt");
na2=load("TNA-kmeansplus.txt");
round=400;
figure(5)
plot(round,n,1:round,na1(1:round),'r',1:round,na2(1:round),'b');
title 'Jumlah Node Hidup Selama Iterasi';
xlabel 'Round';
ylabel 'Node Hidup';
hold on;
legend('kmeans++','kmeans',"Location","eastoutside");

%Ploting total konsumsi energi
te1=load("TE-kmeans.txt");
te2=load("TE-kmeansplus.txt");
figure(6)
plot(1:round,te1(1:round),'r',1:round,te2(1:round),'b');
title 'Total Konsumsi Energi Selama Iterasi';
xlabel 'Round';
ylabel 'Joule';
hold on;
legend('kmeans','kmeans++',"Location","eastoutside");


