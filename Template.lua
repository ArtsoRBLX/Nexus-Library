--=====================================================================
--  MY SCRIPT  •  Powered by Nexus UI
--=====================================================================

-- 1. Automatically download and load the UI Library if it's not already loaded
local Library = getgenv().NexusUI
if not Library then
    Library = loadstring(game:HttpGet("https://rawcdn.githack.com/ArtsoRBLX/Nexus-Library/refs/heads/main/NexusLib.lua"))()
    getgenv().NexusUI = Library
end

-- 2. Create the UI
local Window = Library:CreateWindow({
    Title = "My Awesome Script",
    Subtitle = "Working perfectly",
    IconId = 6031097226
})

-- 3. Create Tabs and Sections
local MainTab = Window:Tab("Main", "🏠")
local PlayerSec = MainTab:Section({ Name = "Player Features", Side = "Left" })

-- 4. Add Features
PlayerSec:Toggle({
    Name = "Infinite Jump",
    Icon = "🦘",
    Flag = "inf_jump",
    Callback = function(val)
        print("Infinite Jump:", val)
    end
})

Window:Notify({
    Title = "Loaded",
    Text = "Script loaded successfully!",
    Color = Library.Theme.Success
})
