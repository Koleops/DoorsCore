
-- Add exit portal visleafs to server's potentially visible set
hook.Add( "SetupPlayerVisibility", "WorldPortals_AddPVS", function( ply, ent )
    for _, portal in ipairs( ents.FindByClass( "linked_portal_door" ) ) do
        if ply:TestPVS( portal:GetPos() ) then
            local exitPortal = portal:GetExit()
            if IsValid(exitPortal) and (not ply:TestPVS( exitPortal:GetPos() )) then
                AddOriginToPVS( exitPortal:GetPos() )
            end
        end
    end
end)