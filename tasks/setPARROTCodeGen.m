function setPARROTCodeGen()
% SETPARROTCODEGEN This function sets the appropriate settings
% for code generation for the controller. This is a private function, not
% meant to be used directly.

% Copyright 2017-2018 The MathWorks, Inc.

% Check that the support package is installed
if isParrotSupportPkgInstalled
    % Check if the flight control system model and its children are open
    modelList = {'flightControlSystem','flightController','stateEstimator',...
        'conversionYUV'};
    
    for k = 1:length(modelList)
        isFCSLoaded = bdIsLoaded(modelList{k});
        if ~isFCSLoaded
            load_system(modelList{k});
        end

        % Set the hardware target toolchain
        switch evalin('base','model')
            case 'Mambo'
                set_param(modelList{k},'HardwareBoard','PARROT Mambo',...
                        'MatFileLogging','on');
            case 'RollingSpider'
                set_param(modelList{k},'HardwareBoard','PARROT Rolling Spider',...
                        'MatFileLogging','on');
        end
        
        % Set image processing settings - It only applies to the
        % flightControlSystem model
        if k==1
            set_param([modelList{k} '/Image Processing System'],'InitFcn',...
                'codertarget.parrot.internal.ipSubsystemCallback(gcb);');
            set_param([modelList{k} '/Image Data'],'InitFcn',...
                'codertarget.parrot.internal.inportCallback(gcb);');
            lines = find_system(modelList{k},'SearchDepth','1','findall','on','Type','Line','Name', 'Y1UY2V');
            lineStruct = get(lines);
            set(lineStruct.Handle, 'StorageClass', 'ImportedExternPointer');
            line = get(lineStruct.Handle);
            line.CoderInfo.Alias = 'imRGB';
        end

        % Only save if model is not opened, just in case there are unsaved changes
        if ~isFCSLoaded
            save_system(modelList{k});
            bdclose(modelList{k});
        end
    end 
else
    warning(message('aeroblks_demos_quad:asbquadcopter:supportPkgNotInstalled'));
end
