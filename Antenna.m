classdef Antenna

    properties
        Position
        Gain
    end
    
    methods
        function obj = Antenna(x,y,z,Gain)

            obj.Position = Position(x,y,z);
            obj.Gain = Gain;
        end
        

    end
end

