clc; clear all; clf; tic

% Choose file
[filename,PathName] = uigetfile('*.gcode','Select the G-CODE file');
FileName=strcat(PathName,filename)
% Import file
fid=fopen(FileName);
tline = fgetl(fid);

% Initialize Variables
layer=0;
ctr=1;
endFlag=0; %0=false, 1=true
xTemp=NaN;
yTemp=NaN;
zTemp=NaN;
eTemp=NaN;
X=NaN;
Y=NaN;
Z=NaN;
E=NaN;
endstr=';-- END GCODE --';
% Initialize view
hold all
camproj('perspective')

while ischar(tline)
    % Store line in variable Line
    Line=tline;
    
    % Failsafe #1. Check for END gcode.
    % Failsafe #2. Avoid comment line.
    if ~isempty(Line)
        if strcmp(Line,endstr)
            endFlag=1;
        end
        if strcmp(Line(1),';')
            tline = fgetl(fid);
            Line=tline;
        end
    end
    
    
    if ~endFlag
        for i=1:size(Line,2)
            % Check if the line contains Z value
            if strcmp(Line(i),'Z');
                token = strtok(Line(i+1:end));
                if size(token,2)+i==size(Line,2)
                    layer=layer+1;
                    zTemp=str2num(token);
                end
            end
        end
        if layer>1
            for i=1:size(Line,2)
                if strcmp(Line(i),'E');
                    % Update E,X,Y,Z
                    E(ctr)=eTemp;
%                     if ctr>1
%                     if E(ctr-1)<E(ctr)
                    X(ctr)=xTemp;
                    Y(ctr)=yTemp;
                    Z(ctr)=zTemp;
%                     subplot(1,2,1)
%                     view(3)
%                     axis equal
%                     hold on
%                     plot3(xTemp,yTemp,zTemp,'r+')
%                     if ctr>1
%                     plot3(X(ctr-1:ctr),Y(ctr-1:ctr),Z(ctr-1:ctr),'g')
%                     end
%                     drawnow
%                     pause(0.1)
%                     end
%                     end
                    ctr=ctr+1;
                    for j=1:size(Line,2)
                        if strcmp(Line(j),'E');
                            eTemp = str2num(strtok(Line(j+1:end)));
                        end
                        if strcmp(Line(j),'X');
                            xTemp = str2num(strtok(Line(j+1:end)));
                        end
                        if strcmp(Line(j),'Y');
                            yTemp = str2num(strtok(Line(j+1:end)));
                        end
                    end
                    break
                end
            end
        end
    end
    tline = fgetl(fid);
end
% subplot(1,2,2)
plot3(X,Y,Z,'b')
view(3)
axis equal
fclose(fid);
toc
clear xTemp yTemp zTemp eTemp token tline i j fid endstr endFlag ctr Line ans