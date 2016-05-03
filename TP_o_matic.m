function varargout = TP_o_matic(varargin)
% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TP_o_matic_OpeningFcn, ...
                   'gui_OutputFcn',  @TP_o_matic_OutputFcn, ...
                   'gui_LayoutFcn',  [], ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
   gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT

% --- Executes just before TP_o_matic is made visible.
function TP_o_matic_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

clc;
clear all;
global a_i linesub incx linehight
linehight=0;
incx=1;
a_i=[1,1];
linesub=1;
relsol=0;
ener=plot(0,0);


function varargout = TP_o_matic_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

function load_Callback(hObject, eventdata, handles)
global incx incy imlength xlength ylength pname fname simu zero back over spl
axes(handles.main);
datacursormode off
button=num2str(get(hObject,'Tag'));
if strcmp(button,'load')
    if exist('lastpath.txt','file')
        fid = fopen('lastpath.txt','r');
        pname=(fread(fid,'*char'))';
        fclose(fid);
    else
        pname='c:\';
    end
    [Matrix_new,incx_new,incy_new,fname_new,pname_new]=loadasf(pname);
    if Matrix_new==0
        errordlg('No valid image file selected','Error');
        return
    else
        Matrix=Matrix_new;
        clear Matrix_new
        incx=incx_new;
        incy=incy_new;
        fname=fname_new;
        pname=pname_new;
    end
    fid = fopen('lastpath.txt', 'wt');
    fprintf(fid, '%s', pname);
    fclose(fid);
    mx=5*mean(mean(Matrix));
    if mx>=1 && mx <65000
        set(handles.cmax,'string',num2str(round(mx)));
        set(handles.cmax,'value',round(mx));
        set(handles.cmax_text,'string',num2str(round(mx)),'foregroundcolor',[0 0 0]);
    elseif mx<1
        set(handles.caxismax1,'string',num2str(round((mx)*1000)/1000));
        set(handles.caxismax1,'value',round((mx)*1000)/1000);
        set(handles.cmax_text,'string',num2str(round((mx)*1000)/1000),'foregroundcolor',[0 0 0]);
    end
elseif strcmp(button,'saveim')
    if isappdata(handles.main,'M')==0
        errordlg('No image loaded','Error');
        return
    else
        Matrix=getappdata(handles.main,'M');
        if incx==incy
            inc=num2str(incx);
        else
            inc=[num2str(incx),'x',num2str(incx),'y'];
        end
        filename=[pname,fname(1:length(fname)-4),'_ed_',inc,'um'];
        %uisave('Matrix',filename)
        [filename, pathname] = uiputfile('*.mat','Save as',filename)
        save([pathname,filename],'Matrix')
        if filename~=0
            fname=filename;
            pname=pathname;
        end
        
    end
elseif strcmp(button,'merge')
    [Matrix,incx,incy]=asfmerger(pname);
    if Matrix==0
        errordlg('No image merged','Error');
        return
    end
    fname=['merged image_',num2str(incx),'_um pixelwidth'];
elseif strcmp(button,'cleanasf')
    if ischar(fname)
        type=fname(length(fname)-2:length(fname));
        if ~strcmp(type,'asf') && ~strcmp(type,'ASF')
            fname=0;
        end        
    end
    if exist('lastpath.txt','file')
        fid = fopen('lastpath.txt','r');
        pname=(fread(fid,'*char'))';
        fclose(fid);
    else
        pname='c:\';
    end
	h = cleanasf_dialog();
    return
elseif strcmp(button,'reload')
    if isempty(pname) || isappdata(handles.main,'M')==0
        errordlg('Nothing there to reload!','Error');
        return
    else
        rmappdata(handles.main,'M')
        [Matrix,incx,incy,fname,pname]=loadasf(pname,fname);
        try
            efield_Callback(hObject, eventdata, handles)
        end
    end
elseif strcmp(button,'rotate')
    if isappdata(handles.main,'M')==0
        errordlg('No image loaded','Error');
        return
    else
        Matrix=rot90(getappdata(handles.main,'M'));
        incx_old=incx;
        incy_old=incy;
        incx=incy_old;
        incy=incx_old;
    end
elseif strcmp(button,'invert')
    if isappdata(handles.main,'M')==0
        errordlg('No image loaded','Error');
        return
    else
        Matrix=getappdata(handles.main,'M')';
        incx_old=incx;
        incy_old=incy;
        incx=incy_old;
        incy=incx_old;
    end
elseif strcmp(button,'invertmatrix')
    if isappdata(handles.main,'M')==0;
        errordlg('No image loaded','Error');
        return
    else
        Matrix=2^16-getappdata(handles.main,'M');
    end
elseif strcmp(button,'resim')
     if isappdata(handles.main,'M')==0;
        errordlg('No image loaded','Error');
        return
    else
        Matrix=getappdata(handles.main,'M');
        try
            efield_Callback(hObject, eventdata, handles)
        end
    end    
elseif strcmp(button,'cut')
    if isappdata(handles.main,'M')==0
        errordlg('No image loaded','Error');
        return
    else
        % Construct a questdlg 
        choice = questdlg('Please choose method:','Cutting method', ...
        'Rectangle','Spline','Cancel','Cancel');
        % Handle response
        switch choice
        case 'Rectangle'
            rect=round(getrect(handles.main)/incx*1e3);
            Matrix=getappdata(handles.main,'M');
            if rect(1,2)<1
                ymi=1;
            else
                ymi=rect(1,2);
            end
            if rect(1,2)+rect(1,4)>imlength(1,1)
                yma=imlength(1,1);
            else
                yma=rect(1,2)+rect(1,4);
            end
            if rect(1,1)<1
                xmi=1;
            else
                xmi=rect(1,1);
            end
            if rect(1,1)+rect(1,3)>imlength(1,2)
                xma=imlength(1,2);
            else
                xma=rect(1,1)+rect(1,3);
            end
            Matrix=Matrix(ymi:yma,xmi:xma);
            % correct zero offset
            xoff_old=get(handles.xoffset,'value');
            yoff_old=get(handles.yoffset,'value');
            xoff=xoff_old-xmi*incx*1e-3;
            yoff=yoff_old-ymi*incy*1e-3;
            x =strcat(num2str((round(xoff*100))/100),' mm');
            y =strcat(num2str((round(yoff*100))/100),' mm'); 
            set(handles.xoffset,'String',x)
            set(handles.xoffset,'value',xoff)
            set(handles.yoffset,'String',y)
            set(handles.yoffset,'value',yoff)
        case 'Spline'
            delete(spl(ishandle(spl)))
            xy = [];
            n = 0;
            % Loop, picking up the points.
            disp('Left mouse button picks points.')
            disp('Right mouse button picks last point.')
            but = 1;
            hold on
            while but == 1
                [xi,yi,but] = ginput(1);
                n = n+1;
                spl(n)=plot(xi,yi,'ro');
                xy(:,n) = [xi;yi];
            end
            % Interpolate with a spline curve and finer spacing.
            if n==1
                errordlg('Please set at least 2 points!','Error');
                return
            end
            t = 1:n;
            ts = 1: n/100 : n;
            xys = spline(t,xy,ts);
            % Plot the interpolated curve.
            spl(n+1)=plot(xys(1,:),xys(2,:),'g-','Linewidth',2);
            Matrix=getappdata(handles.main,'M');
            status = waitbar(0,'Please wait...');
            pause(.1)
            m=min(min(Matrix));
            for v=1:imlength(1,2)
                waitbar(v /imlength(1,2),status)
                pause(0.01)
                r=sqrt((xys(1,:)-v*incx*1e-3).^2)';
                [value,index]=min(r);
                for w=1:imlength(1,1)
                    if w*incy*1e-3>xys(2,index)
                        Matrix(w,v)=m;
                    end
                end
            end
            delete(status)
            hold off
        case 'Cancel'
            return
        end
    end
     mx=5*mean(mean(Matrix));
    if mx>=1 && mx <65000
        set(handles.cmax,'string',num2str(round(mx)));
        set(handles.cmax,'value',round(mx));
        set(handles.cmax_text,'string',num2str(round(mx)),'foregroundcolor',[0 0 0]);
    elseif mx<1
        set(handles.caxismax1,'string',num2str(round((mx)*1000)/1000));
        set(handles.caxismax1,'value',round((mx)*1000)/1000);
        set(handles.cmax_text,'string',num2str(round((mx)*1000)/1000),'foregroundcolor',[0 0 0]);
    end
