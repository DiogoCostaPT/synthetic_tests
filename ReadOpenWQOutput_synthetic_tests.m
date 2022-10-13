
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INPUT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Read project results: HDF5
outputFolder = '/Users/diogocosta/Library/CloudStorage/OneDrive-impactblue-scientific.com/6_Projects/1_GWF/2_WIP/code/synthTestT_results';

% Runs to process
model_all = {...'crhm',...
            'summa'};
% test = 2; % 2_nrTrans_instS_PorMedia
% test = 4; % 4_nrTrans_contS_PorMedia
% test = 6; % 6_nrTrans_instS_PorMedia_linDecay
% test = 8; % 8_nrTrans_contS_PorMedia_linDecay
tests_all = [2,...
    ...2, 4,8,9, 10, 11, 11.1 12, 13...
    ];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SETTINGS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Extraction settings
extrData_flag = true;
debugMode_flag = true;

% Plot settings
plot_TimeX_ConcY_perElement_flag = false;

plot_ConcX_ZProfileY_perTime_flag = true;
if test == 4 || test == 8 
    tStart_sec = seconds([...
                        60 * 60 * 24 * 15,...
                        60 * 60 * 24 * 70,...
                        60 * 60 * 24 * 120,...
                        ]);
elseif test == 2 || test == 6 
    tStart_sec = seconds([...
                        60 * 60 * 24 * 55,...
                        60 * 60 * 24 * 85,...
                        60 * 60 * 24 * 120,...
                        ]);
end
    
%tStart_sec = seconds([... % day
%                    0,...
%                    60 * 60 * 24,...
%                    60 * 60 * 24 * 3,...
%                    60 * 60 * 24 * 8,...
%                    60 * 60 * 24 * 20,...
%                    60 * 60 * 24 * 40,...
%                    60 * 60 * 24 * 160,...
%                    60 * 60 * 24 * 400,...
%                    ]);
requestProfileAPI = containers.Map(...
                    {'Profile', 'layer_m_interval', 'ReverseAxis_XY', 'TimeStamps'},...
                    {...
                        'z(x=1,y=1)',...
                        0.006,...
                        {true, true}, ...
                        datetime('1-Sep-2017 12:15:00') + tStart_sec...
                     });

openwq_noWaterConc_Val = -9999;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Start Processing
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Loop over models
for model_i = 1:numel(model_all)

    model_name = model_all{model_i};
    
    if model_name == "crhm"
        % crhm
        results_dir = '/Users/diogocosta/Library/CloudStorage/OneDrive-impactblue-scientific.com/6_Projects/1_GWF/2_WIP/code/code_crhm/bin/Case_Studies/synthetic_tests';  
        comptName = 'SOIL_RECHR';
    elseif model_name == "summa"
        % summa
        results_dir = '/Users/diogocosta/Library/CloudStorage/OneDrive-impactblue-scientific.com/6_Projects/1_GWF/2_WIP/code/Summa-openWQ/bin/synthetic_tests';
        %comptName = 'SCALARCANOPYWAT';
        %comptName = 'RUNOFF';
        comptName = 'ILAYERVOLFRACWAT_SOIL';
        %comptName = 'SCALARAQUIFER';
    end
    
    % Loop over tests
    for test_num = 1:numel(tests_all)

        test = tests_all(test_num);
        
        if test == 2

            Synthetic_test = '2_nrTrans_instS_PorMedia';

            extractElm_info = {...
                strcat(comptName,'@SPECIES_A#MG|L'),[repelem(1,100);
                                                     repelem(1,100);
                                                     1:100]';
                };
        
        elseif test == 4

            Synthetic_test = '4_nrTrans_contS_PorMedia';

            extractElm_info = {...
                strcat(comptName,'@SPECIES_A#MG|L'),[repelem(1,100);
                                                     repelem(1,100);
                                                     1:100]';
                };
        elseif test == 8

            Synthetic_test = '8_nrTrans_contS_PorMedia_linDecay';

            extractElm_info = {...
                strcat(comptName,'@SPECIES_A#MG|L'),[repelem(1,100);
                                                     repelem(1,100);
                                                     1:100]';
                };
        elseif test == 9
            Synthetic_test = '9_batch_singleSp_1storder';

            extractElm_info = {...
                strcat(comptName,'@SPECIES_A#MG'),[1,1,1]
                };

        elseif test == 10
            Synthetic_test = '10_batch_singleSp_2ndorder';

            extractElm_info = {...
                strcat(comptName,'@SPECIES_A#G'),[1,1,1]
                };

        elseif test == 11
            Synthetic_test = '11_batch_2species';

            extractElm_info = {...
                strcat(comptName,'@SPECIES_A#MG'),[1,1,1];...
                strcat(comptName,'@SPECIES_B#MG'),[1,1,1];...
                };

        elseif test == 11.1
            Synthetic_test = '11_1_batch_3species';

            extractElm_info = {...
                strcat(comptName,'@SPECIES_A#MG'),[1,1,1];...
                strcat(comptName,'@SPECIES_B#MG'),[1,1,1];...
                strcat(comptName,'@SPECIES_C#MG'),[1,1,1];...
                };

        elseif test == 12
            Synthetic_test = '12_batch_nitrogencycle';

            extractElm_info = {...
                strcat(comptName,'@Nref#MG'),[1,1,1];...
                strcat(comptName,'@Nlab#MG'),[1,1,1];...
                strcat(comptName,'@DON#MG'),[1,1,1];...
                strcat(comptName,'@DIN#MG'),[1,1,1]
                };    

        elseif test == 13
            Synthetic_test = '13_batch_oxygenBODcycle';

            extractElm_info = {...
                strcat(comptName,'@BOD#MG'),[1,1,1];...
                strcat(comptName,'@DEFICIT_OXYG#MG'),[1,1,1];...
                strcat(comptName,'@DO#MG'),[1,1,1]
                };
        end


        %% ================================================================================================
        % DON'T CHANGE BELOW ==============================================================================
        % ================================================================================================
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % EXTARCT DATA
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        if extrData_flag == true


            openwq_readfuncs_dir = '../../build/source/openwq/openwq/supporting_scripts/Read_Outputs/';
            addpath(openwq_readfuncs_dir)

            folderpath = strcat(results_dir, '/', Synthetic_test,'/', model_name,'/Output_OpenWQ/');

            output_openwq_tscollect_all = read_OpenWQ_outputs(...
                openwq_readfuncs_dir,...        % Fullpath for needed functions
                folderpath,...                  % Provide fullpath to directory where the HDF5 files are located
                extractElm_info,...             % If the flag above is 1, then provide details about the variables to plot
                'HDF5',...                      % Output format 
                debugMode_flag);                % Debug mode

            % Save Results
            save(strcat(outputFolder,'/',model_name, '/', Synthetic_test,'.mat'), 'output_openwq_tscollect_all');

        end
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Plot elements
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        
        % TimeX_ConcY_perElement
        if plot_TimeX_ConcY_perElement_flag == true

            plot_OpenWQ_outputs_TimeX_ConcY_perElement(...
                output_openwq_tscollect_all,...
                openwq_noWaterConc_Val);  % No water concentration flag in openwq

        end
        
        % ConcX_ZProfileY_perTime
        if plot_ConcX_ZProfileY_perTime_flag == true
                 
             plot_OpenWQ_outputs_ConcX_ZProfileY_perTime(...
                output_openwq_tscollect_all,...
                requestProfileAPI,...     % profile request, e.g., "z(x=1,y=1)"
                openwq_noWaterConc_Val);  % No water concentration flag in openwq
            
        end
        
    end
end