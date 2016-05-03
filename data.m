function txt = data(empt,event_obj)
load data_
pos = get(event_obj,'Position');
hit=sqrt((xi-(pos(1))).^2);
index=find(hit==min(hit));
Energy=round(Ei(index)/1E4)/1E2;
txt = {['B-field deflection: ',num2str((round((xi(index)-xoffset)*100))/100) ' mm'],['Energy: ',num2str(Energy) ' MeV'],...
       ['Position (x/y): (',num2str(round(pos(1)*10)/10),' / ',num2str(round(pos(2)*100)/100),')']};
end