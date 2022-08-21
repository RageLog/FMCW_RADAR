classdef CFar
    %CFAR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        Tr
        Tc
        Gc
        Gr
        Offset % offset the threshold by SNR value in dB
    end
    
    methods
        function obj = CFar(Tr,Tc,Gr,Gc,Offset)
            obj.Tr = Tr;
            obj.Tc = Tc;
            obj.Gc = Gc;
            obj.Gr = Gr;
            obj.Offset = Offset;
        end
    end
end

