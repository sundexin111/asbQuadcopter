function setGRTCodeGen()
% SETGRTCODEGENERATIONSETTINGS This function sets the appropriate settings
% for code generation for the controller. This is a private function, not
% meant to be used directly.

% Copyright 2017-2018 The MathWorks, Inc.

% Check if the flight control system model and its children are open
model = {'flightControlSystem','flightController','stateEstimator',...
    'conversionYUV'};

for k = 1:length(model)
    isFCSLoaded = bdIsLoaded(model{k});
    if ~isFCSLoaded
        load_system(model{k});
    end
    
    % Set the hardware target tool-chain
    set_param(model{k},...
        'HardwareBoard','None',...
        'SystemTargetFile','grt.tlc');

    % Set image processing settings - It only applies to the
    % flightControlSystem model
    if k==1
        set_param([model{k} '/Image Processing System'],'InitFcn','');
        set_param([model{k} '/Image Data'],'InitFcn','');
        lines = find_system(model{k},'SearchDepth','1','findall','on','Type','Line', 'Name', 'Y1UY2V');
        lineStruct = get(lines);
        line = get(lineStruct.Handle);
        line.CoderInfo.Alias = '';
        set(lineStruct.Handle, 'StorageClass', 'Auto');
    end
        
    % Only save if model is not opened, just in case there are unsaved changes
    if ~isFCSLoaded
        save_system(model{k});
        bdclose(model{k});
    end
end
