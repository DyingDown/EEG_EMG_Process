function [EEG, stepFlags] =  flag_artifacts(EEG, parentFolder, setname, flagFile, stepFlags)
    global config;
    fprintf("Start removing artifacts for set %s...\n", setname);
    
    saveFolder = fullfile(parentFolder, "set", "afterArtifact");
    if ~exist(saveFolder, "dir")
        mkdir(saveFolder);
        fprintf("Created folder %s\n", saveFolder);
    end

    fprintf("After artifacts removel set's savePath = %s\n", saveFolder);
    

    EEG = pop_iclabel(EEG, 'default');

    fig = uifigure('Name', 'Artifact Flagging', 'Position', [100, 100, 600, 400]);
    
    % 使用Grid布局
    gridLayout = uigridlayout(fig, [10, 3]);  % 8行3列


    % 设置行和列的尺寸
    gridLayout.RowHeight = {'1.5x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};  % 每一行的高度都是相等的
    gridLayout.ColumnWidth = {'4x', '1x', '1x'};  % 列等宽

    % 添加提示文字
    textLabel = uilabel(gridLayout, 'Text', 'Select range for flagging component for rejection', ...
                    'FontSize', 25, 'FontWeight', 'bold', 'HorizontalAlignment', 'center');
    textLabel.Layout.Row = 1;  % 让标签显示在第一行
    textLabel.Layout.Column = [1, 3];  % 跨越第一行的所有3列

    % 添加表头 min
    textLabelmin = uilabel(gridLayout, 'Text', 'MIN', 'HorizontalAlignment', 'center');
    textLabelmin.Layout.Row = 2;  % 让标签显示在第一行
    textLabelmin.Layout.Column = 2;  % 跨越第一行的所有3列

     % 添加表头 max
    textLabelmax = uilabel(gridLayout, 'Text', 'MAX', 'HorizontalAlignment', 'center');
    textLabelmax.Layout.Row = 2;  % 让标签显示在第一行
    textLabelmax.Layout.Column = 3;  % 跨越第一行的所有3列

    
    artifactTypes = fieldnames(config.artifacts);
    
    labelArray = gobjects(1, length(artifactTypes));
    minInputArray = gobjects(1, length(artifactTypes));
    maxInputArray = gobjects(1, length(artifactTypes));

    for i = 1:numel(artifactTypes)
        % 标签：伪影类型
        labelArray(i) = uilabel(gridLayout, 'Text', sprintf("Probability range for %s",artifactTypes{i}));
        labelArray(i).Layout.Row = i + 2;
        labelArray(i).Layout.Column = 1;
        
        % 下限输入框
        minInputArray(i) = uieditfield(gridLayout, 'numeric', 'Value', config.artifacts.(artifactTypes{i}).lower_limit);
        minInputArray(i).Layout.Row = i + 2;
        minInputArray(i).Layout.Column = 2;
        
        % 上限输入框
        maxInputArray(i) = uieditfield(gridLayout, 'numeric', 'Value', config.artifacts.(artifactTypes{i}).upper_limit);
        maxInputArray(i).Layout.Row = i + 2;
        maxInputArray(i).Layout.Column = 3;
    end
    
    % 添加一个确认按钮，点击时触发标记伪影
    btn = uibutton(gridLayout, 'Text', 'Flag Artifacts', ...
        'ButtonPushedFcn', @(btn, event) flagArtifacts());
    btn.Layout.Row = 10;
    btn.Layout.Column = 2;

    cancelBtn = uibutton(gridLayout, 'Text', 'Exit', ...
        'ButtonPushedFcn', @(btn, event) Exit());
    cancelBtn.Layout.Row = 10;
    cancelBtn.Layout.Column = 3;

    waitfor(fig);

    function flagArtifacts()
        EEG_temp = EEG;  % 使用一个临时的 EEG 数据避免直接修改原始数据
        EEG_temp = pop_icflag(EEG_temp, [minInputArray(1).Value maxInputArray(1).Value; ...
                               minInputArray(2).Value maxInputArray(2).Value; ...
                               minInputArray(3).Value maxInputArray(3).Value; ...
                               minInputArray(4).Value maxInputArray(4).Value; ...
                               minInputArray(5).Value maxInputArray(5).Value; ...
                               minInputArray(6).Value maxInputArray(6).Value; ...
                               minInputArray(7).Value maxInputArray(7).Value]);
        rejected_comps = find(EEG_temp.reject.gcompreject > 0);


        EEG_temp = pop_subcomp(EEG_temp, rejected_comps);
        EEG_temp = eeg_checkset(EEG_temp);

        disp("Rejection of comps:");
        disp(class(rejected_comps))
        disp(rejected_comps);


        % 添加显示消息的确认弹窗
        confirmationFig = uifigure('Name', 'Rejection Confirmation', 'Position', [100, 100, 600, 400]);
        gridLayoutConf = uigridlayout(confirmationFig, [4, 1]);
        msgLabel = uilabel(gridLayoutConf, 'Text', sprintf('Marked components for rejection: [%s]', strjoin(string(rejected_comps), ', ')), 'FontSize', 14, 'HorizontalAlignment', 'center');
        msgLabel.Layout.Row = 1;

        % 预览按钮
        previewBtn = uibutton(gridLayoutConf, 'Text', 'Preview Rejection', 'ButtonPushedFcn', @(btn, event) previewData(EEG_temp));
        previewBtn.Layout.Row = 2;

        % 确定按钮
        confirmBtn = uibutton(gridLayoutConf, 'Text', 'Confirm', 'ButtonPushedFcn', @(btn, event) confirmRejection);
        confirmBtn.Layout.Row = 3;

        % 取消按钮
        cancelBtn = uibutton(gridLayoutConf, 'Text', 'Cancel', 'ButtonPushedFcn', @(btn, event) cancelRejection());
        cancelBtn.Layout.Row = 4;

        % 设置按钮的尺寸
        previewBtn.Layout.Column = 1;
        confirmBtn.Layout.Column = 1;
        cancelBtn.Layout.Column = 1;
        
        waitfor(confirmationFig);  % 等待弹窗关闭
        
        function previewData(EEG_temp)
            EEG_a = EEG_temp; 
            eegChannels = find(strcmp({EEG_temp.chanlocs.type}, 'EEG'));
            EEG_eeg = pop_select(EEG_a, 'channel', eegChannels);
            pop_eegplot(EEG_eeg, 1, 1, 1); 
        end

        function confirmRejection()
            EEG = pop_saveset(EEG_temp, 'filename', [setname '.set'], 'filepath', char(saveFolder));
            stepFlags.flagArtifacts = true;
            save(flagFile, "stepFlags");
            disp("Artifacts removed.")
            close(confirmationFig);  % 确定后关闭确认弹窗
        end

        function cancelRejection()
            disp("Action cancelled, no changes made.");
            close(confirmationFig);  % 取消后关闭确认弹窗
        end
    end
    
    function Exit()
        close(fig);
    end 

    % EEG_a = EEG; 
    % for i = 1:8
    %     EEG_a.data(i,:) = EEG_a.data(i,:)*0;
    % end
    % pop_eegplot( EEG_a, 1, 1, 1);
    
end