function plot_cohere(baseDataFolder)

    inputFolder = fullfile(baseDataFolder, 'CMCresult_lowerLimb');
    outputFolder = fullfile(baseDataFolder, 'CMCplots_lowerLimb');
    eventTypes = {'a', 'b'}; % 事件类型
    
    % 遍历所有目录并筛选符合 subj 格式的文件夹，同时排除 '.' 和 '..'
    allFolders = dir(fullfile(inputFolder, '*'));
    allFolders = allFolders([allFolders.isdir]); % 确保是文件夹
    
    % 筛选符合规则的文件夹，排除 '.' 和 '..'
    subjectFolders = allFolders(~ismember({allFolders.name}, {'.', '..'})); 
    
    % 如果需要筛选符合 subj 格式的文件夹，使用 matches_subj_pattern 函数进一步筛选
    subjectFolders = subjectFolders(arrayfun(@(f) matches_subj_pattern(f.name), subjectFolders));
    
    % 小波频率范围与时间轴设置
    freq_range = 1:0.5:50; % 调整频率范围
    freq = 1:50; % 频率 (Hz)
    time = linspace(0, 3000, 1000); % 时间 (ms)
    
    for s = 1:length(subjectFolders)
        subjectPath = fullfile(subjectFolders(s).folder, subjectFolders(s).name);
    
        % 遍历事件类型目录
        for e = 1:length(eventTypes)
            eventType = eventTypes{e};
            eventPath = fullfile(subjectPath, eventType);
            matFiles = dir(fullfile(eventPath, '*.mat'));
    
            % 输出目录设置
            outputPath = fullfile(outputFolder, subjectFolders(s).name, eventType);
            if ~exist(outputPath, 'dir')
                mkdir(outputPath);
            end
    
            % 处理每个 mat 文件
            for m = 1:length(matFiles)
                matFilePath = fullfile(matFiles(m).folder, matFiles(m).name);
                data = load(matFilePath);
                [~, matFileName, ~] = fileparts(matFiles(m).name); % 文件名不含路径和扩展名
                
                % 提取数据：查找以 'wcohere_C3_' 或 'wcohere_C4_' 开头的变量
                results = {};
                channels = {};
                labels = fieldnames(data.results);
                for i = 1:length(labels)
                    disp(labels)
                    if startsWith(labels{i}, 'wcohere_C3_') || startsWith(labels{i}, 'wcohere_C4_')
                        disp("found start with wcohere_c3_c4")
                        results{end+1} = data.results.(labels{i});
                        channelName = strrep(labels{i}, 'wcohere_', ''); % 去除 'wcohere_' 前缀
                        channelName = strrep(channelName, '_', ' - '); % 替换下划线为 ' - '
                        channels{end+1} = channelName;
                    end
                end
                disp("result length:")
                disp(length(results));
                disp(channels)
    
                % 创建图像
                figure;
                t = tiledlayout(4, 4); % 4 行 4 列的布局，保证每个数据项按顺序展示
                for i = 1:length(results)
                    nexttile; % 自动按顺序排列
                    imagesc(time, freq_range, results{i});
                    axis xy; % 确保频率轴正序
                    colormap('jet');
                    colorbar;
                    caxis([0, 0.4]); % 根据数据调整颜色范围
                    title(channels{i}, 'Interpreter', 'none');
                    xlabel('Time (ms)');
                    ylabel('Frequency (Hz)');
                end

                set(gcf, 'Position', [100, 100, 2300, 1000]); % 设置图像大小，适合 4x4 图布局

                % 总标题：获取文件名前缀并生成整体标题
                splitName = split(matFileName, '_');
                prefix = splitName{1}; % 获取文件名前缀
                overallTitle = sprintf('线性脑肌耦合 小波相干分析结果 (C3&C4) %s', prefix);
                sgtitle(overallTitle, 'Interpreter', 'none');
    
                % 保存图像
                outputFileName = sprintf('%s_%s_CMC(C3&C4).png', prefix, eventType);
                saveas(gcf, fullfile(outputPath, outputFileName));
                close; % 关闭当前图像
            end
        end
    end
    
    disp('图像生成完毕！');














    
    % eeglab;
    % dirs = ['a', 'b'];
    % 
    % folders = dir(fullfile(baseDataFolder, "CMCresult_lowerLimb"));  % 获取当前目录下的所有文件和文件夹
    % disp(folders)
    % for j = 1:length(folders)
    %     % 跳过 . 和 .. 这两个特殊文件夹
    %     if strcmp(folders(j).name, '.') || strcmp(folders(j).name, '..')
    %         continue;
    %     end
    %     disp(class(folders(j).name))
    % 
    %     % 拼接完整路径
    %     fullPath = fullfile(baseDataFolder, folders(j).name);
    %     % 判断是否是文件夹，并且文件夹名符合条件
    %     if folders(j).isdir && matches_subj_pattern(folders(j).name)
    %         fprintf('符合条件的文件夹：%s\n', fullPath);
    % 
    %         setsFolder = fullfile(fullPath);
    % 
    %         fileList = dir(setsFolder);
    % 
    %         % 排除 '.' 和 '..' 文件夹
    %         fileList = fileList(~ismember({fileList.name}, {'.', '..'}));
    % 
    %         for i = 1:length(fileList)
    %             fileName = fileList(i).name;  % 获取文件或文件夹的名字
    %             filepath = fullfile(setsFolder, fileName);  % 获取完整路径
    %             fprintf("当前处理的的文件是：%s\n",filepath);
    % 
    %             [~,name,ext] = fileparts(fileName);
    %             if ~strcmp(ext, ".set")
    %                 continue;
    %             end
    % 
    % 
    %             metaInfoFile = fullfile(fullPath, "meta_info", name + ".mat");
    %             info = load(metaInfoFile);
    % 
    %             % for indedx = 1:length(dirs)
    %             wCMC_C3C4_sitstand('a', info.TL_a, folders(j).name, filepath);
    %             wCMC_C3C4_sitstand('b', info.TL_b, folders(j).name, filepath);
    %             % end;
    %         end
    %     end
    % end
end