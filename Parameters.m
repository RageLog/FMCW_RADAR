classdef Parameters 
    properties
        %Constant
        C0 = 299792458; % m/s Speed of light
        k = 1.380649e-23 % Boltzman Constant m2 kg s-2 K-1

        %VCO parameters
        Fc % Carrier Frequency
        Fs % Sampling Frequenscy  --> this must be Fs >= ((2*Fd*Rmax)/(C0*Ts))+((2*Fc*Vmax)/C0)
        Fd % Frequency BW --> this must be Fd > C0/(2*DeltaR)

        Lambda

        VCO % VCO parameters

        To % Observation time 
        Ts % Sweep time -->(for each up or down chirp) this must be T > C0/(2*Fc*DeltaV)
        TRate % Triangle rate 
        Ts_Up % Up Chirp Sweep time
        Ts_Dawn % Down Chirp Sweep time

        PowerAmplifierGain %dBW
        PowerSplitterRate % x percent(for exemple Vo1 = 0.7 Vo2 = 0.3) to dBW
        LnaGain %dBW

        SystemEmpedance %Ohm

        AntennaTx
        AntennaRx

      
        Rmax % Maximum range
        DeltaR % range resolution

        Vmax % Maximum velocity
        DeltaV % velocity resolution
        
        NumOfMod
        SampPerMod
        
        VcomMin
        VcomMax

        Targets

        CFar

    end
    
    methods
        function obj = Parameters()
           obj.VCO = VCO(0,0,0,0,0,0,0);
           obj.Ts_Up = obj.Ts * obj.TRate;
           obj.Ts_Dawn = obj.Ts *(1- obj.TRate);
           obj.AntennaTx = Antenna(0,0,0,5);
           obj.AntennaRx = Antenna(0,0,0,5);
           obj.SystemEmpedance = 50;
           obj.Targets = Target(100,0,0,0,0,0,3000);
           obj.CFar = CFar(0,0,0,0,0);
        end
    end
    methods(Static)
       
    end
end

