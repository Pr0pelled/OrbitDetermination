--Drawing Kepler orbits using beams

type orbitInfo = {
	["TrueAnomaly"]: number,
	["SemiMajorAxis"]: number,
	["SemiLatusRectum"]: number,
	["EccentricityVector"]: Vector3,
	["Eccentricity"]: number,
	["Inclination"]: number,
	["AscendingNodeVector"]: Vector3,
	["LongitudeOfAscendingNode"]: number,
	["ArgumentOfPeriapsis"]: number,
	["StandardGravitationalParameter"]: number,
	["SpecificOrbitalEnergy"]: number
}

local thisModule = {}

--Helpers
local function createAttachment(position: Vector3, name: string)
	local attachment = Instance.new("Attachment")
	attachment.Name = name
	attachment.CFrame = CFrame.new(position)
	return attachment
end

local function createBeam(attachment0: Attachment, attachment1: Attachment, width: number, color: Color3)
	local beam = Instance.new("Beam")
	beam.Attachment0 = attachment0
	beam.Attachment1 = attachment1
	beam.Width0 = width
	beam.Width1 = width
	beam.Color = ColorSequence.new(color)
	beam.FaceCamera = true
	return beam
end

local function createNode(position: Vector3, color: Color3)
	local node = Instance.new("Part")
	node.CFrame = CFrame.new(position)
	node.Size = Vector3.new(0.5, 0.5, 0.5)
	node.Color = color
	node.CanCollide = false
	node.Anchored = true
	node.Shape = "Ball"

	return node
end

local function getRadius(semiMajorAxis: number, eccentricity: number, theta:number)
	return (semiMajorAxis * (1 - eccentricity^2)) / (1 + eccentricity * math.cos(theta))
end

local function getPositionFromRadius(radius: number, theta: number)
	return Vector3.new(radius * math.sin(theta), 0, radius * math.cos(theta))
end

--Module  methods
function thisModule.drawOrbit(info: orbitInfo, numPoints: number, color: Color3?)
	local mainPart = Instance.new("Part")
	mainPart.Size = Vector3.one
	mainPart.CFrame = CFrame.new(0, 0, 0)
	mainPart.Transparency = 1
	mainPart.Anchored = true
	mainPart.CanCollide = false

	local turnValue = 0
	if info.ArgumentOfPeriapsis > math.pi then
		turnValue = 2 * math.pi - info.ArgumentOfPeriapsis
	else
		turnValue = math.pi - info.ArgumentOfPeriapsis
	end

	print(info.ArgumentOfPeriapsis - (math.pi/4), info.ArgumentOfPeriapsis + (math.pi/4))

	local periapsisPosition = getPositionFromRadius(getRadius(info.SemiMajorAxis, info.Eccentricity, 0), 0 - turnValue)
	local apoapsisPosition = getPositionFromRadius(getRadius(info.SemiMajorAxis, info.Eccentricity, math.pi), math.pi - turnValue)
	local adjustedEccentricityVector = apoapsisPosition - periapsisPosition
	print(adjustedEccentricityVector)

	local lastAttachment: Attachment, firstAttachment: Attachment = nil
	for i = 0, numPoints, 1 do
		local theta
		if info.Eccentricity > 1 then
			theta = (math.pi + ((2 * math.pi) * (i / numPoints))) % (2 * math.pi)
		else
			theta = ((2 * math.pi) * (i / numPoints))
		end
		local r = getRadius(info.SemiMajorAxis, info.Eccentricity, theta + turnValue)
		local pos = getPositionFromRadius(r, theta)
		if (math.abs(pos.X) < math.abs(periapsisPosition.X) or math.abs(pos.Y) < math.abs(periapsisPosition.Y)) then --Trying to make it so that only the pertinent half of the hyperbola is shown.
			local attachment = createAttachment(pos, theta)
			attachment.Parent = mainPart
			if lastAttachment then
				createBeam(lastAttachment, attachment, 0.1, color or Color3.new(0, 0, 0)).Parent = mainPart
			else
				firstAttachment = attachment
			end
			lastAttachment = attachment
		end
	end
	if info.Eccentricity <= 1 then
		createBeam(lastAttachment, firstAttachment, 0.1, color or Color3.new(0, 0, 0)).Parent = mainPart
	end

	--Creating different important nodes

	--Periapsis
	createNode(getPositionFromRadius(getRadius(info.SemiMajorAxis, info.Eccentricity, 0), 0 - turnValue), Color3.fromRGB(0, 255, 0)).Parent = mainPart

	--Apoapsis
	if info.Eccentricity < 1 then
		createNode(getPositionFromRadius(getRadius(info.SemiMajorAxis, info.Eccentricity, math.pi), math.pi - turnValue), Color3.fromRGB(255, 0, 0)).Parent = mainPart
	end

	--Ascending Node
	createNode(getPositionFromRadius(getRadius(info.SemiMajorAxis, info.Eccentricity, -info.ArgumentOfPeriapsis), -info.ArgumentOfPeriapsis - turnValue), Color3.fromRGB(255, 0, 255)).Parent = mainPart

	--Descending Node
	createNode(getPositionFromRadius(getRadius(info.SemiMajorAxis, info.Eccentricity, math.pi - info.ArgumentOfPeriapsis), math.pi - info.ArgumentOfPeriapsis - turnValue), Color3.fromRGB(128, 0, 255)).Parent = mainPart

	mainPart.Parent = workspace

	return mainPart
end

return thisModule