if SERVER then
	ULib.ucl.registerAccess("EnablePropsTeleport", {"operator", "admin", "superadmin"}, "" , "DoorsCore [E2]")
    ULib.ucl.registerAccess("bypass_portal_limit", {"operator", "admin", "superadmin"}, "" , "DoorsCore [E2]")

	hook.Add("ULibDoorsCore", "ULibDoorsCore", function( ply, command )
        if not ULib then
            if ply:IsAdmin() then return true end
            return false
        end

		if ULib.ucl.query(ply, command, true) then
            return true
		end

        return false
	end)
end