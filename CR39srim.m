function [E_CR39_Alu, E_alu_end]=CR39srim(CR39,alu)

if nargin<2
    options.Resize='on';
    options.WindowStyle='normal';
    options.Interpreter='tex';
	prompt = {'Enter Aluminum thickness in microns:','Enter CR39 thickness in microns:'};
	dlg_title = ['Specify parameters'];
	num_lines = 1;
	def = {'15','1000'};
	parameters =inputdlg(prompt,dlg_title,num_lines,def,options);
    
    if isempty(parameters)
        E_CR39_Alu=0;
        E_alu_end=0;
        disp('User canceled input');
        return
    end
    
    alu_thickness=str2double(cell2mat(parameters(1,1)));
    CR39thickness=str2double(cell2mat(parameters(2,1)));

else    
    CR39thickness=CR39;
    alu_thickness=alu;
end

h = msgbox('Calculating','Please wait');
pause(.5)

%CR39thickness=1030;
%alu_thickness=18;


Alu=load('Alusrim.txt');
E_alu=Alu(:,1); %ion energy in keV
dE_electron_alu=Alu(:,2)*2.7019e2; %stopping in units of  keV / micron 
dE_ion_alu=Alu(:,3)*2.7019e2;
range_alu=Alu(:,4); %range in um

E_alui=(10:50000)';  %keV steps
dEdx_electron_alu=interp1(E_alu,dE_electron_alu,E_alui);
dEdx_ion_alu=interp1(E_alu,dE_ion_alu,E_alui);

index=0;
for Ealu_in=10:50000
    index=index+1;
    Ealu_out=Ealu_in;
    um_alu=1;
    while Ealu_out>10
        Ealu_out=round(Ealu_out-dEdx_electron_alu(Ealu_out-9)+dEdx_ion_alu(Ealu_out-9));
        um_alu=um_alu+1; 
    end
    range_alu(index,1)=Ealu_in;
    range_alu(index,2)=um_alu;
end

[index_alu]=find(range_alu(:,2)==alu_thickness); 
E_alu_end=range_alu(index_alu(round(length(index_alu)/2))); %minimum energy that is needed to pass thickness of alu layer

CR=load('CR39srim.txt') ;
E=CR(:,1); %ion energy in keV
dE_electron=CR(:,2)*1.31e02; %stopping in units of  keV / micron 
dE_ion=CR(:,3)*1.31e02;
range=CR(:,4); %range in um

Ei=(10:50000)';  %keV steps
dEdx_electron=interp1(E,dE_electron,Ei);
dEdx_ion=interp1(E,dE_ion,Ei);

index=0;
for E_in=3000:15000
    index=index+1;
    E_out=E_in;
    um=1;
    while E_out>E_alu_end
        E_out=round(E_out-dEdx_electron(E_out-9)+dEdx_ion(E_out-9));
        um=um+1;  
    end
    range_CR39(index,1)=E_in;
    range_CR39(index,2)=um;
end
    
[index]=find(range_CR39(:,2)==CR39thickness); 
if isempty(index_alu)==0
E_CR39_Alu_alternate=range_CR39(index(round(length(index)/2)))/1e3; %minimum energy that is needed to pass CR39 and Alu layer
end

for E_in=3000:15000
    index=index+1;
    E_out=E_in;
    for um=1:CR39thickness
        if E_out<10
            break
        end
        E_out=round(E_out-dEdx_electron(E_out-9)+dEdx_ion(E_out-9));
     end
    after_CR39(index,1)=E_in;
    after_CR39(index,2)=E_out;
end
E_CR39_Alu=round(after_CR39(find(after_CR39(:,2)==E_alu_end))/1e3*100)/100;
E_alu_end=round(E_alu_end/1e3*100)/100;

close(h)
end