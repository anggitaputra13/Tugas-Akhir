clc;
clear;
close all;

%Deklarasi Variabel%
n=100;
xm=100;
ym=100;
sinkx=50;
sinky=200;


%Membentuk Topologi Awal%
for i=1:n
    SN(i).x=rand(1,1)*xm;
    SN(i).y=rand(1,1)*ym;
    x(i,1)=SN(i).x;
    y(i,1)=SN(i).y;
    hold on;
    figure(1)
    plot(xm,ym,SN(i).x,SN(i).y,'ob',sinkx,sinky,'*r');
    title 'Wireless Sensor Network';
    xlabel '(m)';
    ylabel '(m)';
end

%Proses K-Means%
k=input('Masukkan jumlah klaster : ');

%Penentua C1 Awal dengan mencari jarak terjauh dengan BS
startx=[];
starty=[];
center=[startx starty]; %menyimpan nilai C1
d=[];
for i=1:length(x)
    c=[SN(i).x SN(i).y]; %mengambil data node ke-i
    distance=sqrt((sinkx-c(:,1))^2+(sinky-c(:,2))^2); %mengurangi jarak BS dengan node
    d=[d distance]; % menyimpan index dan nilai jarak masing" node dengan BS
end
[e s]=max(d); %mencari nilai terbesar dari distance yang dipilih sebagai C1
center=[center;[x(s) y(s)]]; %menyimpan koordinat c1 dalam array
x(s)=[]; %mengosongkan kembali nilai x dan y
y(s)=[];

%Proses mencari C selanjutnya
r=1;
while(r~=k)
    for i=1:length(x)
        g=[SN(i).x SN(i).y]; %Mengambil data kordinat node ke i
        ka=dsearchn(center,g); %Mencari node terdekat dengan data pusat klaster
        nearestx=center(ka,1); %Mencari data terdekat pada nilai kordinat x
        nearesty=center(ka,2); %Mencari data terdekat pada nilai kordinat y
        distance=sqrt((nearestx-g(:,1))^2+(nearesty-g(:,2))^2); %Menghitung jarak node dengan cluster head
        d=[d distance]; %Menyimpan nilai jarak dan indeksnya
    end
    [e s]=max(d); %Mencari data jarak dengan nilai max/tertinggi
    center=[center;[x(s) y(s)]]; %Menyimpan data node dengan jarak tertinggi pada aray CH
    x(s)=[]; %mengosongkan kembali nilai x, y dan d
    y(s)=[];
    [r c]=size(center);
    d=[];
end
figure(2) %Menampilkan koordinat titik CH pada WSN
disp(center);
plot(center(:,1),center(:,2),'ko','linewidth',3);
hold on;
grid on;
for i=1:n
   plot(xm,ym,SN(i).x,SN(i).y,'ob',sinkx,sinky,'*r');
   title 'Wireless Sensor Network';
   xlabel '(m)';
   ylabel '(m)'; 
end

%Proses pengelompokan node dengan cluster
cx=center(:,1); %Menyimpan nilai kordinat x CH pada var cx
cy=center(:,2); %Menyimpan nilai kordinat y CH pada var cy
mean_oldx=cx; %menyimpan nilai x pusat klaster lama
mean_newx=cx; %menyimpan nilai x pusat klaster yang diperbaharui
mean_oldy=cy; %menyimpan nilai y pusat klaster lama
mean_newy=cy; %menyimpan nilai y pusat klaster yang diperbaharui
outputx=cell(k,1); %menyimpan data node x sesuai klaster
outputy=cell(k,1); %menyimpan data node y sesuai klaster
temp=0;
iter=1;
while(temp==0) %Melakukan perulangan untuk membentuk klaster hingga nilai CH tidak mengalami perubahan
    mean_oldx=mean_newx; %menyamakan nilai pusat klaster lama dan baru
    mean_oldy=mean_newy;
    for(i=1:length(x)) %perulangan mencari jarak setiap node
        data=[];
        for(j=1:length(cx)) %mencari jarak setiap node dengan setiap cluster head
            data=[data sqrt((SN(i).x-cx(j))^2+(SN(i).y-cy(j))^2)];
        end
        [gc index]=min(data); %Mencari jarak terendah node dengan CH
        outputx{index}=[outputx{index} SN(i).x]; %Mengelompokkan data sesuai CH terdekat
        outputy{index}=[outputy{index} SN(i).y]; %Mengelompokkan data sesuai CH terdekat
    end
    gmckx=[];
    gmcky=[];
    for(i=1:k) %Proses memperbarui nilai pusat CH 
        gmckx=[gmckx mean(outputx{i})]; 
        gmcky=[gmcky mean(outputy{i})];
    end
    cx=gmckx; %Menyimpan nilai terbaru CH
    cy=gmcky;
    mean_newx=cx; %Menyimpan nilai terbaru CH
    mean_newy=cy;
    finalx=0; %variabel keputusan untuk mengetahui nilai kordinat x CH sudah sama setiap iterasi
    finaly=0; %variabel keputusan untuk mengetahui nilai kordinat y CH sudah sama setiap iterasi
    if(mean_newx==mean_oldx) %Mengecek apakah nilai CH kordinat x sama dengan nilai CH pada iterasi sebelumnya
        finalx=1;
    end
    if(mean_newy==mean_oldy) %Mengecek apakah nilai CH kordinat y sama dengan nilai CH pada iterasi sebelumnya
        finaly=1;
    end
    if(finalx==1 && finaly==1) %Jika nilai sama maka akhiri perulangan dengan set temp=1
        temp=1;
    else %Jika tidak sama maka simpan nilai pusat CH baru pada bvariabel outputx dan outputy
            outputx=cell(k,1);
            outputy=cell(k,1);
    end
    iter=iter+1;
end
disp('Jumah iterasi yang dilakukan adalah: '),disp(iter)
celldisp(outputx); %Menampilkan nilai pada kordinat x fix setiap node dan klaster
celldisp(outputy); %Menampilkan nilai pada kordinat y fix setiap node dan klaster
figure;
for i=1:k %Perulangan untuk ploting node sesuai klaster pada WSN
    xf=outputx{i};
    yf=outputy{i};
    if(i==1)
        plot(xf,yf,'ro','linewidth',3);
    elseif(i==2)
        plot(xf,yf,'bo','linewidth',3);
    elseif(i==3)
        plot(xf,yf,'yo','linewidth',3);
    else
        plot(xf,yf,'go','linewidth',3);
    end
    hold on;
    grid on;
end
figure(3)
plot(xm,ym,sinkx,sinky,'*r');
title 'Wireless Sensor Network';
xlabel '(m)';
ylabel '(m)';
hold on;



    