# 数据清洗流程

## 读取数据

数据源文件为txt文件，包含多个通道（具体见Data部分），其中有用的通道只有24个

1-8 ：EMG

17-32： EEG

步骤如下：

1. 从文件中读取数据，过滤掉文件中开头为`#`的行，表示过滤掉注释=过滤掉表头
2. 选取数据中有用的列
3. 可以在这里对数据进行滤波处理，也可以放到后续EEGLAB里面进行滤波
4. 将处理好的数据存储下来

## 导入数据到EEGLAB

需要用到三个文件：

- 第一步处理好的数据
- 通道位置文件（应该包含24个通道的位置信息）
- Event信息





# Code

## viewData_sitstand_v1.m

1. 读取数据
2. 滤波
3. 画图
4. 存储

## create_event_info.m

创建event信息

## process_sitstand.m

数据预处理


## vCMC_C3C4
调用 calcCMC.m

## calcWavelet
wavelet
    wavebases
smoothwavelet


# Data

### **EMG通道（肌电图）**

这些通道对应 **肌肉** 活动的信号，通常以“True/False”和具体肌肉名称标识。

1. **True（EMG 通道）**：

   ```
   0+True+胫骨前肌+1000
   1+True+腓骨长肌+1000
   2+True+腓肠肌内侧+1000
   3+True+腓肠肌外侧+1000
   4+True+股直肌+1000
   5+True+股内侧肌+1000
   6+True+股二头肌长头+1000
   7+True+半腱肌+1000
   ```

2. **False（其他 EMG 备用或无效通道）**：

   ```
   8+False+胫骨前肌+1000
   9+False+腓骨长肌+1000
   10+False+肠肌内侧+1000
   11+False+肠肌外侧+1000
   12+False+EMG13+1000
   13+False+EMG14+1000
   14+False+EMG15+1000
   15+False+EMG16+1000
   ```

- **解释**：这里的 EMG 通道前 8 个是 **True** 标识的，通常意味着这些通道是有效的、被采集的肌肉活动信号。
- 肌肉列表：
  - 胫骨前肌 (TA)
  - 腓骨长肌 (PL)
  - 腓肠肌内侧 (MG)
  - 腓肠肌外侧 (LG)
  - 股直肌 (RF)
  - 股内侧肌 (VM)
  - 股二头肌长头 (LBF)
  - 半腱肌 (Semi)

------

### **EEG通道（脑电图）**

这些通道标识了脑电信号，常使用 10-20 系统命名法，如 P4、CP2、FC5 等。

1. EEG 通道：

   ```
   0+True+P4+80
   1+True+CP2+80
   2+True+FC5+80
   3+True+C3+80
   4+True+P3+80
   5+True+C2+80
   6+True+FC6+80
   7+True+C4+80
   8+True+CP6+80
   9+True+F3+80
   10+True+FC2+80
   11+True+FC1+80
   12+True+F4+80
   13+True+CP5+80
   14+True+C1+80
   15+True+CP1+80
   ```

- **解释**：这些都是 EEG 通道，符合 **10-20 国际系统** 标准，通常用于记录不同脑区的活动。
- **关键脑区对照**：
  - **P4**: 右侧顶叶
  - **CP2**: 中央-顶叶右区
  - **FC5**: 前额-中央左区
  - **C3**: 左侧中央
  - **P3**: 左侧顶叶
  - **C2**: 中央中间
  - **FC6**: 前额-中央右区
  - **C4**: 右侧中央
  - **CP6**: 中央-顶叶右区
  - **F3**: 左侧前额
  - **F4**: 右侧前额
  - **C1**: 左侧中央靠中间
  - **CP5**, **CP1** 等：中央-顶叶之间。



# TODO

- [ ] viewData_sitstand_v1 里面有参数没搞懂，还有数据分段咋回事
- [ ] 问一下chatgpt：startP是啥，怎么找，怎么判断