end
clear xi
clear Ei
clear yi

imlength=size(Matrix);
ylength=0:incy*1E-3:imlength(1,1)*incy*1E-3;
xlength=0:incx*1E-3:imlength(1,2)*incx*1E-3;
imagesc(xlength,ylength,Matrix);

hold on
simu=plot(0,0);
zero=plot(0,0);
back=plot(0,0);
over=plot(0,0);
spl=plot(0,0);
ener=plot(0,0);
hold off
axis xy
xlabel('B-field deflection (mm)')
ylabel('E-field deflection (mm)')
T=title(fname);
set(T,'Interpreter','none')
cmin=get(handles.cmin,'Value');
cmax=str2double(get(handles.cmax_text,'string'));
caxis([cmin cmax]);

%rot90 and invert may swap incx and incy, which will cause problems if they are not equal
set(handles.xpx_text,'string',[num2str(incx),' um']);
set(handles.ypx_text,'string',[num2str(incy),' um']);
width = round(get(handles.width, 'Value'));
set(handles.width_text,'string',[num2str(width), 'um / ',num2str(round(width/incx)),'pixel']);
spotsize=str2double(get(handles.spot,'string'));
set(handles.spotpx,'string',num2str(round(spotsize/incx)));
set(handles.hbin,'value',spotsize);
set(handles.hbin_text,'string',[num2str(spotsize), 'um / ',num2str(round(spotsize/incx)),'pixel']);
setappdata(handles.main,'M',Matrix)


function zeropoint_Callback(hObject, eventdata, handles)
global zero ylength xlength
datacursormode off
button=num2str(get(hObject,'Tag'));
if isappdata(handles.main,'M')==0
    errordlg('No image loaded','Error');
else
    if strcmp(button,'zeropoint')
        [xoff,yoff] = ginput(1);  
    elseif strcmp(button,'find0')
        choice = questdlg('Please choose method:','Select method', ...
        'Energy method','Distance method','Cancel','Cancel');
        % Handle response
        switch choice
            case 'Distance method'
                options.Resize='on';
                options.WindowStyle='normal';
                options.Interpreter='tex';
                prompt = {'Enter Xoffset of marker:','Enter Yoffset of marker:'};
                dlg_title = 'Marker position:';
                num_lines = 1;
                if exist('lastmarker.mat','file') 
                    load lastmarker.mat
                else
                    markerx=0;
                    markery=0;
                end
                def = {num2str(markerx),num2str(markery)};
                marker =inputdlg(prompt,dlg_title,num_lines,def,options);
                if isempty(marker)
                    return
                end
                markerx = str2double(cell2mat(marker(1,1)));
                markery = str2double(cell2mat(marker(2,1)));
                save('lastmarker.mat','markerx','markery')
            case 'Energy method'
                options.Resize='on';
                options.WindowStyle='normal';
                options.Interpreter='tex';
                prompt = {'Enter proton energy:'};
                dlg_title = 'Cut-off energy:';
                num_lines = 1;
                def = {num2str(25)};
                ce =inputdlg(prompt,dlg_title,num_lines,def,options);
                if isempty(ce)
                    return
                end
                markerce = str2double(cell2mat(ce(1,1)));
                B=get(handles.bfield, 'value')
                lB=get(handles.bfieldlength, 'value')/1E3
                Db=get(handles.drift, 'value')/1E3
                m=1.67e-27;
                markerx=1.602177e-19*B*lB*(Db+0.5*lB)/sqrt(2*m*(markerce*1e6*(1.602177e-19)))*1e3
                markery=0;
        end
       
        [xoff_mark,yoff_mark] = ginput(1); 
        xoff=xoff_mark-markerx;
        yoff=yoff_mark-markery;
    else
        xoff=str2double(get(handles.xoffset,'string'));
        if isnan(xoff)
            xoff=get(handles.xoffset,'value');
        end
        yoff=str2double(get(handles.yoffset,'string'));
        if isnan(yoff)
            yoff=get(handles.yoffset,'value');
        end
        
    end
    
	x =num2str(round(xoff*100)/100);
	y =num2str(round(yoff*100)/100); 
	set(handles.xoffset,'String',x)
	set(handles.xoffset,'value',xoff)
	set(handles.yoffset,'String',y)
	set(handles.yoffset,'value',yoff)
    xoffset=double(xoff);
    yoffset=double(yoff);
    hold on
    delete(zero(ishandle(zero)))
    x=1:max(xlength);
    y=1:max(ylength);
    alpha=get(handles.angle,'value')/360*2*pi;
	zero(1)=plot(handles.main,xoffset+0*y,y,'-k','Linewidth',2);
    zero(2)=plot(handles.main,x,sin(alpha)*x+yoffset-sin(alpha)*xoffset,'-k','Linewidth',2);
    hold off
end

function getenergy_Callback(hObject, eventdata, handles)
global incx simu a_i incy xlength
xoffset=get(handles.xoffset,'value');
yoffset=get(handles.yoffset,'value');
edistance=get(handles.edistance,'value')/1E3;
E=get(handles.efield,'value')*1E3/edistance;
B=get(handles.bfield, 'value');
lB=get(handles.bfieldlength, 'value')/1E3;
lE=get(handles.efieldlength, 'value')/1E3;
D=get(handles.drift, 'value')/1E3;
alpha=get(handles.angle,'value');
spot=get(handles.width,'value')/1e3;
'hej'

if isappdata(handles.main,'M')==0
    incx=100; %in microns
end

if length(a_i(:,1))>1
        list=['Proton';'C5+   ';'C6+   '];
        str=cellstr(list);
        [selection,ok]=listdlg('PromptString','Select an ion species:','SelectionMode','single','ListString',str);
        if ok==0
            selection=1;
        end
else
    selection=1;
end
alpha=alpha/360*2*pi;  
delete(simu(ishandle(simu)))
hold all
Ecut=0;
index=0;
for number=1:length(a_i(:,1)) %for multiple traces
	index=index+1;
	a=a_i(number,2);
	A=a_i(number,1);
    relsol=get(handles.relsol,'value');
    if relsol==0
        trace=tracer(E,lE,B,lB,D,a,A); %retrieve trace for current parameters
    else
        trace=tracer_rk(E,lE,B,lB,D,a,A); %retrieve trace for current parameters using relativistic solver
    end
    xtrace=trace(:,2);
    ytrace=trace(:,3);
    Energy=trace(:,1);
    
    nans=find(isnan(xtrace));

    if isempty(nans)==0
        xtrace=xtrace(length(nans)+1:length(xtrace));
        ytrace=ytrace(length(nans)+1:length(ytrace));
        Energy=Energy(length(nans)+1:length(Energy));
    end
    if xlength<max(xtrace)
        xi_max=floor(max(xtrace));
        %xi_max=floor(max(xlength))+abs(xoffset);
    else
        xi_max=floor(max(xtrace));
    end
    xi=round(min(xtrace)):incx*1E-3:xi_max;
    Ei = interp1(xtrace,Energy,xi);
    yi = interp1(xtrace,ytrace,xi);
    xi=xi+xoffset;
    yi=yi+yoffset;
    %rotate calculated trace
    beta=atan((yi-yoffset)./(xi-xoffset));
    z=sqrt((xi-xoffset).^2+(yi-yoffset).^2);
    xi=(cos(alpha+beta).*z)+xoffset;
    yi=(sin(alpha+beta).*z)+yoffset;
    simu(index*3-2)=plot(handles.main,xi,yi,'k','Linewidth',2);
    simu(index*3-1)=plot(handles.main,xi,yi+spot/2,'k','Linewidth',2);
    simu(index*3)=plot(handles.main,xi,yi-spot/2,'k','Linewidth',2);
    if selection==number
    	save ('data_','Ei','xi','xoffset','incx','incy')
    end        
