
-- Setup variables
wp.matDummy = Material( "wp/black" )
wp.matView = CreateMaterial(
    "UnlitGeneric",
    "GMODScreenspace",
    {
        [ "$basetexturetransform" ] = "center .5 .5 scale -1 -1 rotate 0 translate 0 0",
        [ "$texturealpha" ] = "0",
        [ "$vertexalpha" ] = "1",
    }
)
wp.matView2 = CreateMaterial("WorldPortals", "Core_DX90", {["$basetexture"] = wp.matDummy:GetName(), ["$model"] = "1"})

wp.portals = {}
wp.drawing = true --default portals to not draw
wp.rendermode = false

-- Start drawing the portals
-- This prevents the game from crashing when loaded for the first time
hook.Add( "PostRender", "WorldPortals_StartRender", function()
    wp.drawing = false
    hook.Remove( "PostRender", "WorldPortals_StartRender" )
end )

function wp.shouldrender( portal, camOrigin, camAngle, camFOV )
    if portal:GetDisable() then return false end

    if not camOrigin then camOrigin = EyePos() end
    if not camAngle then camAngle = EyeAngles() end
    if not camFOV then camFOV = LocalPlayer():GetFOV() end
    local exitPortal = portal:GetExit()
    local distance = camOrigin:Distance( portal:GetPos() )
    local disappearDist = portal:GetDisappearDist()

    if not IsValid( exitPortal ) then return false end

    if portal:IsDormant() then return false end
    
    if not (disappearDist <= 0) and distance > disappearDist then return false end
    
    --don't render if the view is behind the portal
    local behind = wp.IsBehind( camOrigin, portal:GetPos(), portal:GetForward() )
    if behind then return false end
    local lookingAt = wp.IsLookingAt( portal, camOrigin, camAngle, camFOV )
    if not lookingAt then return false end

    return true
end


if not render.RealRenderView then
    render.RealRenderView = render.RenderView
end

function WorldPortals_RenderView(view)
    if not wp.drawing then
        wp.renderportals(view.origin or EyePos(), view.angles or EyeAngles(), view.width or ScrW(), view.height or ScrH(), view.fov or LocalPlayer():GetFOV())
    end
    wp.rendermode = true
    local renderView = render.RealRenderView(view)
    wp.rendermode = false
end

render.RenderView = WorldPortals_RenderView
hook.Add("InitPostEntity", "WorldPortals_RenderView", function()
    render.RenderView = WorldPortals_RenderView
end)

function wp.renderportals( plyOrigin, plyAngle, width, height, fov )
    if wp.drawing then return end
    wp.portals = ents.FindByClass( "linked_portal_door" )
    if not wp.portals then return end

    -- Disable phys gun glow and beam
    local oldWepColor = LocalPlayer():GetWeaponColor()
    LocalPlayer():SetWeaponColor( Vector( 0, 0, 0 ) )

    for _, portal in pairs( wp.portals ) do
        local exitPortal = portal:GetExit()
        local texture = portal:GetTexture()
        if IsValid(exitPortal) and wp.shouldrender(portal, plyOrigin, plyAngle, fov) and texture then
            render.PushRenderTarget( texture )
                render.Clear( 0, 0, 0, 255, true, true )

                local oldClip = render.EnableClipping( true )
                render.PushCustomClipPlane( exitPortal:GetForward(), exitPortal:GetForward():Dot( exitPortal:GetPos() - exitPortal:GetForward() * 0.5 ) )

                local camOrigin = wp.TransformPortalPos( plyOrigin, portal, exitPortal )
                local camAngle = wp.TransformPortalAngle( plyAngle, portal, exitPortal )

                wp.drawing = true
                wp.drawingent = portal
                    render.RenderView( {
                        x = 0,
                        y = 0,
                        w = width,
                        h = height,
                        fov = fov,
                        origin = camOrigin,
                        angles = camAngle,
                        dopostprocess = false,
                        drawhud = false,
                        drawmonitors = false,
                        drawviewmodel = false,
                        bloomtone = true
                        --zfar = 1500
                    } )
                wp.drawing = false
                wp.drawingent = nil

                render.PopCustomClipPlane()
                render.EnableClipping( oldClip )
            render.PopRenderTarget()
        end
    end
    LocalPlayer():SetWeaponColor( oldWepColor )
end

hook.Add( "RenderScene", "WorldPortals_Render", function( plyOrigin, plyAngle, fov )
    wp.renderportals(plyOrigin, plyAngle, ScrW(), ScrH(), fov)
end )