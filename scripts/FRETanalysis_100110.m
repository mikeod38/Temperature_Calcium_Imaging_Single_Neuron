clear all; 
close all
[fname,mypath]=uigetfile('*.tif','Select the first file you''d like to open');
%cd(mypath)
stack=tiffread2([mypath fname]);
filename = find(mypath ==filesep);

filename = fname(1:end-4);
 
Total_Data = struct2cell(stack);
% stack=[];
Images = Total_Data(7,1,:);
Images = cell2mat(Images);
L=size(Images);
%%============== Show movie ===================

% L=size(Images);
% h=figure;
% set(h,'Units','pixels','UserData','matrix');
% set(h,'Position',[400,400,2*L(2),2*L(1)]);
% for i=1:10:L(3)
% I=zeros(L(1),L(2));
% I(:,:)=Images(:,:,i);
% imagesc(I);
% pause(0.02);
% hold on
% end
%% ============== Show movie end===================

Image1(:,:) = max(Images,[],3);
figure
imagesc(Image1);
% zoom on;
% disp('Zoom onto Right Neuron position, Press space to end.');
% pause; zoom off;
disp('Choose first rectangle for the neuron location, and a second rectangle for the neuron Background.... Press Enter to Finish.'); 
h = imrect;
Neuron_position = wait(h);
h = imrect;
Sub_Im_Width = round(Neuron_position(3)/2);
Sub_Im_Length = round(Neuron_position(4)/2);
BG_position = wait(h);
Sub_BG_Width = round(BG_position(3)/2);
Sub_BG_Length = round(BG_position(4)/2);

R_Neuron_X = uint16(Neuron_position(1) + Sub_Im_Width);
R_Neuron_Y = uint16(Neuron_position(2) + Sub_Im_Length);
R_Neuron_BG_X = uint16(BG_position(1) + Sub_BG_Width);
R_Neuron_BG_Y = uint16(BG_position(2) +Sub_BG_Length);

Symmetry_L=round(L(2)/2);

L_Neuron_X=R_Neuron_X - Symmetry_L;
L_Neuron_Y=R_Neuron_Y;
L_Neuron_BG_X=R_Neuron_BG_X - Symmetry_L;
L_Neuron_BG_Y=R_Neuron_BG_Y;
% 
% % Neuron_Im_S=30;
% % BG_Im_S=8;
% L=size(Images);
Neuron_Pixel_Size=100;
% L=L(3);
R_Neuron_Im = Images(R_Neuron_Y-Sub_Im_Length:R_Neuron_Y+Sub_Im_Length, R_Neuron_X-Sub_Im_Width:R_Neuron_X+Sub_Im_Width,:);
R_Neuron_Im = reshape(R_Neuron_Im,1,[],L(3));
R_Neuron_Im = squeeze(R_Neuron_Im);
R_Neuron_Im = R_Neuron_Im';

L_Neuron_Im = Images(L_Neuron_Y-Sub_Im_Length:L_Neuron_Y+Sub_Im_Length, L_Neuron_X-Sub_Im_Width:L_Neuron_X+Sub_Im_Width,:);
L_Neuron_Im = reshape(L_Neuron_Im,1,[],L(3));
L_Neuron_Im = squeeze(L_Neuron_Im);
L_Neuron_Im = L_Neuron_Im';

R_Neuron_BG_Im = Images(R_Neuron_BG_Y-Sub_BG_Length:R_Neuron_BG_Y+Sub_BG_Length, R_Neuron_BG_X-Sub_BG_Width:R_Neuron_BG_X+Sub_BG_Width,:);
R_Neuron_BG_Im = reshape(R_Neuron_BG_Im,1,[],L(3));
R_Neuron_BG_Im = squeeze(R_Neuron_BG_Im);
R_Neuron_BG = mean(R_Neuron_BG_Im);

L_Neuron_BG_Im = Images(L_Neuron_BG_Y-Sub_BG_Length:L_Neuron_BG_Y+Sub_BG_Length, L_Neuron_BG_X-Sub_BG_Width:L_Neuron_BG_X+Sub_BG_Width,:);
L_Neuron_BG_Im = reshape(L_Neuron_BG_Im,1,[],L(3));
L_Neuron_BG_Im = squeeze(L_Neuron_BG_Im);
L_Neuron_BG = mean(L_Neuron_BG_Im);

[R_Neuron, IX]= sort(R_Neuron_Im, 2,'descend');
R_Neuron= R_Neuron(:,1:Neuron_Pixel_Size);
L=size(R_Neuron_Im);
R_Min_Col=R_Neuron(:,end);
R_Neuron_loc=zeros(L(1),L(2));

 
[L_Neuron, L_IX]= sort(L_Neuron_Im, 2,'descend');
L_Neuron= L_Neuron(:,1:Neuron_Pixel_Size);
L_Min_Col=L_Neuron(:,end);
L_Neuron_loc=zeros(L(1),L(2));

Left_Neuron_BG=zeros(L(1),L(2));
Right_Neuron_BG=zeros(L(1),L(2));

for i = 1:L(1)
   R_Neuron_loc(i,:)= R_Neuron_Im(i,:) >= R_Min_Col(i);
   L_Neuron_loc(i,:)= L_Neuron_Im(i,:) >= L_Min_Col(i);
   Left_Neuron_BG(i,:)= L_Neuron_loc(i,:)*L_Neuron_BG(i);
   Right_Neuron_BG(i,:)= R_Neuron_loc(i,:)*R_Neuron_BG(i);
end;


