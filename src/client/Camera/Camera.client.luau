local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local CAMERA_OFFSET = CFrame.new(4.4, 1.8, 8)

local currentRotation = Vector2.new()

local occlusionRaycastParams = RaycastParams.new()
occlusionRaycastParams.RespectCanCollide = true

local character: Model
local humanoidRootPart: BasePart

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Without this camera would pass through walls
local function getOcclusion(rootCFrame: CFrame, targetCFrame: CFrame)
	local direction = targetCFrame.Position - rootCFrame.Position
	local raycastResult = workspace:Raycast(rootCFrame.Position, direction, occlusionRaycastParams)

	if raycastResult then
		return CFrame.new(rootCFrame.Position) * targetCFrame.Rotation
			+ (direction.Unit * (raycastResult.Distance - 0.5))
	end

	return targetCFrame
end

-- This saves us performance and prevents us using expensive stuff every frame
player.CharacterAdded:Connect(function(newCharacter: Model)
	humanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart") :: BasePart
	character = newCharacter

	occlusionRaycastParams.FilterDescendantsInstances = { character }
end)

RunService.RenderStepped:Connect(function(deltaTime: number)
	camera.CameraType = Enum.CameraType.Scriptable

	UserInputService.MouseIconEnabled = false
	UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter

	-- Character can be nil, if player died recently this prevents errors
	if character == nil or character.Parent == nil then
		return
	end

	local mouseDelta = UserInputService:GetMouseDelta()
	local viewportSize = camera.ViewportSize

	-- Switched positions of X and Y to keep its consitent with final rotation
	currentRotation += Vector2.new(mouseDelta.Y * viewportSize.Y / viewportSize.X, mouseDelta.X)

	-- Prevents player from flipping vertical rotation
	currentRotation = Vector2.new(math.clamp(currentRotation.X, -45, 70), currentRotation.Y)

	local currentX = currentRotation.X
	local currentY = currentRotation.Y
	local rotation = CFrame.fromOrientation(math.rad(currentX), math.rad(-currentY), 0)

	local rootCFrame = humanoidRootPart.CFrame
	local targetCFrame = CFrame.new(rootCFrame.Position) * rotation * CAMERA_OFFSET

	camera.CFrame = getOcclusion(rootCFrame, targetCFrame)
end)
