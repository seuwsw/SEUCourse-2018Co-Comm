 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 %12/17/2018     Wang Siwei
 %һ�����в�����AF�������
 %����ԭ��������벿���������������Pudn��
 %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
echo off;clear all;close all;clc;
tic
N=1000;
L=65;    %һ֡����
BerSnrTable=zeros(20,5);
for snr=0:25
    %snr = snrpot+snrpot;
    BerSnrTable(snr+1,1) = snr;
    sig=1/sqrt(10^(snr/10));
    %temp=0;%
    %temp1=0;%
    for i=1:N
        BitsTx = floor(rand(1,L)*2);
        P=mean(abs(BitsTx(:)).^2);
        %BitsTxcrc=CrcEncode(BitsTx);%
        BitsTxcnv=cnv( BitsTx);%ȷ�������ƾ�����������������
        Mod8Tx=mod_8psk(BitsTxcnv);%8PSK����
        M=length(Mod8Tx);%M=36
        %����Ϊ�����ŵ�ģ�ͺ�����ģ�ͣ����ڱ��η����ص㲻���ڴˣ����������¼�
        H1d=RayleighCH();%RayleighCH�ŵ�ģ��
        H12=RayleighCH();
        H2d=RayleighCH();
        Z1d=randn(1,M)+j*randn(1,M);
        Z12=randn(1,M)+j*randn(1,M);
        Z2d=randn(1,M)+j*randn(1,M);
        
        %user2���ղ�����
        
        Y12=H12.*Mod8Tx+sig*Z12;
        R12=conj(H12).*Y12;
        BitR12=demod_8psk(R12);%8PSK���
        BitR12viterbi=viterbi(BitR12);%Ӳ�о���������о����룬�������
        BitR12viterbi=BitR12viterbi(1:length(BitR12viterbi)-1);
        %[BitR12decrc,error]=CrcDecode(BitR12viterbi);%CrcDecode.m�������ҵĿ�Դ���룬����û����
         %error=0,��ȷ����   error=1���������
         %��Э�����
        %if(error==1)%
            Y1d=H1d.*Mod8Tx+sig*Z1d;
            R1d=conj(H1d).*Y1d; 
            BitR1d=demod_8psk(R1d);
            BitR1dviterbi=viterbi(BitR1d);
            BitR1dviterbi=BitR1dviterbi(1:length(BitR1dviterbi)-1);
            
            [Num1,Ber1] = symerr( BitR1dviterbi,BitsTx);
            BerSnrTable(snr+1,4)=BerSnrTable(snr+1,4)+Num1;
            
            %BitR1ddecrc=CrcDecode(BitR1dviterbi);%
            %[Num,Ber] = symerr(BitR1ddecrc,BitsTx);%
            %BerSnrTable(snr+1,2)=BerSnrTable(snr+1,2)+Num;%
        %end%
         %Э�����
        %if(error==0)%
            G=sqrt(P/(P*abs(H12).^2+2*sig*sig));
            Bits2d=BitR12viterbi;
            %Bits2dcrc=CrcEncode(Bits2d);%CRC�������
            Bits2dcnv=cnv(Bits2d);%ȷ�������ƾ�����������������
            Mod8_2d=mod_8psk(Bits2dcnv);
            Y2d=H2d.*G*(Mod8_2d+sig*Z12)+sig*Z2d;
            %���ϲ����ڴ˴��ļ���ʽ
            Rd=conj(H2d).*Y2d+conj(H1d).*Y1d;
            BitRd=demod_8psk(Rd);
            BitRdviterbi=viterbi(BitRd);
            BitRdviterbi=BitRdviterbi(1:length(BitRdviterbi)-1);
            %BitRddecrc=CrcDecode(BitRdviterbi);%%CRC�������
            [Num,Ber] = symerr( BitRdviterbi,BitsTx);%����������
            BerSnrTable(snr+1,2)=BerSnrTable(snr+1,2)+Num;%�������ۼ�
            %temp=temp+1;%
        %end   %
    end
    BerSnrTable(snr+1,3)=BerSnrTable(snr+1,2)/(L*N);
    BerSnrTable(snr+1,5)=BerSnrTable(snr+1,4)/(L*N);%���������
    %BerSnrTable(snr+1,4)=temp;%
end   
semilogy(BerSnrTable(:,1),BerSnrTable(:,5),'bD-',BerSnrTable(:,1),BerSnrTable(:,3),'r*-');
xlabel('�����(SNR)');ylabel('������');title('AF��������������ʹ�ϵ');
legend('Э��ģʽ','��Э��ģʽ')
%figure
%semilogy(BerSnrTable(:,1),BerSnrTable(:,4),'g*-');
time_of_sim = toc
echo on;


