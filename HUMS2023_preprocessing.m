%{
This file is for preprocessing the original dataset provided by HUMS2023. The link to download the original dataset is provided in the readme file.
If you are using the already preprocessed data, which is provided in this repo, this file is not helpufl.
%}
inputDirectory = ''; % the HUMS2023 downlaoded directory

outputDirectory = '';% output directory (for sensro_number X)

if ~exist(outputDirectory, 'dir')
    mkdir(outputDirectory);
end

matFiles = dir(fullfile(inputDirectory, '*.mat'));

for fileIndex = 1:length(matFiles)
    matFilePath = fullfile(inputDirectory, matFiles(fileIndex).name);
    matData = load(matFilePath);
    
    f1cell = matData.xah{X}; % X is the sensor number. In my case, I used the sensor 2 RF

    data_mean = mean(f1cell);
    data_std = std(f1cell);
    norm_d = (f1cell - data_mean) / data_std;
    
    re_data = reshape(norm_d, 4095, 99);
    row_avg = mean(re_data, 2);


    dXA = row_avg;
    XA = fft(hilbert(dXA));

    % Apply zeroing to specific frequency components
    for k = 1:10
        XA(1+k*35+(-2:2)) = 0;
    end
    XA(1+3.5*35:end) = 0;

  
    xr = real(ifft(XA));

    [filePath, fileName, fileExtension] = fileparts(matFiles(fileIndex).name);
    processedFileName = [fileName, '_PPSX.mat']; % X is the sensor number
    processedFilePath = fullfile(outputDirectory, processedFileName);
    save(processedFilePath, 'xr');
    
    fprintf('File %s processed and saved', matFiles(fileIndex).name, processedFileName);
end
