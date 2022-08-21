classdef VCO
    %VCO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        A
        Fmin
        Fmax
        Fd % Diffirent from parameter.Fd
        
        Vmin
        Vmax

        Delta_VCom % voltage changes
        Kvco % Frequency changes by Command voltage changes 2*pi*Fd/Delta_VCom



        Nonlinearty_1
        Nonlinearty_2
    end
    
    methods
        function obj = VCO(Amplitude, Fmin, Fmax, Vmin, Vmax, Nonlinearty_1,Nonlinearty_2)
            obj.A = Amplitude;
            obj.Fmin = Fmin;
            obj.Fmax = Fmax;
            obj.Vmin = Vmin;
            obj.Vmax = Vmax;
            obj.Delta_VCom = (Vmax - Vmin); 
            obj.Nonlinearty_1 = Nonlinearty_1;
            obj.Nonlinearty_2 = Nonlinearty_2;
            obj.Fd = obj.Fmax - obj.Fmin;
            obj.Kvco = (2*pi*obj.Fd)/obj.Delta_VCom;
        end
    end
end

