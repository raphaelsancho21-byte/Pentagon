-- [[ Petagon UI Library Example Usage ]]
-- Para executar via GitHub (Requer Loadstring habilitado no Executor):
local Petagon = loadstring(game:HttpGet("https://raw.githubusercontent.com/raphaelsancho21-byte/Pentagon/refs/heads/main/Pentagon.lua"))()

-- DICA: Se quiser testar SEM usar o GitHub (sem loadstring), 
-- basta copiar o conteúdo do arquivo Petagon.lua e colar aqui no topo deste script!

local Window = Petagon:CreateWindow({
    Name = "Petagon Premium | Script Hub",
    LoadingTitle = "Petagon UI",
    LoadingSubtitle = "by Antigravity"
})

-- [[ Key System ]]
-- Note: Authentication now saves as .json and includes a Username for config separation.
Window:CreateKeySystem({
    Key = {"petagon2024"},
    Title = "Access Control",
    Subtitle = "Enter your secret key & profile",
    Note = "Check our Discord for keys!",
    FileName = "Petagon_Auth",
    SaveKey = true
})

-- [[ Main Tab - Features ]]
local MainTab = Window:CreateTab("Features")

MainTab:CreateButton({
    Name = "Show Notification",
    Callback = function()
        Petagon:Notify({
            Title = "Petagon UI",
            Content = "This is a fixed notification! It looks amazing and works perfectly.",
            Duration = 5
        })
    end
})

MainTab:CreateToggle({
    Name = "Auto Farm",
    CurrentValue = false,
    Callback = function(Value)
        Petagon:Notify({
            Title = "Auto Farm",
            Content = "Logic is now " .. (Value and "Active" or "Inactive"),
            Duration = 2
        })
    end
})

-- [[ Movement Tab ]]
local MoveTab = Window:CreateTab("Movement")

MoveTab:CreateSlider({
    Name = "Walk Speed",
    Range = {16, 250},
    CurrentValue = 16,
    Callback = function(Value)
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end
})

MoveTab:CreateKeybind({
    Name = "Speed Boost Key",
    CurrentKey = Enum.KeyCode.Q,
    Callback = function(Key)
        Petagon:Notify({
            Title = "Keybind Match",
            Content = "You Pressed: " .. Key.Name,
            Duration = 2
        })
    end
})

MoveTab:CreateInput({
    Name = "Jump Power",
    PlaceholderText = "Default: 50",
    Callback = function(Value)
        local Num = tonumber(Value)
        if Num and game.Players.LocalPlayer.Character then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = Num
        end
    end
})

-- [[ Settings Tab ]]
-- This creates a fixed tab with Theme Switching and Destroy options
Window:CreateSettingsTab()

-- Initial Notification
Petagon:Notify({
    Title = "Welcome to Petagon!",
    Content = "The library is now more beautiful and powerful. Enjoy!",
    Duration = 5
})
