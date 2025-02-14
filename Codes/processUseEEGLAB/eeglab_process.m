% clc
% clear all

%{
    该文件用来对数据进行预处理
        - 加载数据到eeglab，其中包括电极位置信息，元数据，事件信息
        - 对数据进行滤波
        - ...未完待续
%}


% 加载subj1_raw_processed_s01、chanlocs、events_info并添加EMG通道标签

function eeglab_process(baseDataFolder)
    global runningFunction;
    eeglab;

    folders = dir(baseDataFolder);  % 获取当前目录下的所有文件和文件夹
    disp(folders)
    for j = 1:length(folders)
        % 跳过 . 和 .. 这两个特殊文件夹
        if strcmp(folders(j).name, '.') || strcmp(folders(j).name, '..')
            continue;
        end
        disp(class(folders(j).name))
        % if ~strcmp(folders(j).name, 'subj1')
        %     continue;
        % end
        
    
        % 拼接完整路径
        fullPath = fullfile(baseDataFolder, folders(j).name);
        % 判断是否是文件夹，并且文件夹名符合条件
        if folders(j).isdir && matches_subj_pattern(folders(j).name)
            fprintf('符合条件的文件夹：%s\n', fullPath);
            % 如果满足条件，对其子文件夹递归调用
            % traverse_folders(fullPath);
            originalDataFolders = fullfile(fullPath, "/filtered");
            % 获取文件夹中的所有文件和文件夹（包括隐藏文件）
            fileList = dir(originalDataFolders);
            
            % 排除 '.' 和 '..' 文件夹
            fileList = fileList(~ismember({fileList.name}, {'.', '..'}));
    
            for i = 1:length(fileList)
                if isempty(runningFunction) || ~strcmp(runningFunction.Name, "EEGLAB Preprocessing")
                    return;
                end
                fileName = fileList(i).name;  % 获取文件或文件夹的名字
                filepath = fullfile(originalDataFolders, fileName);  % 获取完整路径
                fprintf("当前处理的的文件是：%s\n",filepath);
                
                setname = extractBefore(fileName, "_raw_processed");
    
                flagFile = fullfile(fullPath, "set", "flags", [setname, '.mat']);
                disp(['flagFile: ' flagFile])
                stepFlags = get_flag_step(flagFile);
    
                if stepFlags.loadSet == false
                    % mannual interpolate electrodes
                    [EEG, stepFlags] = load_set(baseDataFolder, fullPath, filepath, fileName, flagFile, stepFlags);
                else
                    EEG = pop_loadset('filename', [setname '.set'], 'filepath', char(fullfile(fullPath, "set", "beforeInterp"))); 
                    disp("Set already Loaded.")
                end
                
                if isempty(runningFunction) || ~strcmp(runningFunction.Name, "EEGLAB Preprocessing")
                    return;
                end

                if stepFlags.interpolate == false
                    [EEG, stepFlags] = mannual_interp(EEG, flagFile, stepFlags);
                else
                    EEG = pop_loadset('filename', [setname '.set'], 'filepath', char(fullfile(fullPath, "set", "afterInterp"))); 
                    disp("Interpolation already done");
                end

                if isempty(runningFunction) || ~strcmp(runningFunction.Name, "EEGLAB Preprocessing")
                    return;
                end

                if stepFlags.runICA == false
                    [EEG, stepFlags] = run_ICA(EEG, fullPath, setname, flagFile, stepFlags);
                else
                    EEG = pop_loadset('filename', [setname '.set'], 'filepath', char(fullfile(fullPath, "set", "afterICA"))); 
                    disp("ICA already done");
                end

                if isempty(runningFunction) || ~strcmp(runningFunction.Name, "EEGLAB Preprocessing")
                    return;
                end
    
                if stepFlags.flagArtifacts == false
                    [EEG, stepFlags] = flag_artifacts(EEG, fullPath, setname, flagFile, stepFlags);
                else
                    EEG = pop_loadset('filename', [setname '.set'], 'filepath', char(fullfile(fullPath, "set", "afterArtifact"))); 
                    disp("Remove Artifacts already done");
                end
    
            end
        end
    end
end

  