R_Neuron_Pixels=sum(R_Neuron_loc');
L_Neuron_Pixels=sum(L_Neuron_loc');
%%------------------------------------------------------------------------------------------
 Left_Neuron_BG=uint16(Left_Neuron_BG);
 Right_Neuron_BG=uint16(Right_Neuron_BG);
 R_Neuron_loc=uint16(R_Neuron_loc);
 L_Neuron_loc=uint16(L_Neuron_loc);
 
R_Neuron_Im = R_Neuron_Im.*R_Neuron_loc;
L_Neuron_Im = L_Neuron_Im.*L_Neuron_loc;

CFP = R_Neuron_Im - Right_Neuron_BG;
YFP = L_Neuron_Im - Left_Neuron_BG;

CFP = sum(CFP');
CFP=CFP./R_Neuron_Pixels;
YFP = sum(YFP');
YFP=YFP./L_Neuron_Pixels;
FRET=CFP./YFP;

Norm_CFP=CFP./max(CFP);
Good_IND= find(Norm_CFP>=0.1);

CFP=CFP(Good_IND);
YFP=YFP(Good_IND);
FRET=FRET(Good_IND);

Right_Neuron_BG = sum(Right_Neuron_BG')./R_Neuron_Pixels;
Right_Neuron_BG = Right_Neuron_BG(Good_IND);
Left_Neuron_BG = sum(Left_Neuron_BG')./L_Neuron_Pixels;
Left_Neuron_BG = Left_Neuron_BG(Good_IND);


Lab_View_File = load(strcat(mypath,fname(1:end-3),'txt'));
Temperat = Lab_View_File(:,2);
Temperature = interp1(1:length(Temperat),Temperat,Good_IND)
%Temperature = Temperature(Good_IND);
Image_Time = Good_IND;

Total_Figure = figure;

 subplot(3,2,2);

BG=[R_Neuron_BG L_Neuron_BG];
BG=round(BG);

plot(Image_Time,Right_Neuron_BG,'Color','c','LineWidth',2); hold on;
plot(Image_Time,Left_Neuron_BG,'Color','r','LineWidth',2);
ylabel('Background');

subplot(3,2,1);
set(gca,'ylim',[0 1])
plot(Image_Time,CFP,'LineWidth',2,'Color','c'); hold on;
plot(Image_Time,YFP,'LineWidth',2,'Color','r');
ylabel('CFP and YFP');

subplot(3,2,3);
set(gca,'ylim',[0 1]);
plot(Image_Time,CFP./max(CFP),'LineWidth',2,'Color','c'); hold on;
plot(Image_Time,YFP./max(YFP),'LineWidth',2,'Color','r');
ylabel('Normalized CFP and YFP');

dT=diff(Temperature);
dFRET=diff(FRET);
T=Image_Time(2:end);

subplot(3,2,4);
[AX,H1,H2]=plotyy(T,smooth(dFRET), T,smooth(dT),'plot');
xlabel('Time'); ylabel('dFRET / dTemperature');

subplot(3,2,[5 6]);
set(gca,'ylim',[min(CFP./YFP) max(CFP./YFP)]);
[AX,H1,H2]=plotyy(Image_Time,CFP./YFP, Image_Time,Temperature,'plot');
set(gca,'ylim',[min(FRET) max(FRET)]);
[AX,H1,H2]=plotyy(Image_Time,FRET, Image_Time,Temperature,'plot');
set(H1,'LineStyle','-','LineWidth',2,'color', 'k');
set(H2,'LineStyle','--','LineWidth',2,'color', 'g');

ylabel('FRET signal CFP/YFP');
xlabel('Time (sec) ');

saveas(Total_Figure,[mypath filesep 'Total_' filename '.fig'],'fig');
saveas(Total_Figure,[mypath filesep 'Total_' filename '.jpg'],'jpg');

% sara's edit (delta F/F)
Delta_R_Figure = figure;
axes_Delta_R = axes('Parent',Delta_R_Figure);
baseline=mean(FRET(1:10));
delta_F=((FRET-baseline)/baseline)*100;
[AX,H1,H2]=plotyy(Image_Time,delta_F, Image_Time,Temperature,'plot');
hold on
%[AX,H1,H2]=plotyy(Image_Time,FRET1, Image_Time,Temperature,'plot');
set(H1,'LineStyle','-','LineWidth',2,'color', 'b');
set(H2,'LineStyle','--','LineWidth',2,'color', 'g');
%ylim(axes_Delta_R,[-50 150])
ylabel('\DeltaR/R (%)');
xlabel('Time (sec) ');
ylabel(AX(2),'Temperature \circC')

saveas(Delta_R_Figure,[mypath filesep 'Delta_R_Figure_' filename '.fig'],'fig');
saveas(Delta_R_Figure,[mypath filesep 'Delta_R_Figure_' filename '.jpg'],'jpg');


%title('strain; Ex(AFD::YC3.60) n? Tc=20\circC T* = ?\circC')
% saveas(Delta_R_Figure,['Delta_R_' filename '.fig'],'fig');
% saveas(Delta_R_Figure,['Delta_R_' filename '.jpg'],'jpg');

% clearvars -except Image_Time Temperature CFP YFP FRET baseline filename delta_F
% 
 %if(strcmpi(x,'y'))
 filename = ['FRET_Analysis_' fname(end-5:end-4) '.mat'];

                clear stack Total_Data Images Lab_View_File BG Image1 L_Neuron
                clear R_Neuron L_Neuron_BG_Im R_Neuron_BG_Im L_Neuron_Im
                clear L_Neuron_loc R_Neuron_Im R_Neuron_loc IX L_IX L_Neuron_BG
                clear L_Neuron_Pixels R_Neuron_BG R_Neuron_Pixels T_file M
                clear AX Delta_R_Figure H1 H2 L Neuron_Pixel_Size axes_Delta_R
                clear f
save ([mypath filename])
disp('saved');
 %else
 %    disp('NOT saved');
 %end



