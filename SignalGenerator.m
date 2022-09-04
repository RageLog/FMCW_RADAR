classdef SignalGenerator
    properties
        Time
        VcoOperationSignal
        VcoOutput
        TxSignal
        SplitedSignal
        RxSignal
        Vrms
    end
    
    methods
        function obj = SignalGenerator(param)
            obj.Time = 0:1/param.Fs:param.To-(1/param.Fs);
            obj.VcoOperationSignal = obj.generateVcoOperationSignal(param,0);
            obj.VcoOutput = obj.generateVcoOutputSignal(param,0,0);
            obj.TxSignal = obj.generateTxSignal(param,0,0);
            obj.Vrms = rms(obj.TxSignal);
            obj.SplitedSignal = obj.generateTxSplitedSignal(param,0,0);
            obj.RxSignal = obj.generateRxSignal(param);
        end
        function ModulationSignal = generateModulationSignal(obj,param,delay)
            TempTime = obj.Time - delay;
            Sig1 = mod(TempTime,param.Ts)./param.Ts;
            Sig2 = 1-Sig1;
            signal = ((0<param.TRate)&(param.TRate<1)) .* min(Sig1*param.TRate,Sig2.*(1-param.TRate)) + (0==param.TRate)*Sig1 + (1==param.TRate)* Sig2;
            ModulationSignal = signal./max(signal);
        end
        function VcoOperationSignal = generateVcoOperationSignal(obj,param,delay)
            DeltaV = param.VcomMax - param.VcomMin;
            VcoOperationSignal = param.VcomMin + (DeltaV*obj.generateModulationSignal(param,delay));

        end
        function out = generateVcoOutputSignal(obj,param,delay,doppler)
            out = param.VCO.A * obj.Generator(param,delay,doppler);
        end
        function Tx = generateTxSignal(obj,param,delay,doppler)
            Gain = param.PowerAmplifierGain + obj.wattTodBW(param.PowerSplitterRate); %dBW
            VGain = obj.wattToVoltage(Gain,param.SystemEmpedance);
            out = obj.generateVcoOutputSignal(param,delay,doppler);
            Tx = VGain*out;% rate with system gain
        end
        function SplitedSignal = generateTxSplitedSignal(obj,param,delay,doppler)
            Gain = param.PowerAmplifierGain + obj.wattTodBW(1-param.PowerSplitterRate); %dBW
            VGain = obj.wattToVoltage(Gain,param.SystemEmpedance);
            out = obj.generateVcoOutputSignal(param,delay,doppler);
            SplitedSignal = VGain*out; % rate with system gain
        end
        function Rx = generateRxSignal(obj,param)
            Rx = zeros(1,length(obj.Time));
            for target = param.Targets
                x = target.Position.x + obj.Time*target.Velocity.x;
                y = target.Position.y + obj.Time*target.Velocity.y;
                z = target.Position.z + obj.Time*target.Velocity.z;
                x = (x-param.AntennaRx.Position.x);
                y = (y-param.AntennaRx.Position.y);
                z = (z-param.AntennaRx.Position.z);
                range = sqrt(x.*x+y.*y+z.*z);
                delay = 2*range/param.C0;
                vel = sqrt(target.Velocity.x*target.Velocity.x + target.Velocity.y*target.Velocity.y + target.Velocity.z *target.Velocity.z);
                Fdoppler = -2*((param.Fc/param.C0)*vel);
                RxGain = obj.friss(param,max(range),target.rcs);
                VGain = obj.wattToVoltage(RxGain,param.SystemEmpedance);
                Rx = Rx + awgn(VGain*obj.generateTxSignal(param,delay,Fdoppler),radareqsnr(param.Lambda,max(range),((obj.Vrms*obj.Vrms *2)/ param.SystemEmpedance),param.Ts));
            end
        end
        function output = Generator(obj,param,delay,doppler)
            TempTime = obj.Time - delay;
            Fmin = param.Fc - param.C0/(2*param.DeltaR);
            w0 = 2*pi*Fmin + doppler;
            VcoOps = obj.generateVcoOperationSignal(param,delay);
            mIntegral = cumtrapz(TempTime,VcoOps);
            mIntegral2 = cumtrapz(TempTime,VcoOps.*VcoOps);
            mIntegral3 = cumtrapz(TempTime,VcoOps.*VcoOps.*VcoOps);
            output = exp(1i*((w0*TempTime)+(param.VCO.Kvco*mIntegral)+(param.VCO.Nonlinearty_1* mIntegral2)+(param.VCO.Nonlinearty_2* mIntegral3)));
        end
    end
    methods(Static)
        function out = wattTodBW(Watt)
            out = 10 * log10(Watt);
        end
        function out = dBWToWatt(dBW)
            out = 10 ^ (dBW/10);
        end
        function out = wattToVoltage(dBW,Empedance)
            out = (10 ^ (dBW/20))*sqrt(Empedance);
        end
        function out = VoltageToWatt(Voltage,Empedance)
            out = 20 * log10(Voltage/sqrt(Empedance));
        end
        function out = dBmTodBW(dBm)
            out = dBm -30;
        end
        function out = dBWtodBV(dBW,Empedance)
            out =  dBW + (10*log10(Empedance));
        end
        function out = friss(param,range,rsc)
            out = param.AntennaTx.Gain + param.AntennaRx.Gain + (20*log10((rsc)/(4*pi*range)));
        end
    end
end

