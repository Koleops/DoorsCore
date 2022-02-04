
ENT.Type                = "anim"
ENT.RenderGroup         = RENDERGROUP_BOTH -- fixes translucent stuff rendering behind the portal
ENT.Spawnable           = false
ENT.AdminOnly           = false
ENT.Editable            = false

function ENT:OnSizeChanged()

    local mins = Vector( 0, -self:GetWidth() /2, -self:GetHeight() /2 )
    local maxs = Vector( 10, self:GetWidth() /2, self:GetHeight() /2)

    if CLIENT then 

        self:SetRenderBounds( mins, maxs )

    else
        
        self:SetCollisionBounds( mins, maxs )

    end
end

function ENT:Initialize()

    if SERVER then

        self:SetTrigger( true )

    end

    self:SetMoveType( MOVETYPE_NONE )
    self:SetSolid( SOLID_OBB )
    self:SetNotSolid( true )
    self:SetCollisionGroup( COLLISION_GROUP_WORLD )
 
    self:DrawShadow( false )

    self:NetworkVarNotify( "Height", self.OnSizeChanged )
    self:NetworkVarNotify( "Width", self.OnSizeChanged )

end


function ENT:SetupDataTables()

    self:NetworkVar( "Entity", 0, "Exit" )
    
    self:NetworkVar( "Int", 1, "Width" )
    self:NetworkVar( "Int", 2, "Height" )
    self:NetworkVar( "Int", 3, "DisappearDist" )

    self:NetworkVar( "Bool", 4, "Disable")

end
