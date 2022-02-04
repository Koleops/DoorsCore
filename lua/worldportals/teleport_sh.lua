
hook.Add("EntityFireBullets", "WorldPortals_Bullets", function(ent,data)
    local trace = util.RealTraceLine({
        start = data.Src,
        endpos = data.Src + data.Dir * data.Distance,
        filter = {
            ent,
            data.IgnoreEntity,
        },
    })

    local portal = wp.GetFirstPortalHit(data.Src, data.Dir)

    if IsValid(portal.Entity) and portal.Distance < trace.HitPos:Distance(data.Src) and not portal.Entity:GetDisable() then
        local localHitPos = portal.Entity:WorldToLocal(portal.HitPos)
        local mins, maxs = portal.Entity:GetCollisionBounds()
        if localHitPos.y > mins.y and localHitPos.y < maxs.y
        and localHitPos.z > mins.z and localHitPos.z < maxs.z then
            data.Src=wp.TransformPortalPos( portal.HitPos, portal.Entity, portal.Entity:GetExit() )
            data.Dir=wp.TransformPortalAngle( data.Dir:Angle(), portal.Entity, portal.Entity:GetExit() ):Forward()
            
            return true
        end
    end
end)

if not util.RealTraceLine then
    util.RealTraceLine = util.TraceLine
end

function WorldPortals_TraceLine(data)
    local trace = util.RealTraceLine(data)
    local portal = wp.GetFirstPortalHit(trace.StartPos, trace.Normal)

    if IsValid(portal.Entity) and portal.Distance < trace.HitPos:Distance(trace.StartPos) then
        local localHitPos = portal.Entity:WorldToLocal(portal.HitPos)
        local mins, maxs = portal.Entity:GetCollisionBounds()

        if localHitPos.y > mins.y and localHitPos.y < maxs.y
        and localHitPos.z > mins.z and localHitPos.z < maxs.z then
            local angle = wp.TransformPortalAngle( trace.Normal:Angle(), portal.Entity, portal.Entity:GetExit() ):Forward()
            local startPos = wp.TransformPortalPos( portal.HitPos, portal.Entity, portal.Entity:GetExit() )

            local length = data.start:Distance(data.endpos)
            local usedLength = portal.Distance

            local endPos = angle
            endPos:Mul(length + 32 - usedLength)
            endPos:Add(startPos)
            
            local tr = util.RealTraceLine({
                start = startPos,
                endpos = endPos,
                mask = trace.mask,
                filter = trace.filter
            })
            return tr
        end
    end
    return trace
end

util.TraceLine = WorldPortals_TraceLine
hook.Add("InitPostEntity", "WorldPortals_TraceLine", function()
    util.TraceLine = WorldPortals_TraceLine
end)