end
hold off
dcm_obj = datacursormode(gcf);
set(dcm_obj,'UpdateFcn',@data)
datacursormode on

function efield_Callback(hObject, eventdata, handles)
global incx incy a_i simu check Ei xi yi over zero xlength ylength
set(hObject, 'Enable', 'off');
pause(0.1)
datacursormode off
slider=num2str(get(hObject,'Tag'));
xoffset=get(handles.xoffset,'value');
yoffset=get(handles.yoffset,'value');
if strcmp(slider,'efield') || strcmp(slider,'efield_text')
    if strcmp(slider,'efield')
        Efield = round(get(hObject, 'Value')*10)/10;
    else
        Efield = round(str2double(get(hObject, 'string'))*10)/10;
        if isnan(Efield)
            Efield=10;
        elseif Efield >double(get(handles.efield,'Max'))
            Efield=50;
        elseif Efield <double(get(handles.efield,'Min'))
            Efield=0;
        end
    end
    set(handles.efield_text,'value',Efield)
    set(handles.efield_text,'string',num2str(Efield))
    set(handles.efield,'value',Efield)
elseif strcmp(slider,'efieldlength') || strcmp(slider,'efieldlength_text')
    if strcmp(slider,'efieldlength')
        Elength = round(get(hObject, 'Value'));
    else
        Elength = round(str2double(get(hObject, 'string')));
        if isnan(Elength)
            Elength=100;
        elseif Elength >double(get(handles.efieldlength,'Max'))
            Elength=double(get(handles.efieldlength,'Max'));
        elseif Elength <double(get(handles.efieldlength,'Min'))
            Elength=double(get(handles.efieldlength,'Min'));
        end
    end
    set(handles.efieldlength_text,'Value', Elength)
    set(handles.efieldlength_text,'String', num2str(Elength))
    set(handles.efieldlength,'value',Elength)
elseif strcmp(slider,'bfield') || strcmp(slider,'bfield_text')
    if strcmp(slider,'bfield')
        Bfield = round(get(hObject, 'Value')*100)/100;
    else
        Bfield = round(str2double(get(hObject, 'string'))*100)/100;
        if isnan(Bfield)
            Bfield=0.55;
        elseif Bfield >double(get(handles.bfield,'Max'))
            Bfield=double(get(handles.bfield,'Max'));
        elseif Bfield <double(get(handles.bfield,'Min'))
            Bfield=double(get(handles.bfield,'Min'));
        end
    end
    set(handles.bfield_text,'Value',Bfield)
    set(handles.bfield_text,'String',num2str(Bfield))
    set(handles.bfield,'value',Bfield)
elseif strcmp(slider,'edistance') || strcmp(slider,'edistance_text')
    if strcmp(slider,'edistance')
        edistance = round(get(hObject, 'Value')*10)/10;
    else
        edistance = round(str2double(get(hObject, 'string'))*10)/10;
        if isnan(edistance)
            edistance=20;
        elseif edistance >double(get(handles.edistance,'Max'))
            edistance=double(get(handles.edistance,'Max'));
        elseif edistance <double(get(handles.edistance,'Min'))
            edistance=double(get(handles.edistance,'Min'));
        end
    end
    set(handles.edistance_text,'Value',edistance)
    set(handles.edistance_text,'String',num2str(edistance))
    set(handles.edistance,'value',edistance)
elseif strcmp(slider,'bfieldlength') || strcmp(slider,'bfieldlength_text')
    if strcmp(slider,'bfieldlength')
        bfieldlength = round(get(hObject, 'Value'));
    else
        bfieldlength = round(str2double(get(hObject, 'string')));
        if isnan(bfieldlength)
            bfieldlength=100;
        elseif bfieldlength >double(get(handles.bfieldlength,'Max'))
            bfieldlength=double(get(handles.bfieldlength,'Max'));
        elseif bfieldlength <double(get(handles.bfieldlength,'Min'))
            bfieldlength=double(get(handles.bfieldlength,'Min'));
        end
    end
    set(handles.bfieldlength_text,'Value',bfieldlength)
    set(handles.bfieldlength_text,'String',num2str(bfieldlength))
    set(handles.bfieldlength,'value',bfieldlength)
elseif strcmp(slider,'drift') || strcmp(slider,'drift_text')
    if strcmp(slider,'drift')
        drift = round(get(hObject, 'Value'));
    else
        drift = round(str2double(get(hObject, 'string')));
        if isnan(drift)
            drift=460;
        elseif drift >double(get(handles.drift,'Max'))
            drift=double(get(handles.drift,'Max'));
        elseif drift <double(get(handles.drift,'Min'))
            drift=double(get(handles.drift,'Min'));
        end
    end
    set(handles.drift_text,'Value',drift)
    set(handles.drift_text,'String',num2str(drift))
    set(handles.drift,'value',drift)
    ph_d = drift+round(get(handles.bfieldlength, 'Value')*10)/10+10;
    ph_detector =strcat(num2str(ph_d),' mm');
    set(handles.ph_detector_text,'String',ph_detector)
    set(handles.ph_detector,'value',ph_d)
elseif strcmp(slider,'angle') || strcmp(slider,'angle_text')
    if strcmp(slider,'angle')
        angle = round(get(hObject, 'Value')*100)/100;
    else
        angle = round(str2double(get(hObject, 'string'))*100)/100;
        if isnan(angle)
            angle=0;
        elseif angle >double(get(handles.angle,'Max'))
            angle=double(get(handles.angle,'Max'));
        elseif angle <double(get(handles.angle,'Min'))
            angle=double(get(handles.angle,'Min'));
        end
    end
    set(handles.angle_text,'Value',angle)
    set(handles.angle_text,'String',num2str(angle))
    set(handles.angle,'value',angle)
elseif strcmp(slider,'eoffset') || strcmp(slider,'eoffset_text')
    if strcmp(slider,'eoffset')
        eoffset = round(get(hObject, 'Value')*10)/10;
    else
        eoffset = round(str2double(get(hObject, 'string'))*10)/10;
        if isnan(eoffset)
            eoffset=0;
        elseif eoffset >double(get(handles.eoffset,'Max'))
            eoffset=double(get(handles.eoffset,'Max'));
        elseif eoffset <double(get(handles.eoffset,'Min'))
            eoffset=double(get(handles.eoffset,'Min'));
        end
    end
    set(handles.eoffset_text,'Value',eoffset)
    set(handles.eoffset_text,'String',num2str(eoffset))
    set(handles.eoffset,'value',eoffset)
end

