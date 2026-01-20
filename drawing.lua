local coreGui = game:GetService("CoreGui")
local camera = workspace.CurrentCamera

local drawingUI = Instance.new("ScreenGui")
drawingUI.Name = "Drawing"
drawingUI.IgnoreGuiInset = true
drawingUI.DisplayOrder = 0x7fffffff
drawingUI.Parent = coreGui

local drawingIndex = 0

local function convertTransparency(transparency: number): number
    return math.clamp(1 - transparency, 0, 1)
end

local DrawingLib = {}

function DrawingLib.new(drawingType)
    drawingIndex += 1
    if drawingType ~= "Circle" then error("Only Circle supported") end

    local circleObj = {
        Radius = 150,
        Position = Vector2.zero,
        Thickness = 2,
        Filled = false,
        Color = Color3.new(1, 1, 1),
        Transparency = 1, 
        Visible = true,
        ZIndex = 0,
        Gradient = nil,
    }

    local circleFrame = Instance.new("Frame")
    local uiCorner = Instance.new("UICorner")
    local uiStroke = Instance.new("UIStroke")
    local uiGradient = Instance.new("UIGradient")

    circleFrame.Name = "Circle_" .. drawingIndex
    circleFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    circleFrame.BorderSizePixel = 0
    circleFrame.Parent = drawingUI

    uiCorner.CornerRadius = UDim.new(1, 0)
    uiCorner.Parent = circleFrame

    uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    uiStroke.Parent = circleFrame
    
    uiGradient.Enabled = false
    uiGradient.Parent = circleFrame


    local function updateVisuals()
        local transVal = convertTransparency(circleObj.Transparency)
        
        circleFrame.Size = UDim2.fromOffset(circleObj.Radius * 2, circleObj.Radius * 2)
        circleFrame.Position = UDim2.fromOffset(circleObj.Position.X, circleObj.Position.Y)
        circleFrame.Visible = circleObj.Visible
        circleFrame.ZIndex = circleObj.ZIndex
        
        uiStroke.Thickness = math.max(0.1, circleObj.Thickness)
        uiStroke.Color = circleObj.Color
        uiStroke.Transparency = transVal

        if circleObj.Gradient then
            uiGradient.Enabled = true
            uiGradient.Color = circleObj.Gradient.Color
            uiGradient.Rotation = circleObj.Gradient.Rotation or 0
            uiGradient.Transparency = NumberSequence.new(transVal)
            
            circleFrame.BackgroundTransparency = 0 
            circleFrame.BackgroundColor3 = Color3.new(1, 1, 1) 
            uiStroke.Enabled = false 
        else
            uiGradient.Enabled = false
            circleFrame.BackgroundColor3 = circleObj.Color
            circleFrame.BackgroundTransparency = circleObj.Filled and transVal or 1
            uiStroke.Enabled = not circleObj.Filled
        end
    end

    local proxy = setmetatable({}, {
        __newindex = function(_, index, value)
            circleObj[index] = value
            updateVisuals()
        end,
        __index = function(_, index)
            if index == "Remove" or index == "Destroy" then
                return function() circleFrame:Destroy() end
            end
            return circleObj[index]
        end
    })

    updateVisuals()
    return proxy
end

getgenv().Drawing = DrawingLib
