classdef Target
    properties
        %position
        Position
        %velocity
        Velocity
        %cross section
        rcs
    end
    methods 
        function obj = Target(x,y,z,vx,vy,vz,rcs)
            obj.Position = Position(x,y,z);
            obj.Velocity = Velocity(vx,vy,vz);
            obj.rcs = rcs;
        end
    end
end