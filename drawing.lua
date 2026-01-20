local coreGui = game:GetService("CoreGui")
local camera = workspace.CurrentCamera

-- Main ScreenGui for drawings
local drawingUI = Instance.new("ScreenGui")
drawingUI.Name = "Drawing"
drawingUI.IgnoreGuiInset = true
drawingUI.DisplayOrder = 0x7fffffff
drawingUI.Parent = coreGui

-- Drawing index
local drawingIndex = 0

-- Base drawing object
local baseDrawingObj = setmetatable({
    Visible = true,
    ZIndex = 0,
    Transparency = 1,
    Color = Color3.new(1, 1, 1),
    Remove = function(self) setmetatable(self, nil) end,
    Destroy = function(self) setmetatable(self, nil) end,
}, {
    __add = function(t1, t2)
        local result = table.clone(t1)
        for index, value in t2 do
            result[index] = value
        end
        return result
    end
})

-- Utility function
local function convertTransparency(transparency: number): number
    return math.clamp(1 - transparency, 0, 1)
end

-- Drawing library
local DrawingLib = {}

function DrawingLib.new(drawingType)
    drawingIndex += 1

    if drawingType ~= "Circle" then
        error("Only Circle type is supported in this version.")
    end

    local circleObj = ({
        Radius = 150,
        Position = Vector2.zero,
        Thickness = 2,
        Filled = false,
        Color = Color3.new(1,1,1),
        Transparency = 0,
        Gradient = nil, -- expects {Color = ColorSequence, Rotation = number}
    } + baseDrawingObj)

    -- UI objects
    local circleFrame = Instance.new("Frame")
    local uiCorner = Instance.new("UICorner")
    local uiStroke = Instance.new("UIStroke")
    local uiGradient = Instance.new("UIGradient")

    circleFrame.Name = drawingIndex
    circleFrame.AnchorPoint = Vector2.one * 0.5
    circleFrame.BorderSizePixel = 0
    circleFrame.Size = UDim2.fromOffset(circleObj.Radius * 2, circleObj.Radius * 2)
    circleFrame.BackgroundColor3 = circleObj.Color
    circleFrame.BackgroundTransparency = circleObj.Filled and convertTransparency(circleObj.Transparency) or 1
    circleFrame.Visible = circleObj.Visible
    circleFrame.ZIndex = circleObj.ZIndex
    circleFrame.Parent = drawingUI

    -- Corner to make circle
    uiCorner.CornerRadius = UDim.new(1, 0)
    uiCorner.Parent = circleFrame

    -- Outline
    uiStroke.Thickness = circleObj.Thickness
    uiStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    uiStroke.Enabled = not circleObj.Filled
    uiStroke.Color = circleObj.Color
    uiStroke.Transparency = convertTransparency(circleObj.Transparency)
    uiStroke.Parent = circleFrame

    -- Gradient
    uiGradient.Enabled = false
    uiGradient.Parent = circleFrame

    return setmetatable({}, {
        __newindex = function(_, index, value)
            if circleObj[index] == nil then return end

            if index == "Radius" then
                circleFrame.Size = UDim2.fromOffset(value * 2, value * 2)
            elseif index == "Position" then
                circleFrame.Position = UDim2.fromOffset(value.X, value.Y)
            elseif index == "Thickness" then
                uiStroke.Thickness = math.clamp(value, 0.1, 0x7fffffff)
            elseif index == "Filled" then
                circleFrame.BackgroundTransparency = value and convertTransparency(circleObj.Transparency) or 1
                uiStroke.Enabled = not value
            elseif index == "Visible" then
                circleFrame.Visible = value
            elseif index == "ZIndex" then
                circleFrame.ZIndex = value
                uiStroke.ZIndex = value
            elseif index == "Transparency" then
                local trans = convertTransparency(value)
                circleFrame.BackgroundTransparency = (circleObj.Filled and trans or 1)
                uiStroke.Transparency = trans
                if uiGradient.Enabled then
                    uiGradient.Transparency = NumberSequence.new(trans)
                end
            elseif index == "Color" then
                circleFrame.BackgroundColor3 = value
                uiStroke.Color = value
                if uiGradient.Enabled then
                    uiGradient.Color = ColorSequence.new(value)
                end
            elseif index == "Gradient" then
                if typeof(value) == "table" and value.Color then
                    uiGradient.Color = value.Color
                    uiGradient.Rotation = value.Rotation or 0
                    uiGradient.Enabled = true
                else
                    uiGradient.Enabled = false
                end
            end

            circleObj[index] = value
        end,
        __index = function(_, index)
            if index == "Remove" or index == "Destroy" then
                return function()
                    circleFrame:Destroy()
                    circleObj.Remove(self)
                    return circleObj:Remove()
                end
            elseif index == "CircleFrame" then
                return circleFrame
            elseif index == "Outline" then
                return uiStroke
            elseif index == "GradientObject" then
                return uiGradient
            end
            return circleObj[index]
        end,
        __tostring = function() return "Drawing" end
    })
end

getgenv().Drawing = DrawingLib
