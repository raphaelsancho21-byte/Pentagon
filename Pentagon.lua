local Petagon = {}

-- [[ Services ]]
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")

-- [[ Variables ]]
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()

-- [[ Configuration ]]
local Theme = {
    MainColor = Color3.fromRGB(10, 11, 16),
    SecondaryColor = Color3.fromRGB(15, 16, 24),
    AccentColor = Color3.fromRGB(123, 44, 191),
    TextColor = Color3.fromRGB(255, 255, 255),
    TextSecondaryColor = Color3.fromRGB(180, 180, 180),
    Font = Enum.Font.Gotham,
    Rounding = 8
}

-- [[ Utility Functions ]]
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

function Petagon:CreateWindow(Options)
    Options = Options or {}
    local WindowTitle = Options.Name or "Petagon UI"
    
    local PetagonGui = Instance.new("ScreenGui")
    PetagonGui.Name = "Petagon"
    PetagonGui.Parent = CoreGui
    PetagonGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = PetagonGui
    Main.BackgroundColor3 = Theme.MainColor
    Main.BorderSizePixel = 0
    Main.ClipsDescendants = true
    Main.Position = UDim2.new(0.5, -250, 0.5, -175)
    Main.Size = UDim2.new(0, 500, 0, 350)

    local UICorner = Instance.new("UICorner")
    UICorner.CornerRadius = UDim.new(0, Theme.Rounding)
    UICorner.Parent = Main

    local UIStroke = Instance.new("UIStroke")
    UIStroke.Color = Theme.AccentColor
    UIStroke.Thickness = 1.5
    UIStroke.Transparency = 0.5
    UIStroke.Parent = Main

    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Parent = Main
    TopBar.BackgroundColor3 = Theme.SecondaryColor
    TopBar.BorderSizePixel = 0
    TopBar.Size = UDim2.new(1, 0, 0, 40)

    local TopBarCorner = Instance.new("UICorner")
    TopBarCorner.CornerRadius = UDim.new(0, Theme.Rounding)
    TopBarCorner.Parent = TopBar

    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = TopBar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.Size = UDim2.new(1, -30, 1, 0)
    Title.Font = Theme.Font
    Title.Text = WindowTitle
    Title.TextColor3 = Theme.TextColor
    Title.TextSize = 16
    Title.TextXAlignment = Enum.TextXAlignment.Left

    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = Main
    Sidebar.BackgroundColor3 = Theme.SecondaryColor
    Sidebar.BorderSizePixel = 0
    Sidebar.Position = UDim2.new(0, 0, 0, 40)
    Sidebar.Size = UDim2.new(0, 140, 1, -40)

    local SidebarCorner = Instance.new("UICorner")
    SidebarCorner.CornerRadius = UDim.new(0, Theme.Rounding)
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
        TabButton.BackgroundColor3 = Theme.MainColor
        TabButton.BorderSizePixel = 0
        TabButton.Size = UDim2.new(1, 0, 0, 30)
        TabButton.Font = Theme.Font
        TabButton.Text = Name
        TabButton.TextColor3 = Theme.TextSecondaryColor
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
        TabPage.ScrollBarImageColor3 = Theme.AccentColor

        local PageListLayout = Instance.new("UIListLayout")
        PageListLayout.Parent = TabPage
        PageListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageListLayout.Padding = UDim.new(0, 8)

        local PagePadding = Instance.new("UIPadding")
        PagePadding.Parent = TabPage
        PagePadding.PaddingLeft = UDim.new(0, 10)
        PagePadding.PaddingRight = UDim.new(0, 10)
        PagePadding.PaddingTop = UDim.new(0, 10)

        TabButton.MouseButton1Click:Connect(function()
            if Window.CurrentTab then
                Window.CurrentTab.Button.TextColor3 = Theme.TextSecondaryColor
                TweenService:Create(Window.CurrentTab.Button, TweenInfo.new(0.3), {BackgroundColor3 = Theme.MainColor}):Play()
                Window.CurrentTab.Page.Visible = false
            end
            
            TabButton.TextColor3 = Theme.TextColor
            TweenService:Create(TabButton, TweenInfo.new(0.3), {BackgroundColor3 = Theme.AccentColor}):Play()
            TabPage.Visible = true
            Window.CurrentTab = {Button = TabButton, Page = TabPage}
        end)

        -- Select first tab by default
        if not Window.CurrentTab then
            TabButton.TextColor3 = Theme.TextColor
            TabButton.BackgroundColor3 = Theme.AccentColor
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
            ButtonFrame.BackgroundColor3 = Theme.SecondaryColor
            ButtonFrame.Size = UDim2.new(1, 0, 0, 35)

            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 6)
            ButtonCorner.Parent = ButtonFrame

            local TextBtn = Instance.new("TextButton")
            TextBtn.Parent = ButtonFrame
            TextBtn.BackgroundTransparency = 1
            TextBtn.Size = UDim2.new(1, 0, 1, 0)
            TextBtn.Font = Theme.Font
            TextBtn.Text = Name
            TextBtn.TextColor3 = Theme.TextColor
            TextBtn.TextSize = 14

            TextBtn.MouseButton1Click:Connect(function()
                Callback()
                -- Visual feedback
                local OriginalColor = ButtonFrame.BackgroundColor3
                TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {BackgroundColor3 = Theme.AccentColor}):Play()
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
            ToggleFrame.BackgroundColor3 = Theme.SecondaryColor
            ToggleFrame.Size = UDim2.new(1, 0, 0, 35)

            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 6)
            ToggleCorner.Parent = ToggleFrame

            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Parent = ToggleFrame
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.Position = UDim2.new(0, 10, 0, 0)
            ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
            ToggleLabel.Font = Theme.Font
            ToggleLabel.Text = Name
            ToggleLabel.TextColor3 = Theme.TextColor
            ToggleLabel.TextSize = 14
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left

            local Switch = Instance.new("Frame")
            Switch.Name = "Switch"
            Switch.Parent = ToggleFrame
            Switch.BackgroundColor3 = Toggled and Theme.AccentColor or Theme.MainColor
            Switch.Position = UDim2.new(1, -45, 0.5, -10)
            Switch.Size = UDim2.new(0, 35, 0, 20)
            
            local SwitchCorner = Instance.new("UICorner")
            SwitchCorner.CornerRadius = UDim.new(1, 0)
            SwitchCorner.Parent = Switch

            local Circle = Instance.new("Frame")
            Circle.Name = "Circle"
            Circle.Parent = Switch
            Circle.BackgroundColor3 = Theme.TextColor
            Circle.Position = Toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            Circle.Size = UDim2.new(0, 16, 0, 16)

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
                local TargetPos = Toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                local TargetColor = Toggled and Theme.AccentColor or Theme.MainColor
                
                TweenService:Create(Circle, TweenInfo.new(0.2), {Position = TargetPos}):Play()
                TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = TargetColor}):Play()
                
                Callback(Toggled)
            end)

            return {
                Set = function(self, NewValue)
                    Toggled = NewValue
                    local TargetPos = Toggled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                    local TargetColor = Toggled and Theme.AccentColor or Theme.MainColor
                    TweenService:Create(Circle, TweenInfo.new(0.2), {Position = TargetPos}):Play()
                    TweenService:Create(Switch, TweenInfo.new(0.2), {BackgroundColor3 = TargetColor}):Play()
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
            SliderFrame.BackgroundColor3 = Theme.SecondaryColor
            SliderFrame.Size = UDim2.new(1, 0, 0, 45)

            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 6)
            SliderCorner.Parent = SliderFrame

            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Parent = SliderFrame
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.Position = UDim2.new(0, 10, 0, 5)
            SliderLabel.Size = UDim2.new(1, -20, 0, 20)
            SliderLabel.Font = Theme.Font
            SliderLabel.Text = Name
            SliderLabel.TextColor3 = Theme.TextColor
            SliderLabel.TextSize = 14
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Parent = SliderFrame
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Position = UDim2.new(0, 10, 0, 5)
            ValueLabel.Size = UDim2.new(1, -20, 0, 20)
            ValueLabel.Font = Theme.Font
            ValueLabel.Text = tostring(Value)
            ValueLabel.TextColor3 = Theme.TextSecondaryColor
            ValueLabel.TextSize = 12
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right

            local Track = Instance.new("Frame")
            Track.Name = "Track"
            Track.Parent = SliderFrame
            Track.BackgroundColor3 = Theme.MainColor
            Track.Position = UDim2.new(0, 10, 1, -12)
            Track.Size = UDim2.new(1, -20, 0, 4)

            local Progress = Instance.new("Frame")
            Progress.Name = "Progress"
            Progress.Parent = Track
            Progress.BackgroundColor3 = Theme.AccentColor
            Progress.Size = UDim2.new((Value - Min) / (Max - Min), 0, 1, 0)

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
            InputFrame.BackgroundColor3 = Theme.SecondaryColor
            InputFrame.Size = UDim2.new(1, 0, 0, 35)

            local InputCorner = Instance.new("UICorner")
            InputCorner.CornerRadius = UDim.new(0, 6)
            InputCorner.Parent = InputFrame

            local InputLabel = Instance.new("TextLabel")
            InputLabel.Parent = InputFrame
            InputLabel.BackgroundTransparency = 1
            InputLabel.Position = UDim2.new(0, 10, 0, 0)
            InputLabel.Size = UDim2.new(0.4, -10, 1, 0)
            InputLabel.Font = Theme.Font
            InputLabel.Text = Name
            InputLabel.TextColor3 = Theme.TextColor
            InputLabel.TextSize = 14
            InputLabel.TextXAlignment = Enum.TextXAlignment.Left

            local BoxHolder = Instance.new("Frame")
            BoxHolder.Parent = InputFrame
            BoxHolder.BackgroundColor3 = Theme.MainColor
            BoxHolder.Position = UDim2.new(0.4, 0, 0.5, -12)
            BoxHolder.Size = UDim2.new(0.6, -10, 0, 24)
            
            local BoxCorner = Instance.new("UICorner")
            BoxCorner.CornerRadius = UDim.new(0, 4)
            BoxCorner.Parent = BoxHolder

            local TextBox = Instance.new("TextBox")
            TextBox.Parent = BoxHolder
            TextBox.BackgroundTransparency = 1
            TextBox.Position = UDim2.new(0, 5, 0, 0)
            TextBox.Size = UDim2.new(1, -10, 1, 0)
            TextBox.Font = Theme.Font
            TextBox.PlaceholderText = Placeholder
            TextBox.Text = ""
            TextBox.TextColor3 = Theme.TextColor
            TextBox.PlaceholderColor3 = Theme.TextSecondaryColor
            TextBox.TextSize = 12
            TextBox.TextXAlignment = Enum.TextXAlignment.Left

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
            DropdownFrame.BackgroundColor3 = Theme.SecondaryColor
            DropdownFrame.Size = UDim2.new(1, 0, 0, 35)
            DropdownFrame.ClipsDescendants = true

            local DropdownCorner = Instance.new("UICorner")
            DropdownCorner.CornerRadius = UDim.new(0, 6)
            DropdownCorner.Parent = DropdownFrame

            local DropdownLabel = Instance.new("TextLabel")
            DropdownLabel.Parent = DropdownFrame
            DropdownLabel.BackgroundTransparency = 1
            DropdownLabel.Position = UDim2.new(0, 10, 0, 0)
            DropdownLabel.Size = UDim2.new(1, -30, 0, 35)
            DropdownLabel.Font = Theme.Font
            DropdownLabel.Text = Name .. " : " .. (Default ~= "" and Default or "None")
            DropdownLabel.TextColor3 = Theme.TextColor
            DropdownLabel.TextSize = 14
            DropdownLabel.TextXAlignment = Enum.TextXAlignment.Left

            local Arrow = Instance.new("TextLabel")
            Arrow.Parent = DropdownFrame
            Arrow.BackgroundTransparency = 1
            Arrow.Position = UDim2.new(1, -25, 0, 0)
            Arrow.Size = UDim2.new(0, 20, 0, 35)
            Arrow.Font = Theme.Font
            Arrow.Text = ">"
            Arrow.TextColor3 = Theme.TextColor
            Arrow.TextSize = 14
            Arrow.Rotation = 90

            local OptionsContainer = Instance.new("Frame")
            OptionsContainer.Parent = DropdownFrame
            OptionsContainer.BackgroundTransparency = 1
            OptionsContainer.Position = UDim2.new(0, 5, 0, 35)
            OptionsContainer.Size = UDim2.new(1, -10, 0, 0)
            
            local OptionsList = Instance.new("UIListLayout")
            OptionsList.Parent = OptionsContainer
            OptionsList.Padding = UDim.new(0, 3)

            local Toggled = false
            local function UpdateDropdown()
                local TargetHeight = Toggled and (35 + (#Options * 25) + 5) or 35
                TweenService:Create(DropdownFrame, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, TargetHeight)}):Play()
                TweenService:Create(Arrow, TweenInfo.new(0.3), {Rotation = Toggled and 270 or 90}):Play()
            end

            for _, Option in ipairs(Options) do
                local OptionBtn = Instance.new("TextButton")
                OptionBtn.Parent = OptionsContainer
                OptionBtn.BackgroundColor3 = Theme.MainColor
                OptionBtn.Size = UDim2.new(1, 0, 0, 22)
                OptionBtn.Font = Theme.Font
                OptionBtn.Text = Option
                OptionBtn.TextColor3 = Theme.TextSecondaryColor
                OptionBtn.TextSize = 12
                
                local OptionCorner = Instance.new("UICorner")
                OptionCorner.CornerRadius = UDim.new(0, 4)
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
            ClickBtn.Size = UDim2.new(1, 0, 0, 35)
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
                        OptionBtn.BackgroundColor3 = Theme.MainColor
                        OptionBtn.Size = UDim2.new(1, 0, 0, 22)
                        OptionBtn.Font = Theme.Font
                        OptionBtn.Text = Option
                        OptionBtn.TextColor3 = Theme.TextSecondaryColor
                        OptionBtn.TextSize = 12
                        
                        local OptionCorner = Instance.new("UICorner")
                        OptionCorner.CornerRadius = UDim.new(0, 4)
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

        return Tab
    end

    -- [[ Notifications ]]
    local NotifContainer = Instance.new("Frame")
    NotifContainer.Name = "NotifContainer"
    NotifContainer.Parent = PetagonGui
    NotifContainer.BackgroundTransparency = 1
    NotifContainer.Position = UDim2.new(1, -220, 1, -20)
    NotifContainer.Size = UDim2.new(0, 200, 1, -20)

    local NotifList = Instance.new("UIListLayout")
    NotifList.Parent = NotifContainer
    NotifList.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifList.Padding = UDim.new(0, 10)

    function Petagon:Notify(NotifOptions)
        NotifOptions = NotifOptions or {}
        local TitleText = NotifOptions.Title or "Notification"
        local ContentText = NotifOptions.Content or "Check this out!"
        local Duration = NotifOptions.Duration or 5

        local NotifFrame = Instance.new("Frame")
        NotifFrame.Name = "Notification"
        NotifFrame.Parent = NotifContainer
        NotifFrame.BackgroundColor3 = Theme.MainColor
        NotifFrame.Size = UDim2.new(1, 0, 0, 60)
        NotifFrame.Position = UDim2.new(1, 20, 0, 0)
        
        local NotifCorner = Instance.new("UICorner")
        NotifCorner.CornerRadius = UDim.new(0, 6)
        NotifCorner.Parent = NotifFrame

        local NotifStroke = Instance.new("UIStroke")
        NotifStroke.Color = Theme.AccentColor
        NotifStroke.Thickness = 1
        NotifStroke.Parent = NotifFrame

        local NotifTitle = Instance.new("TextLabel")
        NotifTitle.Parent = NotifFrame
        NotifTitle.BackgroundTransparency = 1
        NotifTitle.Position = UDim2.new(0, 10, 0, 5)
        NotifTitle.Size = UDim2.new(1, -20, 0, 20)
        NotifTitle.Font = Theme.Font
        NotifTitle.Text = TitleText
        NotifTitle.TextColor3 = Theme.AccentColor
        NotifTitle.TextSize = 14
        NotifTitle.TextXAlignment = Enum.TextXAlignment.Left

        local NotifContent = Instance.new("TextLabel")
        NotifContent.Parent = NotifFrame
        NotifContent.BackgroundTransparency = 1
        NotifContent.Position = UDim2.new(0, 10, 0, 25)
        NotifContent.Size = UDim2.new(1, -20, 0, 30)
        NotifContent.Font = Theme.Font
        NotifContent.Text = ContentText
        NotifContent.TextColor3 = Theme.TextColor
        NotifContent.TextSize = 12
        NotifContent.TextXAlignment = Enum.TextXAlignment.Left
        NotifContent.TextWrapped = true

        TweenService:Create(NotifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Position = UDim2.new(0, 0, 0, 0)}):Play()
        
        task.delay(Duration, function()
            TweenService:Create(NotifFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back), {Position = UDim2.new(1.2, 0, 0, 0)}):Play()
            task.wait(0.4)
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
        KeyGui.BackgroundColor3 = Theme.MainColor
        KeyGui.BorderSizePixel = 0
        KeyGui.Position = UDim2.new(0.5, -150, 0.5, -100)
        KeyGui.Size = UDim2.new(0, 300, 0, 200)

        local KeyCorner = Instance.new("UICorner")
        KeyCorner.CornerRadius = UDim.new(0, Theme.Rounding)
        KeyCorner.Parent = KeyGui

        local KeyStroke = Instance.new("UIStroke")
        KeyStroke.Color = Theme.AccentColor
        KeyStroke.Thickness = 1.5
        KeyStroke.Parent = KeyGui

        local KeyTitle = Instance.new("TextLabel")
        KeyTitle.Parent = KeyGui
        KeyTitle.BackgroundTransparency = 1
        KeyTitle.Position = UDim2.new(0, 0, 0, 15)
        KeyTitle.Size = UDim2.new(1, 0, 0, 30)
        KeyTitle.Font = Theme.Font
        KeyTitle.Text = TitleText
        KeyTitle.TextColor3 = Theme.TextColor
        KeyTitle.TextSize = 20

        local KeySubtitle = Instance.new("TextLabel")
        KeySubtitle.Parent = KeyGui
        KeySubtitle.BackgroundTransparency = 1
        KeySubtitle.Position = UDim2.new(0, 0, 0, 45)
        KeySubtitle.Size = UDim2.new(1, 0, 0, 20)
        KeySubtitle.Font = Theme.Font
        KeySubtitle.Text = SubtitleText
        KeySubtitle.TextColor3 = Theme.TextSecondaryColor
        KeySubtitle.TextSize = 14

        local KeyInputFrame = Instance.new("Frame")
        KeyInputFrame.Parent = KeyGui
        KeyInputFrame.BackgroundColor3 = Theme.SecondaryColor
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
        KeyTextBox.Font = Theme.Font
        KeyTextBox.PlaceholderText = "Enter key here..."
        KeyTextBox.Text = ""
        KeyTextBox.TextColor3 = Theme.TextColor
        KeyTextBox.TextSize = 14

        local SubmitBtn = Instance.new("TextButton")
        SubmitBtn.Parent = KeyGui
        SubmitBtn.BackgroundColor3 = Theme.AccentColor
        SubmitBtn.Position = UDim2.new(0.1, 0, 0.7, 0)
        SubmitBtn.Size = UDim2.new(0.4, -5, 0, 35)
        SubmitBtn.Font = Theme.Font
        SubmitBtn.Text = "Submit"
        SubmitBtn.TextColor3 = Theme.TextColor
        SubmitBtn.TextSize = 14

        local SubmitCorner = Instance.new("UICorner")
        SubmitCorner.CornerRadius = UDim.new(0, 6)
        SubmitCorner.Parent = SubmitBtn

        local GetBtn = Instance.new("TextButton")
        GetBtn.Parent = KeyGui
        GetBtn.BackgroundColor3 = Theme.SecondaryColor
        GetBtn.Position = UDim2.new(0.5, 5, 0.7, 0)
        GetBtn.Size = UDim2.new(0.4, -5, 0, 35)
        GetBtn.Font = Theme.Font
        GetBtn.Text = "Get Key"
        GetBtn.TextColor3 = Theme.TextColor
        GetBtn.TextSize = 14

        local GetCorner = Instance.new("UICorner")
        GetCorner.CornerRadius = UDim.new(0, 6)
        GetCorner.Parent = GetBtn

        local Note = Instance.new("TextLabel")
        Note.Parent = KeyGui
        Note.BackgroundTransparency = 1
        Note.Position = UDim2.new(0, 0, 0.9, 0)
        Note.Size = UDim2.new(1, 0, 0, 20)
        Note.Font = Theme.Font
        Note.Text = NoteText
        Note.TextColor3 = Theme.TextSecondaryColor
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
        
        SettingsTab:CreateButton({
            Name = "Save Configuration",
            Callback = function()
                Petagon:Notify({Title = "Configs", Content = "Saved successfully!", Duration = 3})
            end
        })

        SettingsTab:CreateToggle({
            Name = "Always Open (Auto-fill Key)",
            CurrentValue = true,
            Callback = function(Value)
                print("Key Saving:", Value)
            end
        })

        SettingsTab:CreateButton({
            Name = "Destroy UI",
            Callback = function()
                PetagonGui:Destroy()
            end
        })

        return SettingsTab
    end

    return Window
end

return Petagon
