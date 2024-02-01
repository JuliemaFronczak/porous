function model = getSequentialModelFromFI(fimodel, varargin)
% For a given fully implicit model, output the corresponding pressure/transport model 
    opt = struct('useAcceleration', false, 'outerLoop', false);
    [opt, varargin] = merge_options(opt, varargin{:});
    if isa(fimodel, 'SequentialPressureTransportModel')
        % User gave us a sequential model! We do not know why, but in that
        % case we just return it straight back.
        model = fimodel;
        return
    end
    rock  = fimodel.rock;
    fluid = fimodel.fluid;
    G     = fimodel.G;
    if isa(fimodel, 'GenericReservoirModel')
        % Reset state function groupings
        fimodel = fimodel.removeStateFunctionGroupings();
        pressureModel = PressureModel(fimodel);
        transportModel = TransportModel(fimodel);
    else
        switch lower(class(fimodel))
            case 'twophaseoilwatermodel'
                pressureModel  = PressureOilWaterModel(G, rock, fluid, ...
                                                        'oil',   fimodel.oil, ...
                                                        'water', fimodel.water);
                transportModel = TransportOilWaterModel(G, rock, fluid, ...
                                                        'oil',   fimodel.oil, ...
                                                        'water', fimodel.water);
            case 'threephaseblackoilmodel'
                pressureModel  = PressureBlackOilModel(G, rock, fluid, ...
                                                        'oil',    fimodel.oil, ...
                                                        'water',  fimodel.water, ...
                                                        'gas',    fimodel.gas, ...
                                                        'disgas', fimodel.disgas, ...
                                                        'vapoil', fimodel.vapoil ...
                                                    );
                transportModel = TransportBlackOilModel(G, rock, fluid, ...
                                                        'oil',    fimodel.oil, ...
                                                        'water',  fimodel.water, ...
                                                        'gas',    fimodel.gas, ...
                                                        'disgas', fimodel.disgas, ...
                                                        'vapoil', fimodel.vapoil ...
                                                        );
            case 'oilwaterpolymermodel'
                pressureModel  = PressureOilWaterPolymerModel(G, rock, fluid, ...
                                                        'oil',     fimodel.oil, ...
                                                        'water',   fimodel.water, ...
                                                        'polymer', fimodel.polymer);
                transportModel = TransportOilWaterPolymerModel(G, rock, fluid, ...
                                                        'oil',     fimodel.oil, ...
                                                        'water',   fimodel.water, ...
                                                        'polymer', fimodel.polymer);

            case 'threephaseblackoilpolymermodel'
                pressureModel  = PressureBlackOilPolymerModel(G, rock, fluid, ...
                                                        'oil',    fimodel.oil, ...
                                                        'water',  fimodel.water, ...
                                                        'gas',    fimodel.gas, ...
                                                        'disgas', fimodel.disgas, ...
                                                        'vapoil', fimodel.vapoil, ...
                                                        'oil',     fimodel.oil, ...
                                                        'polymer', fimodel.polymer);
                transportModel = TransportBlackOilPolymerModel(G, rock, fluid, ...
                                                        'oil',    fimodel.oil, ...
                                                        'water',  fimodel.water, ...
                                                        'gas',    fimodel.gas, ...
                                                        'disgas', fimodel.disgas, ...
                                                        'vapoil', fimodel.vapoil, ...
                                                        'oil',     fimodel.oil, ...
                                                        'polymer', fimodel.polymer);
            case {'naturalvariablescompositionalmodel', 'genericnaturalvariablesmodel'}
                carg = {G, rock, fluid, fimodel.EOSModel, 'water', fimodel.water};
                pressureModel = PressureNaturalVariablesModel(carg{:});
                transportModel = TransportNaturalVariablesModel(carg{:});
            case {'overallcompositioncompositionalmodel', 'genericoverallcompositionmodel'}
                carg = {G, rock, fluid, fimodel.EOSModel, 'water', fimodel.water};
                pressureModel = PressureOverallCompositionModel(carg{:});
                transportModel = TransportOverallCompositionModel(carg{:});
            otherwise
                error('mrst:getSequentialModelFromFI', ...
                ['Sequential model not implemented for ''' class(fimodel), '''']);
        end
        pressureModel.operators = fimodel.operators;
        transportModel.operators = fimodel.operators;
    end
    arg = {pressureModel, transportModel, 'stepFunctionIsLinear', ~opt.outerLoop, varargin{:}};
    if opt.useAcceleration
        model = AcceleratedSequentialModel(arg{:});
    else
        model = SequentialPressureTransportModel(arg{:});
    end
end

%{
Copyright 2009-2020 SINTEF Digital, Mathematics & Cybernetics.

This file is part of The MATLAB Reservoir Simulation Toolbox (MRST).

MRST is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

MRST is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with MRST.  If not, see <http://www.gnu.org/licenses/>.
%}

