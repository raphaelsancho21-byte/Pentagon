local Petagon = {}

-- [[ Services ]]
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- [[ Variables ]]
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- [[ Visibility Globals ]]
local UIVisible = true
local ToggleKey = Enum.KeyCode.RightControl
local MobileButton = nil

-- [[ Configuration ]]
local Themes = {
    Dark = {
        MainColor = Color3.fromRGB(15, 16, 22),
        SecondaryColor = Color3.fromRGB(22, 23, 30),
        AccentColor = Color3.fromRGB(123, 44, 191),
        TextColor = Color3.fromRGB(255, 255, 255),
        TextSecondaryColor = Color3.fromRGB(180, 180, 180),
        Font = Enum.Font.Gotham,
        Rounding = 8,
        Gradient = {Color3.fromRGB(123, 44, 191), Color3.fromRGB(60, 20, 100)}
    },
    Light = {
        MainColor = Color3.fromRGB(245, 245, 250),
        SecondaryColor = Color3.fromRGB(230, 230, 235),
        AccentColor = Color3.fromRGB(0, 120, 255),
        TextColor = Color3.fromRGB(30, 30, 35),
        TextSecondaryColor = Color3.fromRGB(100, 100, 110),
        Font = Enum.Font.Gotham,
        Rounding = 8,
        Gradient = {Color3.fromRGB(0, 120, 255), Color3.fromRGB(0, 200, 255)}
    },
    Blue = {
        MainColor = Color3.fromRGB(10, 20, 35),
        SecondaryColor = Color3.fromRGB(15, 25, 45),
        AccentColor = Color3.fromRGB(0, 210, 255),
        TextColor = Color3.fromRGB(255, 255, 255),
        TextSecondaryColor = Color3.fromRGB(160, 180, 200),
        Font = Enum.Font.Gotham,
        Rounding = 8,
        Gradient = {Color3.fromRGB(0, 180, 255), Color3.fromRGB(0, 100, 200)}
    }
}

local CurrentTheme = Themes.Dark
local GlobalObjects = {} -- For dynamic theme updates

-- [[ Utility Functions ]]
local function ApplyGradient(Parent, Colors)
    local UIGradient = Instance.new("UIGradient")
    UIGradient.Color = ColorSequence.new(Colors[1], Colors[2])
    UIGradient.Rotation = 45
    UIGradient.Parent = Parent
    return UIGradient
end

local function AddStroke(Parent, Color, Thickness, Transparency)
    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Color
    UIStroke.Thickness = Thickness or 1
    UIStroke.Transparency = Transparency or 0.5
    UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    UIStroke.Parent = Parent
    return UIStroke
end

local function MakeDraggable(TopBar, Main)
    local Dragging = nil
    local DragInput = nil
    local DragStart = nil
    local StartPos = nil

    local function Update(Input)
        local Delta = Input.Position - DragStart
        Main.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
    end

    TopBar.InputBegan:Connect(function(Input)
        if (Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch) then
            Dragging = true
            DragStart = Input.Position
            StartPos = Main.Position

            Input.Changed:Connect(function()
                if (Input.UserInputState == Enum.UserInputState.End) then
                    Dragging = false
                end
            end)
        end
    end)

    TopBar.InputChanged:Connect(function(Input)
        if (Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch) then
            DragInput = Input
        end
    end)

    UserInputService.InputChanged:Connect(function(Input)
        if (Input == DragInput and Dragging) then
            Update(Input)
        end
    end)
end

function Petagon:ApplyTheme(ThemeName)
    if Themes[ThemeName] then
        CurrentTheme = Themes[ThemeName]
        for Obj, Type in pairs(GlobalObjects) do
            if Obj and Obj.Parent then
                if Type == "Main" then
                    Obj.BackgroundColor3 = CurrentTheme.MainColor
                elseif Type == "Secondary" then
                    Obj.BackgroundColor3 = CurrentTheme.SecondaryColor
                elseif Type == "Accent" then
                    Obj.BackgroundColor3 = CurrentTheme.AccentColor
                    if Obj:FindFirstChild("UIGradient") then
                        Obj.UIGradient.Color = ColorSequence.new(CurrentTheme.Gradient[1], CurrentTheme.Gradient[2])
                    end
                elseif Type == "Text" then
                    Obj.TextColor3 = CurrentTheme.TextColor
                elseif Type == "TextSecondary" then
                    Obj.TextColor3 = CurrentTheme.TextSecondaryColor
                elseif Type == "Stroke" then
                    Obj.Color = CurrentTheme.AccentColor
                end
            end
        end
    end
end

function Petagon:ToggleUI()
    if not self.PetagonGui then return end
    UIVisible = not UIVisible
    self.PetagonGui.Main.Visible = UIVisible
    
    if MobileButton then
        MobileButton.Visible = not UIVisible
    end
end

