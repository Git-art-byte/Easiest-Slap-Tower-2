local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

Fluent:Notify({
        Title = "Thanks You!",
        Content = "Thank you for using Our Script.",
        SubContent = "Enjoy!", -- Optional
        Duration = 6 -- Set to nil to make the notification not disappear
})

SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

local Window = Fluent:CreateWindow({
    Title = "Troll Easiest Tower 2 👋" .. Fluent.Version,
    SubTitle = "by Haroun",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = true,
    Theme = "Aqua",
    MinimizeKey = Enum.KeyCode.LeftControl
})

-- Tabs
local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "life-buoy" }),
    Player = Window:AddTab({ Title = "Player", Icon = "user" }),
    Scripts = Window:AddTab({ Title = "Scripts", Icon = "info" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Must come after Tabs are created
InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

-- Toggle
local runningMoneyLoop = false

local MoneyToggle = Tabs.Main:AddToggle("MoneyToggle", {
    Title = "Infinite Money [OP]",
    Description = "Gives Inf Money ",
    Default = false,
    Callback = function(state)
        runningMoneyLoop = state
        if state then
            print("Money Toggle On")
            task.spawn(function()
                while runningMoneyLoop do
                    local args = { "999999999999999999" }

                    local success, err = pcall(function()
                        game:GetService("ReplicatedStorage")
                            :WaitForChild("CratesUtilities")
                            :WaitForChild("Remotes")
                            :WaitForChild("GiveReward")
                            :FireServer(unpack(args))
                    end)

                    if not success then
                        warn("Failed to fire GiveReward:", err)
                    end

                    task.wait(0.000000001) -- adjust delay to avoid detection
                end
            end)
        else
            print("Money Toggle Off")
        end
    end
})


local WalkSpeedInput = Tabs.Player:AddInput("WalkSpeedInput", {
    Title = "WalkSpeed",
    Description = "Enter a WalkSpeed value",
    Default = "16", -- Default Roblox walk speed
    Placeholder = "e.g. 50",
    Numeric = true, -- Only allows numbers
    Finished = true, -- Only calls callback when Enter is pressed
    Callback = function(Value)
        local speed = tonumber(Value)
        if speed then
            local character = game:GetService("Players").LocalPlayer.Character
            if character and character:FindFirstChildOfClass("Humanoid") then
                character:FindFirstChildOfClass("Humanoid").WalkSpeed = speed
                print("WalkSpeed set to:", speed)
            else
                warn("Character or Humanoid not found.")
            end
        else
            warn("Invalid number entered.")
        end
    end
})

local JumpPowerInput = Tabs.Player:AddInput("JumpPowerInput", {
    Title = "JumpPower",
    Description = "Enter a JumpPower value",
    Default = "50", -- Default Roblox jump power
    Placeholder = "e.g. 100",
    Numeric = true,
    Finished = true,
    Callback = function(Value)
        local jumpPower = tonumber(Value)
        if jumpPower then
            local character = game:GetService("Players").LocalPlayer.Character
            if character then
                local humanoid = character:FindFirstChildOfClass("Humanoid")
                if humanoid then
                    humanoid.UseJumpPower = true -- ✅ This is the key fix
                    humanoid.JumpPower = jumpPower
                    print("JumpPower set to:", jumpPower)
                else
                    warn("Humanoid not found.")
                end
            else
                warn("Character not found.")
            end
        else
            warn("Invalid number entered.")
        end
    end
})


local infiniteJumpEnabled = false

local InfiniteJumpToggle = Tabs.Player:AddToggle("InfiniteJumpToggle", {
    Title = "Infinite Jump",
    Description = "Enables infinite jumping",
    Default = false,
    Callback = function(state)
        infiniteJumpEnabled = state
        if state then
            print("Infinite Jump: ON")
        else
            print("Infinite Jump: OFF")
        end
    end
})

-- Hook into UserInputService to detect jumps
local UserInputService = game:GetService("UserInputService")
UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then
        local character = game:GetService("Players").LocalPlayer.Character
        if character and character:FindFirstChildOfClass("Humanoid") then
            character:FindFirstChildOfClass("Humanoid"):ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

local noclipEnabled = false
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local NoclipToggle = Tabs.Player:AddToggle("NoclipToggle", {
    Title = "Noclip",
    Description = "Walk through walls and objects",
    Default = false,
    Callback = function(state)
        noclipEnabled = state
        if state then
            print("Noclip: ON")
        else
            print("Noclip: OFF")
        end
    end
})

-- Loop to disable collisions when noclip is on
RunService.Stepped:Connect(function()
    if noclipEnabled then
        local character = LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") and part.CanCollide == true then
                    part.CanCollide = false
                end
            end
        end
    end
end)


local rewardAmount = "0"

local MoneyInput = Tabs.Main:AddInput("MoneyInput", {
    Title = "Money Amount",
    Description = "Enter the amount to give",
    Default = "",
    Placeholder = "",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        rewardAmount = tostring(Value)
        print("Reward amount set to:", rewardAmount)
    end
})

-- Buttons
Tabs.Main:AddButton({
    Title = "Give Money",
    Description = "Generate Money",
    Callback = function()
        if rewardAmount == "0" or rewardAmount == "" then
            warn("Invalid input amount.")
            return
        end

        local args = { rewardAmount }

        game:GetService("ReplicatedStorage"):WaitForChild("CratesUtilities")
            :WaitForChild("Remotes")
            :WaitForChild("GiveReward"):FireServer(unpack(args))

        print("Fired GiveReward with:", rewardAmount)
    end
})

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- CratesUtilities rewards
local crateRewards = {
    "Carpet",
    "Glove"
}

-- Money_Remotes rewards
local moneyRewards = {
    "Quantum",
    "GodEvent",
    "AdminEvent",
    "FireCoil",
    "VoidCoil",
    "GoldenCoil"
}

-- Function to fire crate reward
local function fireCrateReward(name)
    local crates = ReplicatedStorage:FindFirstChild("CratesUtilities")
    if crates and crates:FindFirstChild("Remotes") then
        local remote = crates.Remotes:FindFirstChild("GiveReward")
        if remote then
            remote:FireServer(name)
        end
    end
end

-- Function to fire money reward
local function fireMoneyReward(name)
    local moneyRemotes = ReplicatedStorage:FindFirstChild("Money_Remotes")
    if moneyRemotes then
        local remote = moneyRemotes:FindFirstChild(name)
        if remote then
            remote:FireServer(LocalPlayer)
        end
    end
end

-- Add the button
Tabs.Main:AddButton({
    Title = "Get All Tools",
    Description = "Gives you all Tools",
    Callback = function()
        -- Fire CrateUtilities rewards
        for _, name in ipairs(crateRewards) do
            fireCrateReward(name)
        end

        -- Fire Money_Remotes rewards
        for _, name in ipairs(moneyRewards) do
            fireMoneyReward(name)
        end

        print("All rewards fired once.")
    end

	local args = {
	game:GetService("Players"):WaitForChild("Xxx_Tentation318")
}
game:GetService("ReplicatedStorage"):WaitForChild("FreeGear_Remotes"):WaitForChild("FreeGearEvent"):FireServer(unpack(args))
})

local args = {
	game:GetService("Players"):WaitForChild("Xxx_Tentation318")
}
game:GetService("ReplicatedStorage"):WaitForChild("FreeGear_Remotes"):WaitForChild("FreeGearEvent"):FireServer(unpack(args))

local args = {
	game:GetService("Players"):WaitForChild("Xxx_Tentation318")
}
game:GetService("ReplicatedStorage"):WaitForChild("FreeGear_Remotes"):WaitForChild("FreeGearEvent"):FireServer(unpack(args))

-- List of glove names to equip and check
local gloveNames = {
    "GiantGlove",
    "GodlyGlove",
    "SlapGlove",
    "Quantum_glove",
    "Slap",
    "SecretSlap",
    "FreeSlap",
    "HackerSlap",
    "Skull_glove"
}

-- Function to auto-equip the first available glove from Backpack
local function autoEquipGlove()
    local LocalPlayer = game:GetService("Players").LocalPlayer
    local Backpack = LocalPlayer:FindFirstChild("Backpack")

    if not Backpack then return end

    for _, name in ipairs(gloveNames) do
        local glove = Backpack:FindFirstChild(name)
        if glove then
            glove.Parent = LocalPlayer.Character
            task.wait(0.1) -- small delay to allow glove to register
            return glove
        end
    end
end

-- Function to get the equipped glove in Character
local function getEquippedGlove()
    local character = game:GetService("Players").LocalPlayer.Character
    if not character then return nil end

    for _, name in ipairs(gloveNames) do
        local glove = character:FindFirstChild(name)
        if glove and glove:FindFirstChild("Event") then
            return glove
        end
    end
    return nil
end

-- Toggle for auto-equip and loop slap
local slapLoopRunning = false
Tabs.Main:AddToggle("AutoEquipLoopSlapToggle", {
    Title = "LoopSlap All [OP]",
    Description = "slaps everyone in the server repeatedly except you",
    Default = false,
    Callback = function(state)
        slapLoopRunning = state
        if state then
            print("Slap All loop started.")

            task.spawn(function()
                while slapLoopRunning do
                    local Players = game:GetService("Players")
                    local LocalPlayer = Players.LocalPlayer

                    -- Auto-equip if no glove equipped
                    local glove = getEquippedGlove()
                    if not glove then
                        autoEquipGlove()
                        glove = getEquippedGlove()
                    end

                    if glove then
                        for _, player in pairs(Players:GetPlayers()) do
                            if player ~= LocalPlayer and player.Character then
                                local args = {
                                    "slash",
                                    player.Character,
                                    Vector3.new(-2.4623, 1.59e-07, -11.7446)
                                }
                                glove.Event:FireServer(unpack(args))
                            end
                        end
                    else
                        warn("No valid glove equipped or found in backpack!")
                    end

                    task.wait(0.1) -- adjust for spam speed
                end
            end)
        else
            print("Slap All loop stopped.")
        end
    end
})


Tabs.Scripts:AddButton({
    Title = "Infinite Yield",
    Description = "",
    Callback = function()
        loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
    end
})

Tabs.Scripts:AddButton({
    Title = "Realistic Graphics",
    Description = "",
    Callback = function()
        loadstring(game:HttpGet("https://pastebin.com/raw/uqD7VqQU"))()
    end
})

-- Store selected player name
local selectedPlayer = nil

-- Generate player names (excluding local player)
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local function getPlayerNames()
    local names = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(names, player.Name)
        end
    end
    return names
end

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local selectedPlayer = nil

-- Function to return a list of all player names except the local player
local function getPlayerNames()
    local names = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(names, player.Name)
        end
    end
    return names
end

-- List of glove names to equip and use
local gloveNames = {
    "GiantGlove",
    "GodlyGlove",
    "SlapGlove",
    "Quantum_glove",
    "Slap",
    "SecretSlap",
    "FreeSlap",
    "HackerSlap",
    "Skull_glove"
}

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Get equipped glove in character
local function getEquippedGlove()
    local character = LocalPlayer.Character
    if not character then return nil end

    for _, name in ipairs(gloveNames) do
        local glove = character:FindFirstChild(name)
        if glove and glove:FindFirstChild("Event") then
            return glove
        end
    end
    return nil
end

-- Try to equip glove from backpack
local function autoEquipGlove()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return end

    for _, name in ipairs(gloveNames) do
        local glove = backpack:FindFirstChild(name)
        if glove then
            glove.Parent = LocalPlayer.Character
            task.wait(0.1) -- wait for it to equip
            return true
        end
    end
end

-- Dropdown (you already have this)
local PlayerDropdown = Tabs.Main:AddDropdown("SlapPlayerDropdown", {
    Title = "Select a Player",
    Description = "Choose a player to slap them",
    Values = getPlayerNames(),
    Multi = false,
    Default = nil,
    Callback = function(value)
        selectedPlayer = value
        print("Selected player to slap:", selectedPlayer)
    end
})

-- Auto refresh dropdown
Players.PlayerAdded:Connect(function()
    PlayerDropdown:SetValues(getPlayerNames())
end)
Players.PlayerRemoving:Connect(function()
    PlayerDropdown:SetValues(getPlayerNames())
end)

-- Slap Button with auto-equip
Tabs.Main:AddButton({
    Title = "Slap",
    Description = "Slap selected player",
    Callback = function()
        if not selectedPlayer then
            warn("No player selected!")
            return
        end

        local targetPlayer = Players:FindFirstChild(selectedPlayer)
        if not targetPlayer or not targetPlayer.Character then
            warn("Target player not found or has no character.")
            return
        end

        -- Ensure glove is equipped
        local glove = getEquippedGlove()
        if not glove then
            autoEquipGlove()
            glove = getEquippedGlove()
        end

        if not glove or not glove:FindFirstChild("Event") then
            warn("No valid glove equipped or Event missing.")
            return
        end

        -- Slap
        local args = {
            "slash",
            targetPlayer.Character,
            Vector3.new(-2.4623, 1.59e-07, -11.7446)
        }

        glove.Event:FireServer(unpack(args))
        print("Slapped", selectedPlayer)
    end
})


Tabs.Main:AddButton({
    Title = "Fly [OP]",
    Description = "Make u fly",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/XNEOFF/FlyGuiV3/main/FlyGuiV3.txt"))()
    end
})
