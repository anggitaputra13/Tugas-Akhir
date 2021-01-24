clc;
clear;
close all;

%%Deklarasi Variabel%%
%Pemetaan Sensor dalam satuan meter%
n=100;
xm=100;
ym=100;
sinkx=50;
sinky=50;
dead_nodes=0;
%Deklarasi Energi%
%Inisialisasi energi pada setiap node(Joules)% 
Eo=2; %Satuan joules
Eelec=50*10^(-9); %Satuan joules/bit
ETx=50*10^(-9); %Satuan joules/bit
ERx=50*10^(-9); %Satuan joules/bit
Eamp=100*10^(-12); %Satuan joules/bit/m^2 
EDA=5*10^(-9); %Satuan joules/bit
kk=4000; %unit bits
rnd=1;
%Nomer node saat iterasi%
transmissions=0;
temp_val=0;
flag1stdead=0;
x=xlsread('node','A1:A100');
y=xlsread('node','B1:B100');
%Membentuk Topologi Awal%
for i=1:n
    SN(i).id=i;	%Sensor Id
    SN(i).x=x(i);
    SN(i).y=y(i);
    SN(i).E=Eo;     % set energi node sama dengan eo"
    SN(i).role=0;   % set role node jika node biasa =0 dan jika sebagai CH set =1
    SN(i).cluster=0;	% set node berada pada cluster mana, secara default set 0
    SN(i).cond=1;	% Set status node jika node masih memiliki energi maka nilai =1 jika node sudah mati maka set =0
    SN(i).rop=0;	% untuk mengetahui node berada pada round berapa
    SN(i).dtch=0;	% jarak node dengan CH
    SN(i).dts=0;    % jarak node dengan Sink/BS
    SN(i).tel=0;	% sudah berapa kali node di set sebagai CH
    SN(i).rn=0;     % round ke berapa node terpilih sebagai CH
    SN(i).chid=0;   % id node sebagai CH
    SN(i).rleft=0;  % rounds left for node to become available for Cluster Head election
    SN(i).re=Eo;
    hold on;
    figure(1)
    plot(xm,ym,SN(i).x,SN(i).y,'ob',sinkx,sinky,'*r');
    title 'Wireless Sensor Network';
    xlabel '(m)';
    ylabel '(m)';
end


%%% Set Up Phase %%%
%%Proses K-Means++%%
k=input('Masukkan jumlah klaster : ');
    % Reseting Previous Amount Of Cluster Heads In the Network %
	CLheads=0;
    % Reseting Previous Amount Of Energy Consumed In the Network on the Previous Round %
    energy=0;
    
    %Penentua C1 Awal dengan mencari jarak terjauh dengan BS
    startx=[];
    starty=[];
    center=[startx starty]; %menyimpan nilai C1
    d=[];
    for i=1:n
        SN(i).cluster=0;    % reseting cluster in which the node belongs to
        SN(i).role=0;       % reseting node role
        SN(i).chid=0;       % reseting cluster head id
        
        c=[SN(i).x SN(i).y]; %mengambil data node ke-i
        distance=sqrt((sinkx-c(:,1))^2+(sinky-c(:,2))^2); %mengurangi jarak BS dengan node
        d=[d distance]; % menyimpan index dan nilai jarak masing" node dengan BS
    end
    [e s]=max(d); %mencari nilai terbesar dari distance yang dipilih sebagai C1
    center=[center;[x(s) y(s)]]; %menyimpan koordinat c1 dalam array
    x(s)=[]; %mengosongkan kembali nilai x dan y
    y(s)=[];
    d=[];

    %Proses mencari C selanjutnya
    r=1;
    while(r~=k)
        for i=1:n
            g=[SN(i).x SN(i).y]; %Mengambil data kordinat node ke i
            ka=dsearchn(center,g); %Mencari node terdekat dengan data pusat klaster
            nearestx=center(ka,1); %Mencari data terdekat pada nilai kordinat x
            nearesty=center(ka,2); %Mencari data terdekat pada nilai kordinat y
            distance=sqrt((nearestx-g(:,1))^2+(nearesty-g(:,2))^2); %Menghitung jarak node dengan cluster head
            d=[d distance]; %Menyimpan nilai jarak dan indeksnya
        end
        [e s]=max(d); %Mencari data jarak dengan nilai max/tertinggi
        center=[center;[x(s) y(s)]]; %Menyimpan data node dengan jarak tertinggi pada aray CH
        SN(s).tel=SN(s).tel+1;
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
        for(i=1:n) %perulangan mencari jarak setiap node
            data=[];
            for(j=1:length(cx)) %mencari jarak setiap node dengan setiap cluster head
                data=[data sqrt((SN(i).x-cx(j))^2+(SN(i).y-cy(j))^2)];
            end
            [gc index]=min(data); %Mencari jarak terendah node dengan CH
            
            outputx{index}=[outputx{index} SN(i).x]; %Mengelompokkan data sesuai CH terdekat
            outputy{index}=[outputy{index} SN(i).y]; %Mengelompokkan data sesuai CH terdekat
            SN(i).cluster=index; %Menyimpan nilai cluster tiap node
            SN(i).dtch=min(data); %Menyimpan jarak node dengan pusat cluster
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
           plot(xf,yf,'bo','linewidth',3);
        elseif(i==2)
           plot(xf,yf,'go','linewidth',3);
        elseif(i==3)
           plot(xf,yf,'ro','linewidth',3);
        elseif(i==4)
           plot(xf,yf,'co','linewidth',3);
        elseif(i==5)
           plot(xf,yf,'mo','linewidth',3);
        elseif(i==6)
           plot(xf,yf,'yo','linewidth',3);
        elseif(i==7)
           plot(xf,yf,'ko','linewidth',3);
        elseif(i==8)
           plot(xf,yf,'rx','linewidth',3);
        elseif(i==9)
           plot(xf,yf,'bx','linewidth',3);
        else
           plot(xf,yf,'gx','linewidth',3);
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
    
    %Pemilihan CH
	% Reseting Previous Amount Of Cluster Heads In the Network %
	CLheads=0;
    
    % Reseting Previous Amount Of Energy Consumed In the Network on the Previous Round %
    energy=0;

    %Pemilihan CH tiap cluster
    for i=1:k
        for j=1:n
            if(SN(j).cluster==i && SN(j).role==0)
                if(SN(j).rleft>0)
                    SN(j).rleft=SN(j).rleft-1;
                end
                if (SN(j).E>0) && (SN(j).rleft==0 && SN(j).role==0)
                    for l=1:n
                        if(SN(j).re>=SN(l).re && SN(j).cluster==SN(l).cluster) %jika re lebih besar pada klaster yang sama
                            SN(j).role=1;	% assigns the node role of acluster head
                            SN(j).tel=SN(j).tel + 1;   
                            SN(j).rleft=1;    % rounds for which the node will be unable to become a CH
                            SN(j).dts=sqrt((sinkx-SN(j).x)^2 + (sinky-SN(j).y)^2); % calculates the distance between the sink and the cluster hea
                            CLheads=CLheads+1;	% sum of cluster heads that have been elected 
                            SN(j).cluster=CLheads; % cluster of which the node got elected to be cluster head
                            CL(CLheads).x=SN(j).x; % X-axis coordinates of elected cluster head
                            CL(CLheads).y=SN(j).y; % Y-axis coordinates of elected cluster head
                            CL(CLheads).id=i; % Assigns the node ID of the newly elected cluster head to an array
                            break
                        end
                    end
                    if(SN(j).role==1)
                        break
                    end
                end
            end
        end 
    end
   
   
   