function Petagon:CreateWindow(Options)
    Options = Options or {}
    local WindowTitle = Options.Name or "Petagon UI"
    
    local PetagonGui = Instance.new("ScreenGui")
    PetagonGui.Name = "Petagon"
    PetagonGui.Parent = CoreGui
    PetagonGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    Petagon.PetagonGui = PetagonGui

    -- [[ Global Toggle Listener ]]
    UserInputService.InputBegan:Connect(function(Input, Processed)
        if not Processed and Input.UserInputType == Enum.UserInputType.Keyboard then
            if Input.KeyCode == ToggleKey then
                Petagon:ToggleUI()
            end
        end
    end)

    -- [[ Mobile Button Helper ]]
    local function CreateMobileButton()
        if MobileButton then MobileButton:Destroy() end
        
        MobileButton = Instance.new("TextButton")
        MobileButton.Name = "PetagonMobile"
        MobileButton.Parent = PetagonGui
        MobileButton.BackgroundColor3 = CurrentTheme.AccentColor
        MobileButton.Position = UDim2.new(0, 20, 0.5, -20)
        MobileButton.Size = UDim2.new(0, 40, 0, 40)
        MobileButton.Font = Enum.Font.GothamBold
        MobileButton.Text = "P"
        MobileButton.TextColor3 = CurrentTheme.TextColor
        MobileButton.TextSize = 20
        MobileButton.Visible = not UIVisible
        GlobalObjects[MobileButton] = "Accent"

        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(1, 0)
        Corner.Parent = MobileButton
        
        ApplyGradient(MobileButton, CurrentTheme.Gradient)
        AddStroke(MobileButton, CurrentTheme.TextColor, 2, 0.8)

        -- Make it draggable
        local Dragging = false
        local DragStart, StartPos
        
        MobileButton.InputBegan:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.Touch or Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = true
                DragStart = Input.Position
                StartPos = MobileButton.Position
            end
        end)

        UserInputService.InputChanged:Connect(function(Input)
            if Dragging and (Input.UserInputType == Enum.UserInputType.Touch or Input.UserInputType == Enum.UserInputType.MouseMovement) then
                local Delta = Input.Position - DragStart
                MobileButton.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
            end
        end)

        UserInputService.InputEnded:Connect(function(Input)
            if Input.UserInputType == Enum.UserInputType.Touch or Input.UserInputType == Enum.UserInputType.MouseButton1 then
                Dragging = false
            end
        end)

        MobileButton.MouseButton1Click:Connect(function()
            Petagon:ToggleUI()
        end)
    end
    
    -- Auto-detect Mobile
    if UserInputService.TouchEnabled then
        CreateMobileButton()
    end
    Main.Name = "Main"
    Main.Parent = PetagonGui
    Main.BackgroundColor3 = CurrentTheme.MainColor
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Position = UDim2.new(0.5, -250, 0.5, -175)
    Main.Size = UDim2.new(0, 500, 0, 350)
    GlobalObjects[Main] = "Main"

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, 10)
    UICorner.Parent = Main

    local UIStroke = AddStroke(Main, CurrentTheme.AccentColor, 1.5, 0.4)
    GlobalObjects[UIStroke] = "Stroke"

    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = Main
    TopBar.BackgroundColor3 = CurrentTheme.SecondaryColor
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    GlobalObjects[TopBar] = "Secondary"

    local TopBarCorner = Instance.new("UICorner")
    TopBarCorner.CornerRadius = UDim.new(0, 10)
    TopBarCorner.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = TopBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Size = UDim2.new(1, -30, 1, 0)
    Title.Font = Enum.Font.GothamBold
    Title.Text = WindowTitle
    Title.TextColor3 = CurrentTheme.TextColor
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left
    GlobalObjects[Title] = "Text"

    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = Main
    Sidebar.BackgroundColor3 = CurrentTheme.SecondaryColor
    Sidebar.BorderSizePixel = 0
    Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Sidebar.Size = UDim2.new(0, 140, 1, -40)
    GlobalObjects[Sidebar] = "Secondary"

    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, CurrentTheme.Rounding)
    SidebarCorner.Parent = Sidebar

    local Container = Instance.new("Frame")
    Container.Name = "Container"
    Container.Parent = Main
    Container.BackgroundTransparency = 1
    Container.Position = UDim2.new(0, 140, 0, 40)
    Container.Size = UDim2.new(1, -140, 1, -40)

    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = Sidebar
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.Position = UDim2.new(0, 5, 0, 5)
    TabContainer.Size = UDim2.new(1, -10, 1, -10)
    TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContainer.ScrollBarThickness = 0

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.Parent = TabContainer
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 5)

    MakeDraggable(TopBar, Main)

    local Window = {
        CurrentTab = nil
    }

    function Window:CreateTab(Name)
        local TabButton = Instance.new("TextButton")
        TabButton.Name = Name .. "Tab"
        TabButton.Parent = TabContainer
        TabButton.BackgroundColor3 = CurrentTheme.MainColor
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(1, 0, 0, 30)
        TabButton.Font = CurrentTheme.Font
        TabButton.Text = Name
        TabButton.TextColor3 = CurrentTheme.TextSecondaryColor
        TabButton.TextSize = 14
        TabButton.AutoButtonColor = false

        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton

        local TabPage = Instance.new("ScrollingFrame")
        TabPage.Name = Name .. "Page"
        TabPage.Parent = Container
        TabPage.BackgroundTransparency = 1
        TabPage.BorderSizePixel = 0
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.Visible = false
        TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabPage.ScrollBarThickness = 2
        TabPage.ScrollBarImageColor3 = CurrentTheme.AccentColor

        local PageListLayout = Instance.new("UIListLayout")
        PageListLayout.Parent = TabPage
        PageListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageListLayout.Padding = UDim.new(0, 8)

        local PagePadding = Instance.new("UIPadding")
        PagePadding.Parent = TabPage
        PagePadding.PaddingLeft = UDim.new(0, 10)
        PagePadding.PaddingRight = UDim.new(0, 10)
        PagePadding.PaddingTop = UDim.new(0, 10)

        GlobalObjects[TabButton] = "Secondary"
        GlobalObjects[TabPage] = "Main"

        TabButton.MouseButton1Click:Connect(function()
            if Window.CurrentTab then
                Window.CurrentTab.Button.TextColor3 = CurrentTheme.TextSecondaryColor
                TweenService:Create(Window.CurrentTab.Button, TweenInfo.new(0.3), {BackgroundColor3 = CurrentTheme.MainColor}):Play()
                Window.CurrentTab.Page.Visible = false
            end
            
            TabButton.TextColor3 = CurrentTheme.TextColor
            TweenService:Create(TabButton, TweenInfo.new(0.3), {BackgroundColor3 = CurrentTheme.AccentColor}):Play()
            TabPage.Visible = true
            Window.CurrentTab = {Button = TabButton, Page = TabPage}
        end)

        -- Select first tab by default
        if not Window.CurrentTab then
            TabButton.TextColor3 = CurrentTheme.TextColor
            TabButton.BackgroundColor3 = CurrentTheme.AccentColor
            TabPage.Visible = true
            Window.CurrentTab = {Button = TabButton, Page = TabPage}
        end

        local Tab = {}
        
        function Tab:CreateButton(ElementOptions)
            ElementOptions = ElementOptions or {}
            local Name = ElementOptions.Name or "Button"
            local Callback = ElementOptions.Callback or function() end

            local ButtonFrame = Instance.new("Frame")
            ButtonFrame.Name = Name .. "Button"
            ButtonFrame.Parent = TabPage
            ButtonFrame.BackgroundColor3 = CurrentTheme.SecondaryColor
            ButtonFrame.Size = UDim2.new(1, 0, 0, 38)
            GlobalObjects[ButtonFrame] = "Secondary"

            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 8)
            ButtonCorner.Parent = ButtonFrame
            
            AddStroke(ButtonFrame, CurrentTheme.AccentColor, 1, 0.7)

            local TextBtn = Instance.new("TextButton")
            TextBtn.Parent = ButtonFrame
            TextBtn.BackgroundTransparency = 1
            TextBtn.Size = UDim2.new(1, 0, 1, 0)
            TextBtn.Font = Enum.Font.GothamMedium
            TextBtn.Text = Name
            TextBtn.TextColor3 = CurrentTheme.TextColor
            TextBtn.TextSize = 14
            GlobalObjects[TextBtn] = "Text"

            TextBtn.MouseButton1Click:Connect(function()
                Callback()
                local OriginalColor = ButtonFrame.BackgroundColor3
                TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = CurrentTheme.AccentColor}):Play()
                task.wait(0.1)
                TweenService:Create(ButtonFrame, TweenInfo.new(0.2), {BackgroundColor3 = OriginalColor}):Play()
            end)

            return {
                SetText = function(self, NewText)
                    TextBtn.Text = NewText
                end
            }
        end

        function Tab:CreateToggle(ElementOptions)
            ElementOptions = ElementOptions or {}
            local Name = ElementOptions.Name or "Toggle"
            local Default = ElementOptions.CurrentValue or false
            local Callback = ElementOptions.Callback or function() end

            local Toggled = Default

            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Name = Name .. "Toggle"
            ToggleFrame.Parent = TabPage
            ToggleFrame.BackgroundColor3 = CurrentTheme.SecondaryColor
            ToggleFrame.Size = UDim2.new(1, 0, 0, 38)
            GlobalObjects[ToggleFrame] = "Secondary"

            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 8)
            ToggleCorner.Parent = ToggleFrame
            
            AddStroke(ToggleFrame, CurrentTheme.AccentColor, 1, 0.6)

            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Parent = ToggleFrame
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Position = UDim2.new(0, 12, 0, 0)
            ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
            ToggleLabel.Font = Enum.Font.GothamMedium
            ToggleLabel.Text = Name
            ToggleLabel.TextColor3 = CurrentTheme.TextColor
            ToggleLabel.TextSize = 14
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            GlobalObjects[ToggleLabel] = "Text"

            local Switch = Instance.new("Frame")
            Switch.Name = "Switch"
            Switch.Parent = ToggleFrame
            Switch.BackgroundColor3 = Toggled and CurrentTheme.AccentColor or CurrentTheme.MainColor
            Switch.Position = UDim2.new(1, -50, 0.5, -11)
            Switch.Size = UDim2.new(0, 38, 0, 22)
            GlobalObjects[Switch] = Toggled and "Accent" or "Main"
            
            local SwitchCorner = Instance.new("UICorner")
            SwitchCorner.CornerRadius = UDim.new(1, 0)
            SwitchCorner.Parent = Switch

            local Circle = Instance.new("Frame")
            Circle.Name = "Circle"
            Circle.Parent = Switch
            Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Circle.Position = Toggled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
            Circle.Size = UDim2.new(0, 18, 0, 18)

            local CircleCorner = Instance.new("UICorner")
            CircleCorner.CornerRadius = UDim.new(1, 0)
            CircleCorner.Parent = Circle

            local ClickBtn = Instance.new("TextButton")
            ClickBtn.Parent = ToggleFrame
            ClickBtn.BackgroundTransparency = 1
            ClickBtn.Size = UDim2.new(1, 0, 1, 0)
            ClickBtn.Text = ""

            ClickBtn.MouseButton1Click:Connect(function()
                Toggled = not Toggled
                local TargetPos = Toggled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
                local TargetColor = Toggled and CurrentTheme.AccentColor or CurrentTheme.MainColor
                
                TweenService:Create(Circle, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Position = TargetPos}):Play()
                TweenService:Create(Switch, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundColor3 = TargetColor}):Play()
                GlobalObjects[Switch] = Toggled and "Accent" or "Main"
                
                Callback(Toggled)
            end)

            return {
                Set = function(self, NewValue)
                    Toggled = NewValue
                    local TargetPos = Toggled and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
                    local TargetColor = Toggled and CurrentTheme.AccentColor or CurrentTheme.MainColor
                    TweenService:Create(Circle, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Position = TargetPos}):Play()
                    TweenService:Create(Switch, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundColor3 = TargetColor}):Play()
                    GlobalObjects[Switch] = Toggled and "Accent" or "Main"
                    Callback(Toggled)
                end
            }
        end

        function Tab:CreateSlider(ElementOptions)
            ElementOptions = ElementOptions or {}
            local Name = ElementOptions.Name or "Slider"
            local Min = ElementOptions.Range[1] or 0
            local Max = ElementOptions.Range[2] or 100
            local Default = ElementOptions.CurrentValue or Min
            local Callback = ElementOptions.Callback or function() end

            local Value = Default

            local SliderFrame = Instance.new("Frame")
            SliderFrame.Name = Name .. "Slider"
            SliderFrame.Parent = TabPage
            SliderFrame.BackgroundColor3 = CurrentTheme.SecondaryColor
            SliderFrame.Size = UDim2.new(1, 0, 0, 48)
            GlobalObjects[SliderFrame] = "Secondary"

            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 8)
            SliderCorner.Parent = SliderFrame
            
            AddStroke(SliderFrame, CurrentTheme.AccentColor, 1, 0.6)

            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Parent = SliderFrame
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.Position = UDim2.new(0, 12, 0, 6)
            SliderLabel.Size = UDim2.new(1, -20, 0, 20)
            SliderLabel.Font = Enum.Font.GothamMedium
            SliderLabel.Text = Name
            SliderLabel.TextColor3 = CurrentTheme.TextColor
            SliderLabel.TextSize = 14
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            GlobalObjects[SliderLabel] = "Text"

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Parent = SliderFrame
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Position = UDim2.new(0, 10, 0, 6)
            ValueLabel.Size = UDim2.new(1, -20, 0, 20)
            ValueLabel.Font = Enum.Font.Gotham
            ValueLabel.Text = tostring(Value)
            ValueLabel.TextColor3 = CurrentTheme.TextSecondaryColor
            ValueLabel.TextSize = 12
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            GlobalObjects[ValueLabel] = "TextSecondary"

            local Track = Instance.new("Frame")
            Track.Name = "Track"
            Track.Parent = SliderFrame
            Track.BackgroundColor3 = CurrentTheme.MainColor
            Track.Position = UDim2.new(0, 12, 1, -14)
            Track.Size = UDim2.new(1, -24, 0, 4)
            GlobalObjects[Track] = "Main"

            local Progress = Instance.new("Frame")
            Progress.Name = "Progress"
            Progress.Parent = Track
            Progress.BackgroundColor3 = CurrentTheme.AccentColor
            Progress.Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0)
            GlobalObjects[Progress] = "Accent"
            ApplyGradient(Progress, CurrentTheme.Gradient)

            local SliderBtn = Instance.new("TextButton")
            SliderBtn.Parent = Track
            SliderBtn.BackgroundTransparency = 1
            SliderBtn.Size = UDim2.new(1, 0, 1, 0)
            SliderBtn.Text = ""

            local function Move()
                local MousePos = UserInputService:GetMouseLocation().X
                local TrackPos = Track.AbsolutePosition.X
                local TrackSize = Track.AbsoluteSize.X
                local Percentage = math.clamp((MousePos - TrackPos) / TrackSize, 0, 1)
                
                Value = math.floor(Min + (Max - Min) * Percentage)
                Progress.Size = UDim2.new(Percentage, 0, 1, 0)
                ValueLabel.Text = tostring(Value)
                Callback(Value)
            end

            local Dragging = false
            SliderBtn.InputBegan:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = true
                    Move()
                end
            end)

            UserInputService.InputEnded:Connect(function(Input)
                if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                    Dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(Input)
                if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
                    Move()
                end
            end)

            return {
                Set = function(self, NewValue)
                    Value = NewValue
                    Progress.Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0)
                    ValueLabel.Text = tostring(Value)
                    Callback(Value)
                end
            }
        end

        function Tab:CreateInput(ElementOptions)
            ElementOptions = ElementOptions or {}
            local Name = ElementOptions.Name or "Input"
            local Placeholder = ElementOptions.PlaceholderText or "Type here..."
            local Callback = ElementOptions.Callback or function() end

            local InputFrame = Instance.new("Frame")
            InputFrame.Name = Name .. "Input"
            InputFrame.Parent = TabPage
            InputFrame.BackgroundColor3 = CurrentTheme.SecondaryColor
            InputFrame.Size = UDim2.new(1, 0, 0, 38)
            GlobalObjects[InputFrame] = "Secondary"

            local InputCorner = Instance.new("UICorner")
            InputCorner.CornerRadius = UDim.new(0, 8)
            InputCorner.Parent = InputFrame
            
            AddStroke(InputFrame, CurrentTheme.AccentColor, 1, 0.6)

            local InputLabel = Instance.new("TextLabel")
            InputLabel.Parent = InputFrame
            InputLabel.BackgroundTransparency = 1
            InputLabel.Position = UDim2.new(0, 12, 0, 0)
            InputLabel.Size = UDim2.new(0.4, -10, 1, 0)
            InputLabel.Font = Enum.Font.GothamMedium
            InputLabel.Text = Name
            InputLabel.TextColor3 = CurrentTheme.TextColor
            InputLabel.TextSize = 14
            InputLabel.TextXAlignment = Enum.TextXAlignment.Left
            GlobalObjects[InputLabel] = "Text"

            local BoxHolder = Instance.new("Frame")
            BoxHolder.Parent = InputFrame
            BoxHolder.BackgroundColor3 = CurrentTheme.MainColor
            BoxHolder.Position = UDim2.new(0.42, 0, 0.5, -13)
            BoxHolder.Size = UDim2.new(0.58, -12, 0, 26)
            GlobalObjects[BoxHolder] = "Main"
            
            local BoxCorner = Instance.new("UICorner")
            BoxCorner.CornerRadius = UDim.new(0, 6)
            BoxCorner.Parent = BoxHolder

            local TextBox = Instance.new("TextBox")
            TextBox.Parent = BoxHolder
            TextBox.BackgroundTransparency = 1
            TextBox.Position = UDim2.new(0, 8, 0, 0)
            TextBox.Size = UDim2.new(1, -16, 1, 0)
            TextBox.Font = Enum.Font.Gotham
            TextBox.PlaceholderText = Placeholder
            TextBox.Text = ""
            TextBox.TextColor3 = CurrentTheme.TextColor
            TextBox.PlaceholderColor3 = CurrentTheme.TextSecondaryColor
            TextBox.TextSize = 12
            TextBox.TextXAlignment = Enum.TextXAlignment.Left
            GlobalObjects[TextBox] = "Text"

            TextBox.FocusLost:Connect(function(EnterPressed)
                Callback(TextBox.Text)
            end)

            return {
                SetText = function(self, NewText)
                    TextBox.Text = NewText
                    Callback(NewText)
                end
            }
        end

        function Tab:CreateDropdown(ElementOptions)
            ElementOptions = ElementOptions or {}
            local Name = ElementOptions.Name or "Dropdown"
            local Options = ElementOptions.Options or {}
            local Default = ElementOptions.CurrentValue or ""
            local Callback = ElementOptions.Callback or function() end

            local DropdownFrame = Instance.new("Frame")
            DropdownFrame.Name = Name .. "Dropdown"
            DropdownFrame.Parent = TabPage
            DropdownFrame.BackgroundColor3 = CurrentTheme.SecondaryColor
            DropdownFrame.Size = UDim2.new(1, 0, 0, 38)
            DropdownFrame.ClipsDescendants = true
            GlobalObjects[DropdownFrame] = "Secondary"

            local DropdownCorner = Instance.new("UICorner")
            DropdownCorner.CornerRadius = UDim.new(0, 8)
            DropdownCorner.Parent = DropdownFrame
            
            AddStroke(DropdownFrame, CurrentTheme.AccentColor, 1, 0.6)

            local DropdownLabel = Instance.new("TextLabel")
            DropdownLabel.Parent = DropdownFrame
            DropdownLabel.BackgroundTransparency = 1
            DropdownLabel.Position = UDim2.new(0, 12, 0, 0)
            DropdownLabel.Size = UDim2.new(1, -30, 0, 38)
            DropdownLabel.Font = Enum.Font.GothamMedium
            DropdownLabel.Text = Name .. " : " .. (Default ~= "" and Default or "None")
            DropdownLabel.TextColor3 = CurrentTheme.TextColor
            DropdownLabel.TextSize = 14
            DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left
            GlobalObjects[DropdownLabel] = "Text"

            local Arrow = Instance.new("TextLabel")
            Arrow.Parent = DropdownFrame
            Arrow.BackgroundTransparency = 1
            Arrow.Position = UDim2.new(1, -30, 0, 0)
            Arrow.Size = UDim2.new(0, 20, 0, 38)
            Arrow.Font = Enum.Font.GothamBold
            Arrow.Text = ">"
            Arrow.TextColor3 = CurrentTheme.TextColor
            Arrow.TextSize = 14
            Arrow.Rotation = 90
            GlobalObjects[Arrow] = "Text"

            local OptionsContainer = Instance.new("Frame")
            OptionsContainer.Parent = DropdownFrame
            OptionsContainer.BackgroundTransparency = 1
            OptionsContainer.Position = UDim2.new(0, 8, 0, 38)
            OptionsContainer.Size = UDim2.new(1, -16, 0, 0)
            
            local OptionsList = Instance.new("UIListLayout")
            OptionsList.Parent = OptionsContainer
            OptionsList.Padding = UDim.new(0, 4)

            local Toggled = false
            local function UpdateDropdown()
                local TargetHeight = Toggled and (38 + (#Options * 28) + 8) or 38
                TweenService:Create(DropdownFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, TargetHeight)}):Play()
                TweenService:Create(Arrow, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {Rotation = Toggled and 270 or 90}):Play()
            end

            for _, Option in ipairs(Options) do
                local OptionBtn = Instance.new("TextButton")
                OptionBtn.Parent = OptionsContainer
                OptionBtn.BackgroundColor3 = CurrentTheme.MainColor
                OptionBtn.Size = UDim2.new(1, 0, 0, 24)
                OptionBtn.Font = Enum.Font.Gotham
                OptionBtn.Text = Option
                OptionBtn.TextColor3 = CurrentTheme.TextSecondaryColor
                OptionBtn.TextSize = 13
                GlobalObjects[OptionBtn] = "Main"
                
                local OptionCorner = Instance.new("UICorner")
                OptionCorner.CornerRadius = UDim.new(0, 6)
                OptionCorner.Parent = OptionBtn

                OptionBtn.MouseButton1Click:Connect(function()
                    DropdownLabel.Text = Name .. " : " .. Option
                    Toggled = false
                    UpdateDropdown()
                    Callback(Option)
                end)
            end

            local ClickBtn = Instance.new("TextButton")
            ClickBtn.Parent = DropdownFrame
            ClickBtn.BackgroundTransparency = 1
            ClickBtn.Size = UDim2.new(1, 0, 0, 38)
            ClickBtn.Text = ""

            ClickBtn.MouseButton1Click:Connect(function()
                Toggled = not Toggled
                UpdateDropdown()
            end)

            return {
                Refresh = function(self, NewOptions)
                    for _, child in ipairs(OptionsContainer:GetChildren()) do
                        if child:IsA("TextButton") then child:Destroy() end
                    end
                    Options = NewOptions
                    for _, Option in ipairs(Options) do
                        local OptionBtn = Instance.new("TextButton")
                        OptionBtn.Parent = OptionsContainer
                        OptionBtn.BackgroundColor3 = CurrentTheme.MainColor
                        OptionBtn.Size = UDim2.new(1, 0, 0, 24)
                        OptionBtn.Font = Enum.Font.Gotham
                        OptionBtn.Text = Option
                        OptionBtn.TextColor3 = CurrentTheme.TextSecondaryColor
                        OptionBtn.TextSize = 13
                        GlobalObjects[OptionBtn] = "Main"
                        
                        local OptionCorner = Instance.new("UICorner")
                        OptionCorner.CornerRadius = UDim.new(0, 6)
                        OptionCorner.Parent = OptionBtn

                        OptionBtn.MouseButton1Click:Connect(function()
                            DropdownLabel.Text = Name .. " : " .. Option
                            Toggled = false
                            UpdateDropdown()
                            Callback(Option)
                        end)
                    end
                end
            }
        end

        function Tab:CreateKeybind(ElementOptions)
            ElementOptions = ElementOptions or {}
            local Name = ElementOptions.Name or "Keybind"
            local CurrentKey = ElementOptions.CurrentKey or Enum.KeyCode.F
            local Callback = ElementOptions.Callback or function() end

            local KeybindFrame = Instance.new("Frame")
            KeybindFrame.Name = Name .. "Keybind"
            KeybindFrame.Parent = TabPage
            KeybindFrame.BackgroundColor3 = CurrentTheme.SecondaryColor
            KeybindFrame.Size = UDim2.new(1, 0, 0, 38)
            GlobalObjects[KeybindFrame] = "Secondary"

            local KeybindCorner = Instance.new("UICorner")
            KeybindCorner.CornerRadius = UDim.new(0, 8)
            KeybindCorner.Parent = KeybindFrame
            
            AddStroke(KeybindFrame, CurrentTheme.AccentColor, 1, 0.6)

            local KeybindLabel = Instance.new("TextLabel")
            KeybindLabel.Parent = KeybindFrame
            KeybindLabel.BackgroundTransparency = 1
            KeybindLabel.Position = UDim2.new(0, 12, 0, 0)
            KeybindLabel.Size = UDim2.new(1, -100, 1, 0)
            KeybindLabel.Font = Enum.Font.GothamMedium
            KeybindLabel.Text = Name
            KeybindLabel.TextColor3 = CurrentTheme.TextColor
            KeybindLabel.TextSize = 14
            KeybindLabel.TextXAlignment = Enum.TextXAlignment.Left
            GlobalObjects[KeybindLabel] = "Text"

            local KeyBox = Instance.new("Frame")
            KeyBox.Parent = KeybindFrame
            KeyBox.BackgroundColor3 = CurrentTheme.MainColor
            KeyBox.Position = UDim2.new(1, -90, 0.5, -12)
            KeyBox.Size = UDim2.new(0, 80, 0, 24)
            GlobalObjects[KeyBox] = "Main"

            local KeyCorner = Instance.new("UICorner")
            KeyCorner.CornerRadius = UDim.new(0, 6)
            KeyCorner.Parent = KeyBox

            local KeyLabel = Instance.new("TextLabel")
            KeyLabel.Parent = KeyBox
            KeyLabel.BackgroundTransparency = 1
            KeyLabel.Size = UDim2.new(1, 0, 1, 0)
            KeyLabel.Font = Enum.Font.GothamBold
            KeyLabel.Text = CurrentKey.Name
            KeyLabel.TextColor3 = CurrentTheme.AccentColor
            KeyLabel.TextSize = 12
            GlobalObjects[KeyLabel] = "Accent"

            local Binding = false
            local ClickBtn = Instance.new("TextButton")
            ClickBtn.Parent = KeybindFrame
            ClickBtn.BackgroundTransparency = 1
            ClickBtn.Size = UDim2.new(1, 0, 1, 0)
            ClickBtn.Text = ""

            ClickBtn.MouseButton1Click:Connect(function()
                Binding = true
                KeyLabel.Text = "..."
            end)

            UserInputService.InputBegan:Connect(function(Input)
                if Binding and Input.UserInputType == Enum.UserInputType.Keyboard then
                    CurrentKey = Input.KeyCode
                    KeyLabel.Text = CurrentKey.Name
                    Binding = false
                    Callback(CurrentKey)
                end
            end)

            return {
                Set = function(self, NewKey)
                    CurrentKey = NewKey
                    KeyLabel.Text = CurrentKey.Name
                    Callback(CurrentKey)
                end
            }
        end

        return Tab
    end

    -- [[ Notifications Fix ]]
    local NotifGui = Instance.new("ScreenGui")
    NotifGui.Name = "PetagonNotifications"
    NotifGui.Parent = CoreGui
    NotifGui.ZIndexBehavior = Enum.ZIndexBehavior.Global

    local NotifContainer = Instance.new("Frame")
    NotifContainer.Name = "NotifContainer"
    NotifContainer.Parent = NotifGui
    NotifContainer.BackgroundTransparency = 1
    NotifContainer.Position = UDim2.new(1, -280, 0, 20)
    NotifContainer.Size = UDim2.new(0, 260, 1, -40)

    local NotifList = Instance.new("UIListLayout")
    NotifList.Parent = NotifContainer
    NotifList.VerticalAlignment = Enum.VerticalAlignment.Top
    NotifList.Padding = UDim.new(0, 8)

    function Petagon:Notify(NotifOptions)
        NotifOptions = NotifOptions or {}
        local TitleText = NotifOptions.Title or "Notification"
        local ContentText = NotifOptions.Content or "Message here"
        local Duration = NotifOptions.Duration or 5

        local NotifFrame = Instance.new("Frame")
        NotifFrame.Name = "Notification"
        NotifFrame.Parent = NotifContainer
        NotifFrame.BackgroundColor3 = CurrentTheme.MainColor
        NotifFrame.Size = UDim2.new(1, 0, 0, 0)
        NotifFrame.ClipsDescendants = true
        NotifFrame.Transparency = 1
        
        local NotifCorner = Instance.new("UICorner")
        NotifCorner.CornerRadius = UDim.new(0, 8)
        NotifCorner.Parent = NotifFrame

        local NotifStroke = AddStroke(NotifFrame, CurrentTheme.AccentColor, 1.2, 0.4)

        local NotifTitle = Instance.new("TextLabel")
        NotifTitle.Parent = NotifFrame
        NotifTitle.BackgroundTransparency = 1
        NotifTitle.Position = UDim2.new(0, 12, 0, 8)
        NotifTitle.Size = UDim2.new(1, -24, 0, 20)
        NotifTitle.Font = Enum.Font.GothamBold
        NotifTitle.Text = TitleText
        NotifTitle.TextColor3 = CurrentTheme.AccentColor
        NotifTitle.TextSize = 14
        NotifTitle.TextXAlignment = Enum.TextXAlignment.Left

        local NotifContent = Instance.new("TextLabel")
        NotifContent.Parent = NotifFrame
        NotifContent.BackgroundTransparency = 1
        NotifContent.Position = UDim2.new(0, 12, 0, 28)
        NotifContent.Size = UDim2.new(1, -24, 0, 30)
        NotifContent.Font = Enum.Font.Gotham
        NotifContent.Text = ContentText
        NotifContent.TextColor3 = CurrentTheme.TextColor
        NotifContent.TextSize = 12
        NotifContent.TextXAlignment = Enum.TextXAlignment.Left
        NotifContent.TextWrapped = true

        -- Animation logic
        TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, 65), Transparency = 0}):Play()
        
        task.delay(Duration, function()
            TweenService:Create(NotifFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, 0), Transparency = 1}):Play()
            task.wait(0.5)
            NotifFrame:Destroy()
        end)
    end

    -- [[ Configuration Saving Logic ]]
    local ConfigPath = "Petagon/Configs/"
    if not isfolder("Petagon") then makefolder("Petagon") end
    if not isfolder(ConfigPath) then makefolder(ConfigPath) end

    local function SaveConfig(FileName, Data)
        local Success, Error = pcall(function()
            writefile(ConfigPath .. FileName .. ".json", game:GetService("HttpService"):JSONEncode(Data))
        end)
        return Success
    end

    local function LoadConfig(FileName)
        if isfile(ConfigPath .. FileName .. ".json") then
            local Success, Data = pcall(function()
                return game:GetService("HttpService"):JSONDecode(readfile(ConfigPath .. FileName .. ".json"))
            end)
            if Success then return Data end
        end
        return nil
    end

    -- [[ Key System ]]
    function Window:CreateKeySystem(KeyOptions)
        KeyOptions = KeyOptions or {}
        local KeyMatch = KeyOptions.Key or {"key"}
        local TitleText = KeyOptions.Title or "Key System"
        local SubtitleText = KeyOptions.Subtitle or "Please enter your key"
        local NoteText = KeyOptions.Note or "Join our Discord for the key"
        local FileName = KeyOptions.FileName or "PetagonKey"
        local SaveKey = KeyOptions.SaveKey or true

        -- Hide Main Window initially if Key System is active
        Main.Visible = false

        local KeyGui = Instance.new("Frame")
        KeyGui.Name = "KeySystem"
        KeyGui.Parent = PetagonGui
        KeyGui.BackgroundColor3 = CurrentTheme.MainColor
        KeyGui.BorderSizePixel = 0
        KeyGui.Position = UDim2.new(0.5, -150, 0.5, -100)
        KeyGui.Size = UDim2.new(0, 300, 0, 200)

        local KeyCorner = Instance.new("UICorner")
        KeyCorner.CornerRadius = UDim.new(0, CurrentTheme.Rounding)
        KeyCorner.Parent = KeyGui

        local KeyStroke = Instance.new("UIStroke")
        KeyStroke.Color = CurrentTheme.AccentColor
        KeyStroke.Thickness = 1.5
        KeyStroke.Parent = KeyGui

        local KeyTitle = Instance.new("TextLabel")
        KeyTitle.Parent = KeyGui
        KeyTitle.BackgroundTransparency = 1
        KeyTitle.Position = UDim2.new(0, 0, 0, 15)
        KeyTitle.Size = UDim2.new(1, 0, 0, 30)
        KeyTitle.Font = CurrentTheme.Font
        KeyTitle.Text = TitleText
        KeyTitle.TextColor3 = CurrentTheme.TextColor
        KeyTitle.TextSize = 20

        local KeySubtitle = Instance.new("TextLabel")
        KeySubtitle.Parent = KeyGui
        KeySubtitle.BackgroundTransparency = 1
        KeySubtitle.Position = UDim2.new(0, 0, 0, 45)
        KeySubtitle.Size = UDim2.new(1, 0, 0, 20)
        KeySubtitle.Font = CurrentTheme.Font
        KeySubtitle.Text = SubtitleText
        KeySubtitle.TextColor3 = CurrentTheme.TextSecondaryColor
        KeySubtitle.TextSize = 14

        local KeyInputFrame = Instance.new("Frame")
        KeyInputFrame.Parent = KeyGui
        KeyInputFrame.BackgroundColor3 = CurrentTheme.SecondaryColor
        KeyInputFrame.Position = UDim2.new(0.1, 0, 0.45, 0)
        KeyInputFrame.Size = UDim2.new(0.8, 0, 0, 35)

        local InputCorner = Instance.new("UICorner")
        InputCorner.CornerRadius = UDim.new(0, 6)
        InputCorner.Parent = KeyInputFrame

        local KeyTextBox = Instance.new("TextBox")
        KeyTextBox.Parent = KeyInputFrame
        KeyTextBox.BackgroundTransparency = 1
        KeyTextBox.Position = UDim2.new(0, 10, 0, 0)
        KeyTextBox.Size = UDim2.new(1, -20, 1, 0)
        KeyTextBox.Font = CurrentTheme.Font
        KeyTextBox.PlaceholderText = "Enter key here..."
        KeyTextBox.Text = ""
        KeyTextBox.TextColor3 = CurrentTheme.TextColor
        KeyTextBox.TextSize = 14

        local SubmitBtn = Instance.new("TextButton")
        SubmitBtn.Parent = KeyGui
        SubmitBtn.BackgroundColor3 = CurrentTheme.AccentColor
        SubmitBtn.Position = UDim2.new(0.1, 0, 0.7, 0)
        SubmitBtn.Size = UDim2.new(0.4, -5, 0, 35)
        SubmitBtn.Font = CurrentTheme.Font
        SubmitBtn.Text = "Submit"
        SubmitBtn.TextColor3 = CurrentTheme.TextColor
        SubmitBtn.TextSize = 14

        local SubmitCorner = Instance.new("UICorner")
        SubmitCorner.CornerRadius = UDim.new(0, 6)
        SubmitCorner.Parent = SubmitBtn

        local GetBtn = Instance.new("TextButton")
        GetBtn.Parent = KeyGui
        GetBtn.BackgroundColor3 = CurrentTheme.SecondaryColor
        GetBtn.Position = UDim2.new(0.5, 5, 0.7, 0)
        GetBtn.Size = UDim2.new(0.4, -5, 0, 35)
        GetBtn.Font = CurrentTheme.Font
        GetBtn.Text = "Get Key"
        GetBtn.TextColor3 = CurrentTheme.TextColor
        GetBtn.TextSize = 14

        local GetCorner = Instance.new("UICorner")
        GetCorner.CornerRadius = UDim.new(0, 6)
        GetCorner.Parent = GetBtn

        local Note = Instance.new("TextLabel")
        Note.Parent = KeyGui
        Note.BackgroundTransparency = 1
        Note.Position = UDim2.new(0, 0, 0.9, 0)
        Note.Size = UDim2.new(1, 0, 0, 20)
        Note.Font = CurrentTheme.Font
        Note.Text = NoteText
        Note.TextColor3 = CurrentTheme.TextSecondaryColor
        Note.TextSize = 11

        local function Unlock()
            TweenService:Create(KeyGui, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, -150, 1, 50)}):Play()
            task.wait(0.4)
            KeyGui:Destroy()
            Main.Visible = true
            Main.Size = UDim2.new(0, 0, 0, 0)
            TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {Size = UDim2.new(0, 500, 0, 350)}):Play()
        end

        SubmitBtn.MouseButton1Click:Connect(function()
            local InputKey = KeyTextBox.Text
            local Correct = false
            for _, k in ipairs(KeyMatch) do
                if InputKey == k then Correct = true break end
            end

            if Correct then
                if SaveKey then writefile(FileName .. ".txt", InputKey) end
                Petagon:Notify({Title = "Key Correct", Content = "Access Granted", Duration = 3})
                Unlock()
            else
                KeyTextBox.Text = ""
                KeyTextBox.PlaceholderText = "Invalid Key!"
                task.wait(1)
                KeyTextBox.PlaceholderText = "Enter key here..."
            end
        end)

        -- Auto-fill saved key
        if isfile(FileName .. ".txt") then
            local SavedKey = readfile(FileName .. ".txt")
            local Correct = false
            for _, k in ipairs(KeyMatch) do
                if SavedKey == k then Correct = true break end
            end
            if Correct then
                task.spawn(Unlock)
            end
        end
    end

    function Window:CreateSettingsTab()
        local SettingsTab = Window:CreateTab("Configs")
        
        SettingsTab:CreateDropdown({
            Name = "UI Theme",
            Options = {"Dark", "Light", "Blue"},
            Default = "Dark",
            Callback = function(Value)
                Petagon:ApplyTheme(Value)
                Petagon:Notify({Title = "Theme Changed", Content = "Interface updated to " .. Value, Duration = 3})
            end
        })

        SettingsTab:CreateKeybind({
            Name = "UI Toggle Key",
            CurrentKey = ToggleKey,
            Callback = function(Key)
                ToggleKey = Key
                Petagon:Notify({Title = "Keybind Updated", Content = "New toggle key: " .. Key.Name, Duration = 3})
            end
        })

        SettingsTab:CreateToggle({
            Name = "Mobile Toggle Button",
            CurrentValue = UserInputService.TouchEnabled,
            Callback = function(Value)
                if Value then
                    CreateMobileButton()
                elseif MobileButton then
                    MobileButton:Destroy()
                    MobileButton = nil
                end
            end
        })

        SettingsTab:CreateButton({
            Name = "Save Configuration",
            Callback = function()
                Petagon:Notify({Title = "Configs", Content = "Saved successfully!", Duration = 3})
            end
        })

        SettingsTab:CreateButton({
            Name = "Destroy UI",
            Callback = function()
                PetagonGui:Destroy()
                NotifGui:Destroy()
            end
        })

        return SettingsTab
    end

    -- Update Tab logic for theme reactivity
    local function UpdateTabColors(TabBtn, Page)
        GlobalObjects[TabBtn] = "Secondary"
        GlobalObjects[Page] = "Main"
    end

    return Window
end

return Petagon