if get(handles.plotcheck,'value')==1 % starts plotting
    Efield = round(get(handles.efield, 'Value')*10)/10;
    edistance=get(handles.edistance,'value')/1E3;
    E=Efield*1E3/edistance;
    B=get(handles.bfield, 'value');
    lB=get(handles.bfieldlength, 'value')/1E3;
    lE=get(handles.efieldlength, 'value')/1E3;
    D=get(handles.drift, 'value')/1E3;
    alpha=get(handles.angle,'value');
    spot=get(handles.width,'value')/1e3;
    alpha=alpha/360*2*pi;

    delete(simu(ishandle(simu)))
    if ishandle(over)
        delete(over)
        hold on
        over=plot(0,0);
        hold off
    end
    
    hold all
    if isappdata(handles.main,'M')==0;
        incx=25; %in microns
    end 
    
    index=0;
    for number=1:length(a_i(:,1)) %for multiple traces
        index=index+1;
        a=a_i(number,2);
        A=a_i(number,1);
        relsol=get(handles.relsol,'value');
        if relsol==0
            trace=tracer(E,lE,B,lB,D,a,A); %retrieve trace for current parameters
        else
            trace=tracer_rk(E,lE,B,lB,D,a,A); %retrieve trace for current parameters using relativistic solver
        end
        xtrace=trace(:,2);
        ytrace=trace(:,3);
        Energy=trace(:,1);
   
        nans=find(isnan(xtrace)); %remove nan-entries
        if isempty(nans)==0
            xtrace=xtrace(length(nans)+1:length(xtrace));
            ytrace=ytrace(length(nans)+1:length(ytrace));
            Energy=Energy(length(nans)+1:length(Energy));
        end

        xi=round(min(xtrace)):incx*1E-3:round(max(xtrace)); %convert to figure dimensions
        Ei = interp1(xtrace,Energy,xi);
        yi = interp1(xtrace,ytrace,xi);
        xi=xi+xoffset;
        yi=yi+yoffset;
        beta=atan((yi-yoffset)./(xi-xoffset)); %rotate calculated trace
        z=sqrt((xi-xoffset).^2+(yi-yoffset).^2);
        xi=(cos(alpha+beta).*z)+xoffset;
        yi=(sin(alpha+beta).*z)+yoffset;
        simu(index*3-2)=plot(handles.main,xi,yi,'k','Linewidth',2); %plot main trace
        simu(index*3-1)=plot(handles.main,xi,yi+spot/2,'k','Linewidth',2); %plot upper trace
        simu(index*3)=plot(handles.main,xi,yi-spot/2,'k','Linewidth',2); %plot lower trace

        delete(zero(ishandle(zero)))
        lims=axis;
        x=0.9*xoffset:1:lims(1,2)*0.95; %plot origin
        zero(1)=plot(x,tan(alpha)*x+yoffset-tan(alpha)*xoffset,'-k','Linewidth',2);
        dy_u=0.98*lims(1,4)-yoffset;
        dy_b=yoffset-1.05*lims(1,3);
        ylimit_u=tan(alpha)*dy_u;
        ylimit_b=tan(alpha)*dy_b;
        if alpha>0
            y=xoffset-ylimit_u:(ylimit_b+ylimit_u)/10:xoffset+ylimit_b;
        elseif alpha<0
            y=xoffset+ylimit_u:(ylimit_b+ylimit_u)/-10:xoffset-ylimit_b;
        else
            y=xoffset;
        end
        zero(2)=plot(y,-tan(0.5*pi-alpha)*y+yoffset+tan(0.5*pi-alpha)*xoffset,'-k','Linewidth',2);
        zero(3)=plot(xoffset,yoffset,'o','Linewidth',3);
        %90° only visible if axis equal!
        if length(a_i(:,1))==1
            [value,index10]=min(sqrt((Ei-10e6).^2));
            if a_i(1,1)==1
                [value,index25]=min(sqrt((Ei-25e6).^2));
            end
            [value,index50]=min(sqrt((Ei-50e6).^2));
            [value,index100]=min(sqrt((Ei-100e6).^2));
            if a_i(1,1)>1
                [value,index250]=min(sqrt((Ei-250e6).^2));
                [value,index500]=min(sqrt((Ei-500e6).^2));
            end
            ind=3+1;
            zero(ind)=text(xi(index10),yoffset-.5,'10','color','w','fontsize',18);
            ind=ind+1;
            zero(ind)=plot(xi(index10),yoffset,'o','linewidth',3,'color','w');
            if a_i(1,1)==1
                ind=ind+1;
                zero(ind)=text(xi(index25),yoffset-.5,'25','color','w','fontsize',18);
                ind=ind+1;
                zero(ind)=plot(xi(index25),yoffset,'o','linewidth',3,'color','w');
            end
            ind=ind+1;
            zero(ind)=text(xi(index50),yoffset-.5,'50','color','w','fontsize',18);
            ind=ind+1;
            zero(ind)=plot(xi(index50),yoffset,'o','linewidth',3,'color','w');
            ind=ind+1;
            zero(ind)=text(xi(index100),yoffset-.5,'100','color','w','fontsize',18);
            ind=ind+1;
            zero(ind)=plot(xi(index100),yoffset,'o','linewidth',3,'color','w');
            if a_i(1,1)>1
                zero(ind+1)=text(xi(index250),yoffset-.5,'250','color','w','fontsize',18);
                zero(ind+2)=plot(xi(index250),yoffset,'o','linewidth',3,'color','w');
                zero(ind+3)=text(xi(index500),yoffset-.5,'500','color','w','fontsize',18);
                zero(ind+4)=plot(xi(index500),yoffset,'o','linewidth',3,'color','w');
            end
        end
    end
end
%ax(1)=gca;
%ax(2)=axes('Position',get(ax(1),'Position'),'XAxisLocation','Top','YAxislocation','Right','YTick',[]);
%linkaxes(ax,'x')
%set(ax(2),'XTickLabel',Ei/1e6)
%axes(ax(1));
hold off
%axis([0 200 0 20])
lB=get(handles.bfieldlength, 'value');
D=get(handles.drift, 'value');
set(handles.ph_detector,'value',D+lB+10)
set(handles.ph_detector_text,'string',[num2str(D+lB+10),' mm'])
set(hObject, 'Enable', 'on');

function efield_CreateFcn(hObject, eventdata, handles)

function ph_detector_Callback(hObject, eventdata, handles)
global incx
set(hObject, 'Enable', 'off'); 
pause(0.001)
slider=num2str(get(hObject,'Tag'));
if strcmp(slider,'ph_detector')
    ph_d = round(get(hObject, 'Value'));
    ph_detector =strcat(num2str(ph_d),' mm');
    set(handles.ph_detector_text,'String',ph_detector)
    set(handles.ph_detector,'value',ph_d)
elseif strcmp(slider,'phdiameter')
    diam = round(get(hObject, 'Value'));
    diameter =strcat(num2str(diam),' um');
    set(handles.phdiameter_text,'String',diameter)
    set(handles.phdiameter,'value',diam)
elseif strcmp(slider,'targetPH')
    t_ph = round(get(hObject, 'Value'));
    target_ph =strcat(num2str(t_ph),' mm');
    set(handles.targetph_text,'String',target_ph)
    set(handles.targetPH,'value',t_ph)
end

ph_d = round(get(handles.ph_detector, 'Value'));
diam=get(handles.phdiameter,'value');
t_ph=get(handles.targetPH,'value');

spotsize=round((ph_d+t_ph)/t_ph*diam); %spotsize in um
set(handles.spot,'string',spotsize);
set(handles.width,'value',spotsize);
spot =strcat(num2str(spotsize));
set(handles.width_text,'string',[spot,'um /',num2str(round(spotsize/incx)),'pixel']);
bin=round(spotsize/(incx));
set(handles.spotpx,'string',num2str(bin));
msr=(diam*1e-3/2)^2*pi/t_ph^2*1E3; %steradians in msr
set(handles.solid_angle,'string',[num2str(msr, '%10.2e\n'),' msr']);
set(handles.hbin,'value',spotsize);
set(handles.hbin_text,'string',[num2str(spotsize), 'um / ',num2str(round(spotsize/incx)),'pixel']);
set(hObject, 'Enable', 'on'); 

function ph_detector_CreateFcn(hObject, eventdata, handles)

function width_Callback(hObject, eventdata, handles)
global incx
width = round(get(hObject, 'Value'));
linewidth=strcat(num2str(width));
set(handles.width,'value',width);
set(handles.width_text,'string',[num2str(linewidth), 'um / ',num2str(round(width/incx)),'pixel']);
function width_CreateFcn(hObject, eventdata, handles)

function hbin_Callback(hObject, eventdata, handles)
global incx
hbin=round(get(hObject,'value'));
set(handles.hbin,'value',hbin);
set(handles.hbin_text,'string',[num2str(hbin), 'um / ',num2str(round(hbin/incx)),'pixel']);

