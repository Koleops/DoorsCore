
E2Lib.RegisterExtension("DoorsCore", true, "")

local MAX_PORTALS = CreateConVar("doorscore_maxportals", 4, FCVAR_ARCHIVE, "Limit the maximum number of portal an E2 can create", 1)

local PortalIndex = {}

-- FUNCTION

local function hasAccess( ply, command )
    return hook.Call("ULibDoorsCore", GAMEMODE, ply, command)
end

local function Validate(chip, ...)
    local args = { ... }

    if not PortalIndex[chip] then return false end

    if #args == 0 then return true end

    for _,index in ipairs(args) do
        if type(index) ~= "string" then continue end
        if not PortalIndex[chip][index] then return false end
    end

    return true
end

local function toEnt(chip, ...)
    local args = { ... }
    local ents = {}

    for _,index in ipairs(args) do
        table.insert(ents, PortalIndex[chip][index])
    end

    return unpack(ents)
end

local function portalCreate(chip, portal)
    local ent = ents.Create("linked_portal_door")
        chip:DeleteOnRemove(ent)
        ent:CallOnRemove("RemovePortalEntry", function(ent, chip)
            if not IsValid(chip) then return end
            if not PortalIndex[chip] then return end

            local key = table.KeyFromValue(PortalIndex[chip], ent)

            if not key then return end

            PortalIndex[chip][key] = nil
        end, chip)

        ent:SetPos(portal.vector or Vector(0, 0, 0))
        ent:SetAngles(portal.angles or Angle(0, 0, 0))

        if IsValid(portal.parent) then
            ent:SetParent(portal.parent)
        end

        ent:SetHeight(math.Clamp(portal.height, 1, 300) or 100)
        ent:SetWidth(math.Clamp(portal.width, 1, 300) or 100)
        ent:SetDisable(portal.disable or false)
        ent:SetDisableTeleport(portal.teleport or false)
        ent:SetEnablePropsTeleport(portal.teleport_props or false)

        ent:Spawn()
        ent:Activate()
    return ent
end

registerCallback("destruct", function(self)
    PortalIndex[self.entity] = nil
end)

-- PORTALCREATE

e2function void portalCreate(string portal, vector position)
    local chip = self.entity

    if Validate(chip, portal) then return end
    PortalIndex[chip] = PortalIndex[chip] or {}

    if table.Count(PortalIndex[chip]) >= MAX_PORTALS:GetInt() and not hasAccess(self.player, "bypass_portal_limit") then return end

    local ent = portalCreate(chip, {
        vector = Vector(position[1], position[2], position[3])
    })

    PortalIndex[chip][portal] = ent
end

e2function void portalCreate(string portal, vector position, height, width)
    local chip = self.entity

    if Validate(chip, portal) then return end
    PortalIndex[chip] = PortalIndex[chip] or {}

    if table.Count(PortalIndex[chip]) >= MAX_PORTALS:GetInt() and not hasAccess(self.player, "bypass_portal_limit") then return end

    local ent = portalCreate(chip, {
        vector = Vector(position[1], position[2], position[3]),
        height = math.floor(height),
        width = math.floor(width)
    })

    PortalIndex[chip][portal] = ent
end

e2function void portalCreate(string portal, vector position, angle angles, height, width)
    local chip = self.entity

    if Validate(chip, portal) then return end
    PortalIndex[chip] = PortalIndex[chip] or {}

    if table.Count(PortalIndex[chip]) >= MAX_PORTALS:GetInt() and not hasAccess(self.player, "bypass_portal_limit") then return end

    local ent = portalCreate(chip, {
        vector = Vector(position[1], position[2], position[3]),
        angles = Angle(angles[1], angles[2], angles[3]),
        height = math.floor(height),
        width = math.floor(width)
    })

    PortalIndex[chip][portal] = ent
end

e2function void portalCreate(string portal, vector position, angle angles, height, width, entity parent)
    local chip = self.entity

    if Validate(chip, portal) then return end
    PortalIndex[chip] = PortalIndex[chip] or {}

    if table.Count(PortalIndex[chip]) >= MAX_PORTALS:GetInt() and not hasAccess(self.player, "bypass_portal_limit") then return end

    local ent = portalCreate(chip, {
        vector = Vector(position[1], position[2], position[3]),
        angles = Angle(angles[1], angles[2], angles[3]),
        parent = parent,
        height = math.floor(height),
        width = math.floor(width)
    })

    PortalIndex[chip][portal] = ent
end

-- PORTALSETEXIT

e2function void portalSetExit(string entry, string exit)
    local chip = self.entity

    if not Validate(chip, entry, exit) then return end

    entry, exit = toEnt(chip, entry, exit)

    entry:SetExit(exit)
end

-- PORTALSETPOS

e2function void portalSetPos(string portal, vector position)
    local chip = self.entity

    if not Validate(chip, portal) then return end

    portal = toEnt(chip, portal)

    portal:SetPos(Vector(position[1], position[2], position[3]))
end

-- PORTALSETANG

e2function void portalSetAngle(string portal, angle angles)
    local chip = self.entity

    if not Validate(chip, portal) then return end

    portal = toEnt(chip, portal)

    portal:SetAngles(Angle(angles[1], angles[2], angles[3]))
end

-- PORTALPARENT

e2function void portalParent(string portal, entity parent)
    local chip = self.entity

    if not Validate(chip, portal) then return end

    portal = toEnt(chip, portal)

    if IsValid(parent) then return end
    portal:SetParent(parent)
end

e2function void portalUnparent(string portal)
    local chip = self.entity

    if not Validate(chip, portal) then return end

    portal = toEnt(chip, portal)

    portal:SetParent()
end

-- PORTALDISABLE

e2function void portalDisable(string portal, io)
    local chip = self.entity

    if not Validate(chip, portal) then return end

    portal = toEnt(chip, portal)

    portal:SetDisable(tobool(io))
end

--PORTALDISABLETELEPORT

e2function void portalDisableTeleport(string portal, io)
    local chip = self.entity

    if not Validate(chip, portal) then return end

    portal = toEnt(chip, portal)

    portal:SetDisableTeleport(tobool(io))
end

-- PORTALENABLEPROPSTELEPORT

e2function void portalEnablePropsTeleport(string portal, io)
    if not hasAccess(self.player, "EnablePropsTeleport") then return end
    local chip = self.entity

    if not Validate(chip, portal) then return end

    portal = toEnt(chip, portal)

    portal:SetEnablePropsTeleport(tobool(io))
end

-- PORTALSETSIZE

e2function void portalSetSize(string portal, width, height)
    local chip = self.entity

    if not Validate(chip, portal) then return end

    portal = toEnt(chip, portal)

    portal:SetWidth(math.Clamp(math.floor(width), 1, 300))
    portal:SetHeight(math.Clamp(math.floor(height), 1, 300))
end

-- PORTALDISAPPEARDIST

e2function void portalDisappearDist(string portal, dist)
    local chip = self.entity

    if not Validate(chip, portal) then return end

    portal = toEnt(chip, portal)

    portal:SetDisappearDist(math.floor(dist))
end

-- PORTALREMOVE

e2function void portalRemove(string portal)
    local chip = self.entity

    if not Validate(chip, portal) then return end

    portal = toEnt(chip, portal)

    portal:Remove()
end
