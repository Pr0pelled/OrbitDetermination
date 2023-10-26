--Determining Kepler Orbits

--Steps:
--[[
	1. Compute specific angular momentum (h) positon:cross(velocity)
	2. Compute the ascneding node vector (n) (0, 1, 0):cross(h)
	3. Compute eccentricity vector (e) (velocity:cross(h) / mu) - (position / position.Magnitude)
		- Compute standard gravitational parameter (Mu) G * (Orbiting Mass)
	4. Compute Semi-latus rectum and semi-major axis (p) (a)
		- p = h.Magnitude^2 / mu
		- a = p / (1 - e^2)
	5. Compute inclination (i) math.acos((0, 1, 0):dot(h) / h.Magnitude)
	6. Compute longitude of ascending node (omega) (math.acos(n.X / n.Magnitude))
		- (2 * math.pi - omega) if n.Z < 0
	7. Compute argument of periapsis (w) math.acos((n:dot(e)) / (n.Magnitude * e.Magnitude))
		- (2 * math.pi - w) if e.Y < 0
	8. Compute true anomaly (nu) math.acos(e:dot(position) / (e.Magnitude * r.Magnitude))
		- (2 * math.pi - nu) if position:dot(velocity) < 0
]]

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

--Mass multiplier
local massMultiplier = 10e10

local thisModule = {}

--Position and velocity should be relative to the central body
function thisModule.determineOrbit(position: Vector3, velocity: Vector3, centralBody: Part): orbitInfo
	local info: orbitInfo = {}
	local h = position:Cross(velocity)
	info.AscendingNodeVector = centralBody.CFrame.UpVector:Cross(h)

	--For non-inclined orbits:
	if info.AscendingNodeVector == Vector3.zero then
		info.AscendingNodeVector = centralBody.CFrame.RightVector
	end

	info.StandardGravitationalParameter = (6.67e-11) * (centralBody.Mass * massMultiplier)
	info.EccentricityVector = (velocity:Cross(h) / info.StandardGravitationalParameter) - position.Unit
	info.Eccentricity = info.EccentricityVector.Magnitude
	info.SpecificOrbitalEnergy = ((velocity.Magnitude^2) / 2) - (info.StandardGravitationalParameter / position.Magnitude)

	if info.Eccentricity == 0 then
		info.SemiLatusRectum = position.Magnitude
		info.SemiMajorAxis = position.Magnitude
	elseif info.Eccentricity < 1 then
		info.SemiMajorAxis = -(info.StandardGravitationalParameter / (2 * info.SpecificOrbitalEnergy))
		info.SemiLatusRectum = info.SemiMajorAxis * (1 - info.Eccentricity^2)
	elseif info.Eccentricity == 1 then
		info.SemiLatusRectum = (h.Magnitude)^2 / info.StandardGravitationalParameter
		info.SemiMajorAxis = info.SemiLatusRectum / (1 - info.Eccentricity^2)
	else
		info.SemiMajorAxis = (info.StandardGravitationalParameter / (2 * info.SpecificOrbitalEnergy))
		info.SemiLatusRectum = info.SemiMajorAxis * (1 - info.Eccentricity^2)
	end
	info.Inclination = math.acos(centralBody.CFrame.UpVector:Dot(h) / h.Magnitude)
	info.LongitudeOfAscendingNode = math.acos(centralBody.CFrame.RightVector:Dot(info.AscendingNodeVector) / info.AscendingNodeVector.Magnitude)
	info.ArgumentOfPeriapsis = math.acos(info.AscendingNodeVector:Dot(info.EccentricityVector) / (info.AscendingNodeVector.Magnitude * info.Eccentricity))
	info.TrueAnomaly = math.acos(info.EccentricityVector:Dot(position) / (info.Eccentricity * position.Magnitude))

	--Checking signs of vectors to change angle measurements
	--Longitude of Ascending Node (Omega)
	if centralBody.CFrame.LookVector:Dot(info.AscendingNodeVector) < 0 then
		info.LongitudeOfAscendingNode = (2 * math.pi) - info.LongitudeOfAscendingNode
	end

	--Argument of periapsis (w)
	if centralBody.CFrame.UpVector:Dot(info.EccentricityVector) < 0 then
		info.ArgumentOfPeriapsis = (2 * math.pi) - info.ArgumentOfPeriapsis
	end

	--True Anomaly
	if position:Dot(velocity) < 0 then
		info.TrueAnomaly = (2 * math.pi) - info.TrueAnomaly
	end

	return info;
end

return thisModule