function hbin_CreateFcn(hObject, eventdata, handles)

function ion_Callback(hObject, eventdata, handles)
global a_i %[ion mass in mp, ion charge in e-]
str = get(hObject, 'String');
val = get(hObject,'Value');

try
    load user.mat
    str(2)={list};
    set(hObject, 'String',str);
end
custom_str=str(2);
datacursormode off

switch str{val};
    case 'Select species'
        h=select_s;
        uiwait(h)
        try
        load user.mat
        str(2)={list};
        set(hObject, 'String',str);
        end
        set(hObject,'Value',2)
    case custom_str
        try
        load user.mat
        set(handles.charge,'Value',1)
        set(handles.charge,'String','mixed');
        set(handles.charge, 'Enable', 'off');
        catch
            global a_i
            a_i=[1,1;12,6;12,5];
        end
    otherwise
        p=load('periodic.mat','-mat','periodic');
        ion=val-2; %mass number
        mass=p.periodic(ion,2);
        charge=p.periodic(ion,1);
        for cs=1:charge
            chargestates{cs}=[num2str(cs),'+'];
        end
        set(handles.charge,'Value',charge)
        set(handles.charge,'String',chargestates);
        if ion==1
            set(handles.isotope,'String',{p.periodic(ion,2),p.periodic(ion,2)+1,p.periodic(ion,2)+2});
            isoval=get(handles.isotope,'Value');
            isomass=str2double(get(handles.isotope,'String'));
            isomass=isomass(isoval);
            a_i=[isomass,charge];
        else
            set(handles.isotope,'value',1);
            set(handles.isotope,'String',{p.periodic(ion,2)});
            a_i=[mass,charge];
        end
        set(handles.charge, 'Enable', 'on');
end
efield_Callback(hObject,eventdata, handles)


function ion_CreateFcn(hObject, eventdata, handles)

% --- Executes on selection change in charge.
function charge_Callback(hObject, eventdata, handles)
str = get(hObject, 'String');
val = get(hObject,'Value');
datacursormode off
global a_i
a_i(1,2)=val;
efield_Callback(hObject,eventdata, handles)


function charge_CreateFcn(hObject, eventdata, handles)

% --- Executes on selection change in isotope.
function isotope_Callback(hObject, eventdata, handles)
M = get(hObject, 'String');
val = get(hObject,'Value');
M= str2double(M{val})
datacursormode off
global a_i
a_i(1,1)=M;
efield_Callback(hObject,eventdata, handles)

function isotope_CreateFcn(hObject, eventdata, handles)


function spectr_Callback(hObject, eventdata, handles)
global imlength incx incy a_i Ei xi yi pname fname spectrum checktr linesub linehight
set(hObject, 'Enable', 'off');
set(handles.Maingui,'Pointer','watch')
pause(0.1)
A=a_i(1,1);
a=a_i(1,2);
xoffset=get(handles.xoffset,'value');
yoffset=get(handles.yoffset,'value');
spot=str2double(get(handles.spot,'string'))*1E-3; %x-binning in mm
width=double(get(handles.width,'value'))*1E-3;    %linewitdh in mm
bin=round(get(handles.hbin,'value')/incx);
diam=get(handles.phdiameter,'value')*1E-6;
t_ph=get(handles.targetPH,'value')*1E-3;
cut=str2double(get(handles.cutoff,'string'));

cmin=get(handles.cmin,'Value');
cmax=get(handles.cmax,'value');

if isappdata(handles.main,'M')==0
    errordlg('Load image first','Error');
elseif isempty(xi)==1
    errordlg('Find appropriate TP values first','Error');
elseif isempty(xi)==0
    Matrix=getappdata(handles.main,'M');
    save ('dataspec','xi','yi','Ei','width','incx','incy','Matrix','spot','checktr','cut','cmin','cmax','bin');
    spectrum=spectr(1);
    msr=(diam/2)^2*pi/t_ph^2*1E3; %steradians in msr
    spectrum(:,2)=spectrum(:,2)./msr; 
    figure
    semilogy(spectrum(:,1),(spectrum(:,2)),'Linewidth',2,'color','r')
    axis([0.9*min(spectrum(:,1)) cut*1.1 0.8*(min(spectrum(:,2))) 1.2*(max(spectrum(:,2)))])
    xlabel('Energy (MeV)');
    ylabel('Counts/MeV/msr');
    if A==1
        t=strcat(fname,' Proton Spectrum');
    else
        t=strcat(fname, ' C', num2str(a),'+',' Spectrum');
    end
    T=title(t);
    set(T,'interpreter','none')
    spec(:,1)=spectrum(:,1);
    spec(:,2)=spectrum(:,2);
    legend('Data')
    width
    if linesub==1 % activates second plot window if linesub is on
        spec(:,5)=spectrum(:,3);    %counts per bin from data
        spec(:,6)=spectrum(:,4);    %delta E of bin from data
        yiback=yi+linehight*width/2; %in pixel?
        save ('dataspec','xi','yiback','Ei','width','incx','incy','Matrix', 'spot','checktr','cut','cmin','cmax','bin');
        helloworld=1;
        background=spectr(helloworld); %run spectr to calculate background
        hold on
        background(:,2)=background(:,2)./msr;
        semilogy(background(:,1),(background(:,2)),'Linewidth',2);
        axis([0.9*min(spectrum(:,1)) cut*1.1 0.8*(min(background(:,2))) 1.2*(max(spectrum(:,2)))]);
        xlabel('Energy (MeV)');
        ylabel('Counts/MeV/msr');
        t=strcat(fname,' Background & Signal');
        T=title(t);
        set(T,'interpreter','none')
        legend('Data','Background')
        hold off
        
        figure %second data window
        spectrum_clean(:,1)=spectrum(:,2)-background(:,2);
        for clean=1:length(spectrum_clean(:,1))
            if spectrum_clean(clean)<=0
                spectrum_clean(clean)=1;
            end
        end
        semilogy(spectrum(:,1),(spectrum_clean(:,1)),'color','r','Linewidth',2);  %plot cleaned spectrum
        xlabel('Energy (MeV)');
        ylabel('Counts/MeV/msr');
        t=strcat(fname); %,' Cleaned Signal');
        hold off
        spec(:,3)=background(:,2);
        spec(:,4)=spectrum_clean(:,1);
        spec(:,5)=spec(:,5)-background(:,3);    %counts per bin from data - counts from background

        %calculate resolution and save it in spectrum file
        edistance=get(handles.edistance,'value')/1E3;
        E=get(handles.efield,'value')*1E3/edistance;
        B=get(handles.bfield, 'value');
        lB=get(handles.bfieldlength, 'value')/1E3;
        lE=get(handles.efieldlength, 'value')/1E3;
        D=get(handles.drift, 'value')/1E3;

        Res1=resolution(E,lE,B,lB,D,a,A,spot);
 
        spec(:,7) = interp1(Res1(:,1),Res1(:,3),spectrum(:,1)); %- error in MeV
        spec(:,8) = interp1(Res1(:,1),Res1(:,4),spectrum(:,1)); %+ error in MeV
        
        J=0; %calculate energy in J catched by TP
        for a=1:length(spec(:,1))
            J=J+spec(a,5)*spec(a,1)*1e6*1.6022e-19;
        end
        hold on
        type=fname(length(fname)-2:length(fname));
        if strcmp(type,'img')
            inffile=[pname, fname(1:length(fname)-3),'inf'];
            fid=textread(inffile,'%s');
            incx=str2double(fid(3));
            incy=str2double(fid(4));
            depth=str2double(fid(5));
            m = str2double(fid(6));
            n = str2double(fid(7));
            S = str2double(fid(8));
            L = str2double(fid(9));
            mindata=(incx./100).^2.*4000./S.*10.^(L.*(0./2^(depth)-0.5));
            mindata_1=(incx./100).^2.*4000./S.*10.^(L.*(1./2^(depth)-0.5))-mindata;
        else
            mindata=1;
            mindata_1=1;
        end
        plot(spectrum(:,1),mindata*spectrum(:,5)/msr,'x','color','g') %plot detection limit as 1/(msr*deltaE_MeV), where deltaE is the energy width of the binning
        plot(spectrum(:,1),spectrum(:,1)*0+mindata/msr,'color','y') %plot detection limit as 1/(msr*MeV)
        plot(spectrum(:,1),(background(:,3)+mindata_1).*spectrum(:,5)./msr,'color','b') %plot detection limit as (Background+1)/(msr*MeV)
        plot(spectrum(:,1),spectrum(:,2),'--','color','m') %raw spectrum #/(msr*MeV)
        plot(spectrum(:,1),spectrum(:,2)./((background(:,3)+mindata_1).*spectrum(:,5)./msr),'color','black'); %signal to noise ratio
       
        hold off
        Ecut=min(spectrum(:,1)):.01:max(spectrum(:,1)); %find intersection between data and (Background+1)/(msr*MeV)
        Ci = interp1(spectrum(:,1),spectrum(:,2),Ecut); 
        Bi = interp1(background(:,1),(background(:,3)+mindata_1).*spectrum(:,5)./msr,Ecut);
        
        under=Ci-Bi; 
        negative=0;
        E_last=0;    
        for a=2:length(under)
            if Ci(a)/Bi(a)<1.01%under(a)<0
                if negative==0
                    if (Ecut(a)+Ecut(a-1))/2-E_last>2
                        yy=(spectrum_clean(:,1)):(Ci(a)+Ci(a-1))/2/10:(Ci(a)+Ci(a-1))/2;
                        hold on
                        plot((Ecut(a)+Ecut(a-1))/2,(Ci(a)+Ci(a-1))/2,'o','linewidth',3,'color','m')
                        plot((Ecut(a)+Ecut(a-1))/2+yy*0,yy,'--','color','m')
                        text((Ecut(a)+Ecut(a-1))/2*1.05,(Ci(a)+Ci(a-1))/2*5,[num2str(round((Ecut(a)+Ecut(a-1))/2*10)/10),'MeV'],'color','m')
                        hold off
                        E_last=(Ecut(a)+Ecut(a-1))/2;
                    end
                    negative=1;
                end
            else
                if negative==1
                    if (Ecut(a)+Ecut(a-1))/2-E_last>2
                        hold on
                        plot((Ecut(a)+Ecut(a-1))/2,(Ci(a)+Ci(a-1))/2,'o','linewidth',3,'color','m') 
                        text((Ecut(a)+Ecut(a-1))/2*1.05,(Ci(a)+Ci(a-1))/2*5,[num2str(round((Ecut(a)+Ecut(a-1))/2*10)/10),'MeV'],'color','m')
                        hold off
                    end
                    E_last=(Ecut(a)+Ecut(a-1))/2;
                end  
                negative=0;
            end
        end                             

        Joules=[num2str(J),'J'];
        Numbers=num2str(round(sum(spec(:,5))));
        string=[' @ ', Numbers,' particles at a total of ', Joules];
        axis([0.9*min(spectrum(:,1)) cut*1.1 0.5*(min(spectrum(:,2))) 1.2*(max(spectrum(:,2)))]);
        legend('Cleaned Spectrum','1#/(deltaE*msr)','1#/(MeV*msr)','(Background+1#)/(MeV*msr)','Raw spectrum','Signal to noise ratio')
        t=[t,string];
        T=title(t);
        set(T,'interpreter','none')
    end
