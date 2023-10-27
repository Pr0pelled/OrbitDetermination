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
	["SpecificOrbitalEnergy"]: number,
	["OrbitUpVector"]: Vector3,
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
	node.Material = Enum.Material.SmoothPlastic
	node.CanCollide = false
	node.Anchored = true
	node.Shape = "Ball"

	return node
end

--Polar-coordinate formula for Kepler Orbits
local function getRadius(semiMajorAxis: number, eccentricity: number, theta:number)
	return (semiMajorAxis * (1 - eccentricity^2)) / (1 + eccentricity * math.cos(theta))
end

--Using trig to get the position in Cartesian Coordinates
local function getPositionFromRadius(radius: number, theta: number)
	return Vector3.new(radius * math.sin(theta), 0, radius * math.cos(theta))
end

--Checks to assure a given position is not past a plane perpendicaly to the periapsis direction
local function isWithinBounds(position: Vector3, bound: Vector3): boolean
	return (position - bound):Dot(bound) < bound.Magnitude
end

--Module  methods
function thisModule.drawOrbit(info: orbitInfo, numPoints: number, color: Color3?)

	--Creating a parent part for the entire display
	local mainPart = Instance.new("Part")
	mainPart.Size = Vector3.one
	mainPart.CFrame = CFrame.new(0, 0, 0)
	mainPart.Transparency = 1
	mainPart.Anchored = true
	mainPart.CanCollide = false

	--Calculating an offset for the orbit
	local turnValue = math.pi - info.ArgumentOfPeriapsis

	--For hyperbolas
	if info.Eccentricity > 1 then
		turnValue -= math.pi
	end

	--Calculating the position of a periapsis for bound-checking
	local periapsisPosition = getPositionFromRadius(getRadius(info.SemiMajorAxis, info.Eccentricity, 0), 0 - turnValue)

	local lastAttachment: Attachment, firstAttachment: Attachment = nil
	for i = 0, numPoints, 1 do
		local theta = (2 * math.pi) * (i / numPoints) --The angle
		local r = getRadius(info.SemiMajorAxis, info.Eccentricity, theta + turnValue) --The radius
		local pos = getPositionFromRadius(r, theta) --The position of this attachment

		--Determining whether to draw this attachment
		if info.Eccentricity < 1 or isWithinBounds(pos, periapsisPosition) then --Trying to make it so that only the pertinent half of the hyperbola is shown.
			local attachment = createAttachment(pos, theta)
			attachment.Parent = mainPart
			if lastAttachment then
				createBeam(lastAttachment, attachment, 0.1, color or Color3.new(0, 0, 0)).Parent = mainPart
			elseif firstAttachment == nil then
				firstAttachment = attachment
			end
			lastAttachment = attachment
		else
			lastAttachment = nil
		end
	end
	if info.Eccentricity <= 1 then
		createBeam(lastAttachment, firstAttachment, 0.1, color or Color3.new(0, 0, 0)).Parent = mainPart
	end

	--Creating different important nodes
	local nodePos: Vector3 = nil

	--Periapsis
	createNode(periapsisPosition, Color3.fromRGB(0, 255, 0)).Parent = mainPart --I don't have to check whether it's in bounds; it always will be

	--Apoapsis
	nodePos = getPositionFromRadius(getRadius(info.SemiMajorAxis, info.Eccentricity, math.pi), math.pi - turnValue)
	if info.Eccentricity < 1 or isWithinBounds(nodePos, periapsisPosition) then
		createNode(nodePos, Color3.fromRGB(255, 0, 0)).Parent = mainPart
	end

	--Ascending Node
	nodePos = getPositionFromRadius(getRadius(info.SemiMajorAxis, info.Eccentricity, -info.ArgumentOfPeriapsis), -info.ArgumentOfPeriapsis - turnValue)
	if info.Eccentricity < 1 or isWithinBounds(nodePos, periapsisPosition) then
		createNode(nodePos, Color3.fromRGB(255, 0, 255)).Parent = mainPart
	end

	--Descending Node
	nodePos = getPositionFromRadius(getRadius(info.SemiMajorAxis, info.Eccentricity, math.pi - info.ArgumentOfPeriapsis), math.pi - info.ArgumentOfPeriapsis - turnValue)
	if info.Eccentricity < 1 or isWithinBounds(nodePos, periapsisPosition) then
		createNode(nodePos, Color3.fromRGB(128, 0, 255)).Parent = mainPart
	end

	--Returning the whole orbit part
	return mainPart
end

return thisModule