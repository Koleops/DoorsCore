
hook.Add("CalcView", "WorldPortals_RotateView", function(ply,pos,ang,fov)
    if wp.rotating then
        if wp.rotating ~= 0 then
            wp.rotating = math.Approach(wp.rotating,0,FrameTime()*((0.5+math.abs(wp.rotating))*3.5))
            local view={
                origin=pos,
                angles=Angle(ang.p,ang.y,wp.rotating),
                fov=fov
            }
            return view
        else
            wp.rotating=nil
        end
    end
end)

net.Receive("WorldPortals_TeleportAlert", function()
    local roll=net.ReadFloat()
    if roll ~= 0 then
        wp.rotating=roll
    end
end)