end
        
save('specles.txt','spec','-ascii')
    

set(hObject, 'Enable', 'on');
set(handles.Maingui,'Pointer','arrow')

function save_Callback(hObject, eventdata, handles)
global Ei xi yi a_i
set(hObject, 'Enable', 'off'); 
pause(0.1)
if isempty(Ei)
    set(hObject, 'Enable', 'on'); 
    errordlg('There is no simulated trace','Error');
    return
end
E=num2str(round(get(handles.efield,'value')*10)/10);
B=num2str(round((get(handles.bfield, 'value'))*100)/100);
D=num2str(round(get(handles.drift, 'value')));
xoffset=get(handles.xoffset,'value');
yoffset=get(handles.yoffset,'value');

line(:,1)=Ei';
line(:,2)=xi-xoffset';
line(:,3)=yi-yoffset';

A=a_i(1,1);
a=a_i(1,2);

if A==1
	filestring=strcat('H+_trace_',B,'T_',E,'kV_',D,'mm_drift','.txt')
elseif round(A)==12
	filestring=strcat('C',num2str(a),'+_trace_',B,'T_',E,'kV_',D,'mm_drift','.txt')
elseif round(A)==16
	filestring=strcat('O',num2str(a),'+_trace_',B,'T_',E,'kV_',D,'mm_drift','.txt')
end
[file,path] = uiputfile(filestring,'Save simulated spectrum to file')
if file==0
else
    filepath=[path,file];
    save(filepath,'line','-ascii');
end
set(hObject, 'Enable', 'on'); 

function cmax_Callback(hObject, eventdata, handles)
cmax=round(get(hObject, 'Value'));
cmin=get(handles.cmin,'value');
if cmax<cmin
    set(handles.cmax,'string',num2str(cmax));
    set(handles.cmax_text,'string',num2str(cmax),'foregroundcolor','r');
else
    set(handles.cmax,'string',num2str(cmax));
    set(handles.cmax_text,'string',num2str(cmax),'foregroundcolor',[0 0 0]);
    caxis([cmin cmax]);
end

function cmax_CreateFcn(hObject, eventdata, handles)

function caxismax1_Callback(hObject, eventdata, handles)
cmax=round(get(hObject, 'Value')*1000)/1000;
cmin=get(handles.cmin,'value');
if cmax<cmin
    set(handles.cmax,'string',num2str(cmax));
    set(handles.cmax_text,'string',num2str(cmax),'foregroundcolor','r');
else
    set(handles.cmax,'string',num2str(cmax));
    set(handles.cmax_text,'string',num2str(cmax),'foregroundcolor',[0 0 0]);
    caxis([cmin cmax]);
end

function caxismax1_CreateFcn(hObject, eventdata, handles)

function cmin_Callback(hObject, eventdata, handles)
cmin = round(get(hObject, 'Value')*1000)/1000;
cmax=str2double(get(handles.cmax_text,'string'));
if cmax<cmin
    set(handles.cmin,'string',num2str(cmin));
    set(handles.cmin_text,'string',num2str(cmin),'foregroundcolor','r');
else   
    set(handles.cmin,'string',num2str(cmin));
    set(handles.cmin_text,'string',num2str(cmin),'foregroundcolor',[0 0 0]);
    caxis([cmin cmax]);
end

function cmin_CreateFcn(hObject, eventdata, handles)

function plotcheck_Callback(hObject, eventdata, handles)
global check
check=get(hObject,'Value');

function reso_Callback(hObject, eventdata, handles)
global a_i
set(hObject, 'Enable', 'off'); 
pause(0.001)
A=a_i(1,1);
a=a_i(1,2);
edistance=get(handles.edistance,'value')/1E3;
E=get(handles.efield,'value')*1E3/edistance;
B=get(handles.bfield, 'value');
lB=get(handles.bfieldlength, 'value')/1E3;
lE=get(handles.efieldlength, 'value')/1E3;
D=get(handles.drift, 'value')/1E3;
spot=str2double(get(handles.spot,'string'))*1E-3;
if isnan(spot)
else
    relsol=get(handles.relsol,'Value');
    if relsol==0
        Res1=resolution(E,lE,B,lB,D,a,A,spot,'classic');
        %Res2=resolution(E,lE,B,lB,D,a,A,spot,'relativistic');
    else
        Res1=resolution(E,lE,B,lB,D,a,A,spot,'relativistic');
    end

