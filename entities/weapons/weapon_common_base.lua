-- Common weapon base for Necronomicon Prop Hunt
AddCSLuaFile()

-- Create fonts for drawing weapon glyphs
if CLIENT then
    surface.CreateFont( "PropHuntWeaponIcons", {
        font = "HalfLife2",
        extended = false,
        size = 120,
        blursize = 0,
        antialias = true,
    } )

    surface.CreateFont( "PropHuntWeaponIconsSelected", {
        font = "HalfLife2",
        extended = false,
        size = 120,
        blursize = 10,
        antialias = true,
    } )
end

SWEP.Base = "weapon_base"
SWEP.BounceWeaponIcon = false;
SWEP.DrawWeaponInfoBox = false
SWEP.WeaponIconKey = "c" -- Defaults to crowbar

function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )

    -- Set us up the texture
    --surface.SetDrawColor( 255, 255, 255, alpha )
    --surface.SetTexture( self.WepSelectIcon )

    -- Lets get a sin wave to make it bounce
    -- local fsin = 0
    -- if ( self.BounceWeaponIcon == true ) then
    --     fsin = math.sin( CurTime() * 10 ) * 5
    -- end

    -- Borders
    y = y + 10
    x = x + 10
    wide = wide - 20

    -- Draw that mother
    --surface.DrawTexturedRect( x + fsin, y - fsin,  wide - fsin * 2 , ( wide / 2 ) + fsin )
    draw.SimpleText( self.WeaponIconKey, "PropHuntWeaponIconsSelected", x + wide / 2, y + tall / 2.3, Color( 255, 240, 20, alpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    draw.SimpleText( self.WeaponIconKey, "PropHuntWeaponIcons", x + wide / 2, y + tall / 2.3, Color( 255, 240, 20, alpha ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

    -- Draw weapon info box
    self:PrintWeaponInfo( x + wide + 20, y + tall * 0.95, alpha )

end
