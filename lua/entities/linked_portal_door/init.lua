
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include( "shared.lua" )

AccessorFunc( ENT, "disable_teleport", "DisableTeleport", FORCE_BOOL )
AccessorFunc( ENT, "enable_props_teleport", "EnablePropsTeleport", FORCE_BOOL )

-- Teleportation
function ENT:Touch( ent )
    if self:GetDisable() or self:GetDisableTeleport() then return end

    local exit = self:GetExit()
    if not IsValid(exit) then return end
    
    if IsValid( self:GetParent() ) then
        local ents = constraint.GetAllConstrainedEntities( self:GetParent() ) -- don't mess up this contraption we're on
        for k,v in pairs( ents ) do
            if v == ent then
                return
            end
        end
    end
    local vel_norm = ent:GetVelocity():GetNormalized()

    -- Object is moving towards the portal
    /*if vel_norm:Dot( self:GetForward() ) < 0 then

        local projected_distance = wp.DistanceToPlane( ent:EyePos(), self:GetPos(), self:GetForward() )

        if projected_distance < 0 then

            local new_pos = wp.TransformPortalPos( ent:GetPos(), self, exit )
            local new_velocity = wp.TransformPortalVector( ent:GetVelocity(), self, exit )
            local new_angle = wp.TransformPortalAngle( ent:GetAngles(), self, exit )
            if ent:IsPlayer() then
                local height = ent:OBBMaxs().z
                local temppos = Vector(0,0,height)
                temppos:Rotate(Angle(0,0,new_angle.r))
                new_pos = new_pos + Vector(0,0,(temppos.z - height) / 2) 
            end
            
            local store
            if ent:IsRagdoll() and self:GetEnablePropsTeleport() then
                store={}
                for i=0,ent:GetPhysicsObjectCount() do
                    local bone=ent:GetPhysicsObjectNum(i)
                    if IsValid(bone) then
                        store[i]={ent:WorldToLocal(bone:GetPos()),ent:WorldToLocalAngles(bone:GetAngles())}
                    end
                end
            end

            if ent:IsPlayer() or self:GetEnablePropsTeleport() then
                ent:SetPos( new_pos )
            end

            if ent:IsPlayer() then
                ent:SetEyeAngles( Angle(new_angle.p, new_angle.y, 0) )
                ent:SetLocalVelocity( new_velocity )
                wp.AlertPlayerOnTeleport( ent, new_angle.r )
            elseif self:GetEnablePropsTeleport() then
                ent:SetAngles( new_angle )

                ent:SetVelocity( new_velocity )
                local phys = ent:GetPhysicsObject()
                if IsValid(phys) then phys:SetVelocityInstantaneous( new_velocity ) end
            end

            if ent:IsRagdoll() and self:GetEnablePropsTeleport() then
                for i=0,ent:GetPhysicsObjectCount() do
                    local bone=ent:GetPhysicsObjectNum(i)
                    if IsValid(bone) then
                        bone:SetPos(ent:LocalToWorld(store[i][1]))
                        bone:SetAngles(ent:LocalToWorldAngles(store[i][2]))
                        bone:SetVelocityInstantaneous(new_velocity)
                    end
                end
            end
            
            if self:GetEnablePropsTeleport() then
                ent:ForcePlayerDrop()
            end
        end
    end*/

    -- Object is moving towards the portal
    if vel_norm:Dot( self:GetForward() ) < 0 then

        local projected_distance = wp.DistanceToPlane( ent:EyePos(), self:GetPos(), self:GetForward() )

        if projected_distance < 0 then

            local new_pos = wp.TransformPortalPos( ent:GetPos(), self, exit )
            local new_velocity = wp.TransformPortalVector( ent:GetVelocity(), self, exit )
            local new_angle = wp.TransformPortalAngle( ent:GetAngles(), self, exit )

            if ent:IsPlayer() then
                local height = ent:OBBMaxs().z
                local temppos = Vector(0,0,height)

                temppos:Rotate(Angle(0,0,new_angle.r))
                new_pos = new_pos + Vector(0,0,(temppos.z - height) / 2) 

                ent:SetPos( new_pos )

                ent:SetEyeAngles( Angle(new_angle.p, new_angle.y, 0) )
                ent:SetLocalVelocity( new_velocity )
                wp.AlertPlayerOnTeleport( ent, new_angle.r )

                return
            end
            
            if not self:GetEnablePropsTeleport() then return end

            local store
            if ent:IsRagdoll() then
                store={}
                for i=0,ent:GetPhysicsObjectCount() do
                    local bone=ent:GetPhysicsObjectNum(i)
                    if IsValid(bone) then
                        store[i]={ent:WorldToLocal(bone:GetPos()),ent:WorldToLocalAngles(bone:GetAngles())}
                    end
                end
            end

            ent:SetPos( new_pos )

            ent:SetAngles( new_angle )

            ent:SetVelocity( new_velocity )

            local phys = ent:GetPhysicsObject()
            if IsValid(phys) then 
                phys:SetVelocityInstantaneous( new_velocity ) 
            end

            if ent:IsRagdoll() then
                for i=0,ent:GetPhysicsObjectCount() do
                    local bone=ent:GetPhysicsObjectNum(i)
                    if IsValid(bone) then
                        bone:SetPos(ent:LocalToWorld(store[i][1]))
                        bone:SetAngles(ent:LocalToWorldAngles(store[i][2]))
                        bone:SetVelocityInstantaneous(new_velocity)
                    end
                end
            end

            ent:ForcePlayerDrop()
        end
    end
end