%e=1.60E-19;     %[C] electron charge
%mp=1.67E-27;     %[kg] nucleon mass (proton mass)
%q=a*e;
%m=A*mp;
%iE=1e6:1e6:900e6;
%Ek=iE*1e-6;
%s=spot*1e-3;
%x=(q*B*lB*D)./sqrt(2*m.*Ek.*e.*1e6);
%y=2.*x.^3.*s./(x.^2-(s./2).^2).^2;
%y1=2.*s./(x.*(1-(s./2./x).^2).^2);

figure
plot(Res1(:,1)/A,Res1(:,2),'color','r')
%hold on
%plot(Ek,y,'color','b')
%plot(Ek,y1,'x','color','g')
%hold off
ylabel('\Delta E/E')
xlabel('Energy (MeV/u)')
title('Resolution')
prompt = {'Enter file name'};
dlg_title = 'Save resolition to txt-file?';
num_lines = 1;
def = {'TP_Resolution'};
answer = inputdlg(prompt,dlg_title,num_lines,def);
if isempty(answer)
else
    dE(:,1)=[1:59/2:60,120:60:round(max(Res1(:,1)))];
    dE(:,2)=interp1(Res1(:,1),Res1(:,2),dE(:,1));
    %save([char(answer),'.txt'],'Res1','-ascii')
    save([char(answer),'.txt'],'dE','-ascii')
end
end
set(hObject, 'Enable', 'on'); 

function savespec_Callback(hObject, eventdata, handles)
global pname fname a_i
set(hObject, 'Enable', 'off'); 
pause(0.1)

species=get(handles.ion,'string');
value=get(handles.ion,'value');
species=cell2mat(species(value));
species=species(1:1);
if isappdata(handles.main,'M')==0
    errordlg('Load image first','Error');
else
    spec=load('specles.txt');
    A=a_i(1,1);
    a=a_i(1,2);
    if A==2 && a==1
        species='Dt';
    elseif A==3 & a==1
        species='Tr';
    end
    xoffset=get(handles.xoffset,'value');
    yoffset=get(handles.yoffset,'value');
    B=num2str(round((get(handles.bfield, 'value'))*100)/100);
    
    file=strcat(pname,fname, '_',species , num2str(a),'+_',B,'T','.txt')
    par =strcat(pname,fname, '_',species , num2str(a),'+_',B,'T','_par.txt');
    
    save(file,'spec','-ascii');
    datei(1)=get(handles.bfield,'value');
    datei(2)=get(handles.bfieldlength,'value');
    datei(3)=get(handles.efield,'value');
    datei(4)=get(handles.efieldlength,'value');
    datei(5)=get(handles.edistance,'value');
    datei(6)=get(handles.drift,'value');
    datei(7)=get(handles.phdiameter,'value');
    datei(8)=get(handles.ph_detector,'value');
    datei(9)=get(handles.angle,'value');
    datei(10)=xoffset;
    datei(11)=yoffset;
    datei(12)=get(handles.targetPH,'value');
    
    datei=datei';    
    save(par,'datei','-ascii');
end
set(hObject, 'Enable', 'on'); 

function checktr_Callback(hObject, eventdata, handles)
global checktr
checktr=get(hObject,'Value');

function cutoff_Callback(hObject, eventdata, handles)

function cutoff_CreateFcn(hObject, eventdata, handles)

function tptype_Callback(hObject, eventdata, handles)
datacursormode off
global zero xlength ylength TP pname simu incx
str = get(hObject, 'String');
val = get(hObject,'Value');

switch str{val};
    case 'Update List'
        if exist('TP_settings','dir')
            settings=dir('TP_settings/*_par.txt');
            settings=struct2cell(settings);
            [ycell,xcell]=size(settings);
            if xcell==0
                ncll=0;
                TP='List not updated';
                errordlg('No TP-Setting files found!','Ooops');
            else
                for ncll=1:xcell
                    entry=cell2mat(settings(1,ncll));
                    strnew{ncll}=entry(1:length(entry)-8);
                end
                TP='List updated';
            end
        else
            ncll=0;
            TP='List not updated';
            errordlg('No TP-Setting files found!','Ooops');
        end
        strnew{ncll+1}='Custom';
        strnew{ncll+2}='Update List';
        set(hObject,'Value',ncll+2)
        set(hObject,'String',strnew);
        
    case 'Custom'
        if exist('pname','var')
                [file,path]=uigetfile({'*_par.txt','TP Parameter File (*_par.txt)'},'Load reference',pname);
        else
                [file,path]=uigetfile({'*_par.txt','TP Parameter File (*_par.txt)'},'Load reference');
        end
        
        if file==0
            return
        end
  
        par=strcat(path,file);
        TP=num2str(file(1:length(file)-8));
        
    otherwise
        TP=str{val};
        file=[TP,'_par.txt'];
        par=strcat('TP_settings/',file);

end
set(handles.type,'string',num2str(TP),'Foregroundcolor','r')
if strcmp(str{val},'Update List')
    return
end
datei=load(par);

set(handles.efield_text,'String',strcat(num2str(datei(3))))
set(handles.efield,'value',datei(3))
set(handles.bfield_text,'String',strcat(num2str(datei(1))))
set(handles.bfield,'value',datei(1))
set(handles.efieldlength_text,'String',strcat(num2str(datei(4))))
set(handles.efieldlength,'value',datei(4))
set(handles.edistance_text,'String',strcat(num2str(datei(5))))
set(handles.edistance,'value',datei(5))
set(handles.bfieldlength_text,'String',strcat(num2str(datei(2))))
set(handles.bfieldlength,'value',datei(2))
set(handles.drift_text,'String',strcat(num2str(round(datei(6)))))
set(handles.drift,'value',datei(6))
set(handles.phdiameter_text,'String',strcat(num2str(datei(7))))
set(handles.phdiameter,'value',datei(7))
set(handles.ph_detector_text,'String',strcat(num2str(datei(8))))
set(handles.ph_detector,'value',datei(8))
set(handles.angle_text,'String',strcat(num2str(datei(9))))
set(handles.angle,'value',datei(9))  
       
% Construct a questdlg for adding offsets
choice = questdlg('Replace offset:', ...
'Load offset from file?','Yes','No','No');
% Handle response
switch choice
	case 'Yes'
        xoffset=round(datei(10)*100)/100;
        x =strcat(num2str(xoffset),' mm');
        yoffset=round(datei(11)*100)/100;
        y =strcat(num2str(yoffset),' mm');
        set(handles.xoffset,'String',x)
        set(handles.yoffset,'String',y)
        set(handles.xoffset,'value',xoffset);
        set(handles.yoffset,'value',yoffset);
    case 'No'
        xoffset=get(handles.xoffset,'value');
        yoffset=get(handles.yoffset,'value');
end

if length(datei)<12
	datei(12)=1250;
end

set(handles.targetPH,'value',datei(12))
set(handles.targetph_text,'String',strcat(num2str(datei(12)),' mm'))
        
spotsize=round((datei(8)+datei(12))/datei(12)*datei(7)); %spotsize in um
set(handles.width,'value',spotsize);
set(handles.hbin,'value',spotsize);
if incx<1
	incx=1;
end
set(handles.width_text,'string',[num2str(spotsize), 'um / ',num2str(round(spotsize/incx)),'pixel']);
set(handles.spotpx,'string',num2str(round(spotsize/incx)));
set(handles.hbin_text,'string',[num2str(spotsize), 'um / ',num2str(round(spotsize/incx)),'pixel']);
set(handles.spot,'string',spotsize);
msr=(datei(7)*1e-6/2)^2*pi/(datei(12)*1e-3)^2*1E3; %steradians in msr
set(handles.solid_angle,'string',[num2str(msr, '%10.2e\n'),' msr']);
      

efield_Callback(hObject, eventdata, handles)

delete(zero(ishandle(zero)))
%delete(simu(ishandle(simu)))
        
