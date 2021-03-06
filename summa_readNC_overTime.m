
clear all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% TIME ANALYSIS
% Output or Forcing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Input info
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Runs to process
model_name = 'summa'; % scriot only for summa (not applicable to CRHM)

tests_all = [1,...
    ...9, 10, 11, 11.1 12, 13...
    ];

DataType_2exam_all = {...
    'output',...
    ...'forcing_data'
    };

% if choosing output, then select the parameters to plot
layer_num = 60;

Output_paramList = {
    'pptrate',...
    'averageRoutedRunoff',...
    'scalarSWE',...
    'mLayerVolFracIce',...
    'mLayerVolFracLiq',...
    'mLayerMatricHead',...
    'scalarSnowfall',...
    'scalarSnowSublimation',...
    'scalarGroundEvaporation',...
    'mLayerTranspire',...
    'scalarThroughfallSnow',...
    'scalarThroughfallRain',...
    'scalarSnowDrainage',...
    'scalarInfiltration',...
    'iLayerLiqFluxSoil',...
    'mLayerBaseflow',...
    'scalarSoilBaseflow',...
    'scalarSoilDrainage',...    
    };

% if choosing forcing, then select the parameters to plot
Forcing_paramList = {
    'LWRadAtm',...
    'SWRadAtm',...
    'airpres',...
    'airtemp',...
    'pptrate',...
    'spechum',...
    'windspd',...
    };

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Start Processing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Loop over tests
for test_i = 1:numel(tests_all)
    
    test_num = tests_all(test_i);
    
    % Folder dir
    if test_num == 1; folderTest = '1_conserv_instant_SW';
    elseif test_num == 9; folderTest = '9_batch_singleSp_1storder';
    elseif test_num == 10; folderTest = '10_batch_singleSp_2ndorder';
    elseif test_num == 11; folderTest = '11_batch_2species';    
    elseif test_num == 11.1; folderTest = '11_1_batch_3species';   
    elseif test_num == 12; folderTest = '12_batch_nitrogencycle';   
    elseif test_num == 13; folderTest = '13_batch_oxygenBODcycle';   
    end
    
    % Output file
    if test_num == 1; nc_output = 'openWQ_synthTests_timestep.nc';
    elseif test_num == 9; nc_output = 'openWQ_synthTests_timestep.nc';
    elseif test_num == 10; nc_output = 'openWQ_synthTests_timestep.nc';
    elseif test_num == 11; nc_output = 'openWQ_synthTests_timestep.nc';    
    elseif test_num == 11.1; nc_output = 'openWQ_synthTests_timestep.nc';   
    elseif test_num == 12; nc_output = 'openWQ_synthTests_timestep.nc';   
    elseif test_num == 13; nc_output = 'openWQ_synthTests_timestep.nc';   
    end
    
    % Forcing file
    if test_num == 1; nc_forcing = 'openWQ_syntheticTests_Transp_forcing.nc';
    elseif test_num == 9; nc_forcing = 'openWQ_syntheticTests_BGC_forcing.nc';
    elseif test_num == 10; nc_forcing = 'openWQ_syntheticTests_BGC_forcing.nc';
    elseif test_num == 11; nc_forcing = 'openWQ_syntheticTests_BGC_forcing.nc';    
    elseif test_num == 11.1; nc_forcing = 'openWQ_syntheticTests_BGC_forcing.nc';   
    elseif test_num == 12; nc_forcing = 'openWQ_syntheticTests_BGC_forcing.nc';   
    elseif test_num == 13; nc_forcing = 'openWQ_syntheticTests_BGC_forcing.nc';   
    end
    
    for d = 1:numel(DataType_2exam_all)
        
        DataType_2exam = DataType_2exam_all{d};
        
        folder = strcat(folderTest,'/summa/summa/',DataType_2exam,'/');

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Extract data
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if strcmp(DataType_2exam, 'output'); nc_file = strcat(folder,nc_output);
        elseif strcmp(DataType_2exam, 'forcing_data'); nc_file = strcat(folder,nc_forcing);
        end

        % To get information about the nc file
        %ncinfo(nc_file)
        % to display nc file
        %ncdisp(nc_file)
        

        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Plot
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        if strcmp(DataType_2exam, 'forcing_data'); paramList = Forcing_paramList;
        elseif strcmp(DataType_2exam, 'output'); paramList = Output_paramList;
        end
        
        % Get time
        time_secs = ncread(nc_file,'time');
        timeAtr = ncreadatt(nc_file,'time','units');
        timeAtr_split = split(timeAtr,'since');
        timeAtr_units = strtrim(timeAtr_split{1});
        
        timeAtr_starDate = strtrim(timeAtr_split{2});
        timeAtr_starDate(strfind(timeAtr_starDate,' -'):end) = '';
        timeAtr_starDate = datevec(strtrim(timeAtr_starDate));
        
        if strcmp(timeAtr_units,'seconds')
            time = datetime(timeAtr_starDate) + seconds(time_secs);
        elseif strcmp(timeAtr_units,'days')
            time = datetime(timeAtr_starDate) + days(time_secs);
        end
        
         %Extract data 
        hbar = parfor_progressbar(...
        numel(paramList),...
        ['Extracting summa variables. File: ', nc_file]);
    
        parfor p = 1:numel(paramList)
            
            % update waitbar
            hbar.iterate(1);

            varVals_all = ncread(nc_file,paramList{p});
            size_varVals = size(varVals_all);
            
            if strcmp(DataType_2exam, 'output')...
                    && (numel(size_varVals) > 2)
                varVals = permute(varVals_all(:,layer_num,:),[1 3 2]);
                layeredVar{p} = true;
            else
                varVals = varVals_all;
                layeredVar{p} = false;
            end
            
            varVals_compile{p} = varVals;

        end
        close(hbar)
        
        % Plot 
        % can't be paralellized
    
        figure('Name', nc_file)   
        sgtitle(['Vertical Layer = ', num2str(layer_num)])
        
        numPanels_y = ceil(numel(paramList)/2);
        numPanels_x = ceil(numel(paramList)/numPanels_y);
        
        hbar = parfor_progressbar(...
        numel(paramList),...
        ['Plotting summa variables. File: ', nc_file]);
        for p = 1:numel(paramList)
            
            % update waitbar
            hbar.iterate(1);
            
            varVals = varVals_compile{p};
            
            subplot(numPanels_x, numPanels_y, p)
            plot(time, varVals)
            xlabel('time')
            ylabel(paramList{p})
            datetick('x','keeplimits','keepticks')
            grid on
            if layeredVar{p} == true
                title(['layer = ', num2str(layer_num)])
            else
               title('unlayered') 
            end

        end
        close(hbar)

    end

end