if isempty(xlength)
	xlength=100;
    ylength=100;
end
x=1:max(xlength);
y=1:max(ylength);
hold on
alpha=datei(9)/360*2*pi;
zero(1)=plot (xoffset+0*y,y,'-k','Linewidth',2);
zero(2)=plot (x,sin(alpha)*x+yoffset-sin(alpha)*xoffset,'-k','Linewidth',2);
hold off

function tptype_CreateFcn(hObject, eventdata, handles)

function overlap_Callback(hObject, eventdata, handles)
global over simu
set(hObject, 'Enable', 'off'); 
pause(0.1)
if ishandle(simu)~=0
    xoffset=get(handles.xoffset,'value');
    yoffset=get(handles.yoffset,'value');
    edistance=get(handles.edistance,'value')/1E3;
    E=get(handles.efield,'value')*1E3/edistance;
    B=get(handles.bfield, 'value');
    lB=get(handles.bfieldlength, 'value')/1E3;
    lE=get(handles.efieldlength, 'value')/1E3;
    D=get(handles.drift, 'value')/1E3;
    alpha=get(handles.angle,'value');

    spot=str2double(get(handles.spot,'string'))*1E-3; %x-binning in mm
    relsol=get(handles.relsol,'value');
    
    R_Al11_Al12=(12/27+11/27)/(12/27-11/27);
    R_Al11_Al13=(13/27+11/27)/(13/27-11/27);
    
    E_11_12=11*E*lE*(D+0.5*lE)/(spot*1e-3*R_Al11_Al12)
    E_11_13=11*E*lE*(D+0.5*lE)/(spot*1e-3*R_Al11_Al13)
    
    if relsol==0
        overlap=overlapping(B,E,lE,lB,D,spot);
    else
        overlap=overlapping(B,E,lE,lB,D,spot,'relativistic');
    end

    
    
    hold all
    axes(handles.main);

    lims=axis;
    rate=(lims(1,4)-lims(1,3))/10;
    y=lims(1,3):rate:.9*lims(1,4);

    delete(over(ishandle(over)))
    over(1)=plot(overlap(1)+xoffset+0*y,y,'color','r','linewidth',3);
    C5C6=['\leftarrow C5+ (', num2str(round(overlap(6))),'MeV) overlapping C6+ (', num2str(round(overlap(2))), 'MeV)'];
    over(2)=text(overlap(1)+xoffset,.9*lims(1,4), C5C6,'FontSize',14,'color',[0 0 0]);
    over(3)=plot(overlap(3)+xoffset+0*y,y,'color','g','linewidth',3);
    pC6=['\leftarrow Proton (', num2str(round(overlap(5))), 'MeV) overlapping with C6+ (', num2str(round(overlap(4))), 'MeV)'];
    over(4)=text(overlap(3)+xoffset,.7*lims(1,4), pC6,'FontSize',14,'color',[0 0 0]);
    hold off
else
    errordlg('No trace to calculate overlap','Ooops');
end

set(hObject, 'Enable', 'on'); 

function linesub_Callback(hObject, eventdata, handles)
global linesub
linesub=get(hObject,'Value');

function linehight_Callback(hObject, eventdata, handles)
global linehight xi yi back a_i
button=get(hObject,'tag');
dm=size(a_i);
if dm(1,1)==1
    if strcmp(button,'linehight')
        linehight = 0.1*round(get(hObject, 'Value'));
        set(handles.linehight_text,'string',num2str(linehight))
        set(handles.linehight,'value',linehight*10);
    else
        linehight = round(str2double(get(hObject, 'string'))*10)/10;
        if isnan(linehight) || abs(linehight)>200
            linehight=0;
        end
        set(handles.linehight_text,'string',num2str(linehight))
        set(handles.linehight,'value',linehight*10);
    end
    delete(back(ishandle(back)))
    spot=get(handles.width,'value')/1e3;
    if length(xi)==length(yi)
        hold all
        back(1)=plot(xi,yi+(linehight+1)*spot/2,'k','Linewidth',2);
        back(2)=plot(xi,yi+(linehight-1)*spot/2,'k','Linewidth',2);
        hold off
    else
        errordlg('Something went wrong, please reset this awesome piece of software!','Ooops');
	return
    end
else
    errordlg('Please select a single ion species!','Error');
end

function linehight_CreateFcn(hObject, eventdata, handles)

function reset_Callback(hObject, eventdata, handles)
global xlength ylength fname simu zero back over Ei xi yi
datacursormode off
set(handles.Maingui,'Pointer','arrow')

if isappdata(handles.main,'M')
    Matrix=getappdata(handles.main,'M');    
    imagesc(xlength,ylength,Matrix)
    axis xy
    xlabel('B-field deflection (mm)')
    ylabel('E-field deflection (mm)')
    T=title(fname);
    set(T,'Interpreter','none')
    cmin=get(handles.cmin,'Value');
    cmax=str2double(get(handles.cmax_text,'string'));
    caxis([cmin cmax]);
    hold on
end
simu=plot(0,0);
zero=plot(0,0);
back=plot(0,0);
over=plot(0,0);
xi=0;
Ei=0;
yi=0;
hold off
set(handles.efield, 'Enable', 'on');
set(handles.efield_text, 'Enable', 'on');
set(handles.savespec, 'Enable', 'on');
set(handles.spectr, 'Enable', 'on');
set(handles.efieldlength, 'Enable', 'on');
set(handles.bfieldlength, 'Enable', 'on');
set(handles.bfield, 'Enable', 'on');
set(handles.edistance, 'Enable', 'on');
set(handles.angle, 'Enable', 'on');
set(handles.targetPH, 'Enable', 'on');
set(handles.phdiameter, 'Enable', 'on');
set(handles.reso, 'Enable', 'on');
set(handles.save, 'Enable', 'on');
set(handles.overlap, 'Enable', 'on');
set(handles.cvsr, 'Enable', 'on');
set(handles.savespec, 'Enable', 'on'); 
set(handles.ion, 'Enable', 'on'); 
guidata(hObject, handles);
clc;

function relsol_Callback(hObject, eventdata, handles)
relsol=get(hObject,'Value');
if relsol==1
    set(hObject,'foregroundcolor','r')
elseif relsol==0
    set(hObject,'foregroundcolor',[0 0 0])
end

function CRb_Callback(hObject, eventdata, handles)
srimcalc;
%[E_CR39_Alu, E_alu_end]=CR39srim;
%Message=['Ion has ', num2str(E_alu_end),'MeV after passing Alu and ' ,num2str(E_CR39_Alu),'MeV after passing CR39'];
%h = msgbox(Message,'Ion breakthrough');

function cvsr_Callback(hObject, eventdata, handles)
global a_i
set(hObject, 'Enable', 'off');
pause(0.1)
A=a_i(1,1);
a=a_i(1,2);
edistance=get(handles.edistance,'value')/1E3;
E=get(handles.efield,'value')*1E3/edistance;
B=get(handles.bfield, 'value');
lB=get(handles.bfieldlength, 'value')/1E3;
lE=get(handles.efieldlength, 'value')/1E3;
D=get(handles.drift, 'value')/1E3;

diff=compare_tracer(E,lE,B,lB,D,a,A);
figure
plot(diff(:,3)/1e6,diff(:,2)/1e6)
t='Comparison of classical and relativistic solver';
ylabel('Relativistic E - Classic E (MeV)');
xlabel('Energy (MeV)');
title(t)
if A==1
    ion='Proton';
elseif A==12
    ion=['Carbon C',num2str(a),'+'];
elseif A==16
    ion=['Oxygen O',num2str(a),'+'];
else
    ion='unknown ion';
end
legend(ion)
set(hObject, 'Enable', 'on');

% --- Executes when Maingui is resized.
function Maingui_ResizeFcn(hObject, eventdata, handles)

% --- Executes during object creation, after setting all properties.
function linehight_text_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
