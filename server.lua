--Basic config Setup
lBox = -0.15
lCam = 0.3
local isDebugMode = false

resourceRoot = getResourceRootElement( getThisResource())
root = getRootElement()

speedCamera = { }
tutorInfo = { }

--Function
function gradToRad(val)
	return ((math.pi * 2)/360) * val
end

function standFace(val)
	if(val == "down") then
		return 0
	elseif (val == "up") then
		return 0
	elseif (val == "left") then
		return -180
	elseif (val == "right") then
		return 0
	end
end

function standDirection(val)
	if(val == "down") then
		return 0
	elseif (val == "up") then
		return 0
	elseif (val == "left") then
		return 90
	elseif (val == "right") then
		return 90
	end
end

function validVehicle(vehicle)
	if getVehicleType ( vehicle ) == "Automobile" then
		return true
	elseif getVehicleType ( vehicle ) == "Bike" then
		local vehicleID = getElementModel ( vehicle )
		 
		if vehicleName == 509 or vehicleName == 481 then
			return false
		end
		
		return true
	end
end

function getElementSpeed(element,unit)
	if (unit == nil) then unit = 0 end
	if (isElement(element)) then
		local x,y,z = getElementVelocity(element)
		if (unit=="mph" or unit==1 or unit =='1') then
			return (x^2 + y^2 + z^2) ^ 0.5 * 100
		else
			return (x^2 + y^2 + z^2) ^ 0.5 * 1.8 * 100
		end
	else
		outputDebugString("Not an element. Can't get speed")
		return false
	end
end

function resetTutor(vehicle)
	removeElementData ( vehicle, "gateTick")
	removeElementData ( vehicle, "tutorID")
	removeElementData ( vehicle, "gateMarker")	
end

function createTutor(vehicle, id, marker)
	setElementData ( vehicle, "gateTick", getTickCount() )
	setElementData ( vehicle, "tutorID", id)		
	setElementData ( vehicle, "gateMarker", marker)
end

function checkSpeed(player, speed, requiredSpeed, ticketCost, wanted)
	if (speed > requiredSpeed ) then
		outputDebugString ( "Over Speed!!!!!" )
		local playerAcc = getPlayerAccount(player)
		local pWanted = getPlayerWantedLevel(player)
		local pMoney = getPlayerMoney(player)
		local price = ticketCost * (speed - requiredSpeed)
		
		if (pMoney >= price ) then							
			takePlayerMoney(player, price)
			outputChatBox("You have paid "..price.." for a ticket", player, 255, 200, 0, false)							
		else
			setPlayerWantedLevel(player, math.min(6, getPlayerWantedLevel(player) + wanted))
			outputChatBox("You don't have enough money to pay the ticket. Wanted Level increased.", player, 255, 200, 0, false)
		end
		fadeCamera(player, false, 0.5, 255, 255, 255)
		setTimer(fadeCamera, 250, 1, player, true, 1.0, 255, 255, 255)
		return true
	end
	return false
end

function init()	
	--Loading Configuration
	local useBlip = get( "autovelox.useIcon" )	
	isDebugMode = get( "autovelox.isDebug" )
	
	local alpha = 0			
	if isDebugMode then
		alpha = 255
	end
	
	-- Loading of SpeedCameras
	
	local speedMap = xmlLoadFile( "config.xml" )
	local speeds = 0
	
	while( xmlFindChild( speedMap, "speedcam", speeds ) ) do
		local tempID = speeds + 1
		speedCamera[ tempID ] = { }
		
		local speed_node = xmlFindChild( speedMap, "speedcam", speeds )
		
		speedCamera[ tempID ].speedX = tonumber(xmlNodeGetAttribute(speed_node, "x"))
		speedCamera[ tempID ].speedY = tonumber(xmlNodeGetAttribute(speed_node, "y"))
		speedCamera[ tempID ].speedZ = tonumber(xmlNodeGetAttribute(speed_node, "z"))
		speedCamera[ tempID ].size = tonumber(xmlNodeGetAttribute(speed_node, "size")) or 6
		speedCamera[ tempID ].angle = tonumber(xmlNodeGetAttribute(speed_node, "angle")) or 2
		speedCamera[ tempID ].direction = tostring(xmlNodeGetAttribute(speed_node, "standDirection")) or "down"
		
		speedCamera[ tempID ].ticketCost = tonumber(xmlNodeGetAttribute(speed_node, "ticketCost")) or 15
		speedCamera[ tempID ].requiredSpeed = tonumber(xmlNodeGetAttribute(speed_node, "requiredSpeed")) or 50
		speedCamera[ tempID ].ticketWanted = tonumber(xmlNodeGetAttribute(speed_node, "ticketWanted")) or 2
		
		local x = speedCamera[ tempID ].speedX
		local y = speedCamera[ tempID ].speedY
		local z = speedCamera[ tempID ].speedZ
		local dir = speedCamera[ tempID ].direction
		local size = speedCamera[ tempID ].size		

		local ang = gradToRad(speedCamera[ tempID ].angle)
		local angMark = gradToRad(speedCamera[ tempID ].angle + 15)

		local boxCos = lBox * math.cos(ang)
		local boxSen = lBox * math.sin(ang)

		local camCos = lCam * math.cos(ang)
		local camSen = lCam * math.sin(ang)		

		local markCos = speedCamera[ tempID ].size * math.cos(angMark)
		local markSen = speedCamera[ tempID ].size * math.sin(angMark)
		
		--Generating Box
		createObject ( 1625, x - boxCos, y - boxSen, z + 3, 0, 0, speedCamera[ tempID ].angle )
		createObject ( 1625, x + boxCos, y + boxSen, z + 3, 0, 0, speedCamera[ tempID ].angle + 180)

		--Generating Stand
		createObject ( 16101, x, y, z + 3, standDirection(dir), 180, standFace(dir) + speedCamera[ tempID ].angle)

		--Generating Camera
		createObject ( 1886, x + camCos, y + camSen, z + 3.5, 15, 0, 90 + speedCamera[ tempID ].angle)
		
		--Marker		
		speedCamera[ tempID ].marker = createMarker ( x + markCos, y + markSen, z, "cylinder", size, 0, 0, 255, alpha)
		
		if isDebugMode then
			outputDebugString ( "New autovelox at:" .. x .. " ".. y .. " " .. z .. " ".. size.. " ".. dir .. " " .. standDirection(dir) .." ".. standFace(dir))
		end
		
		--Blip
		if useBlip then			
			local blip = createBlip(speedCamera[ tempID ].speedX, speedCamera[ tempID ].speedY, speedCamera[ tempID ].speedZ, 0, 1, 255, 0, 0, 255, 0, 70, root)
			setBlipVisibleDistance(blip, 200)
		end
		speeds = speeds + 1
	end
	
	-- Loading of Waring Sign
	
	local signMap = xmlLoadFile( "config.xml" )	
	local signs = 0
	
	while( xmlFindChild( signMap, "speedsign", signs ) ) do	
		
		local sign_node = xmlFindChild( signMap, "speedsign", signs )
		
		signX = tonumber(xmlNodeGetAttribute(sign_node, "x"))
		signY = tonumber(xmlNodeGetAttribute(sign_node, "y"))
		signZ = tonumber(xmlNodeGetAttribute(sign_node, "z"))
		angle = tonumber(xmlNodeGetAttribute(sign_node, "angle")) or 0
		
		createObject ( 3380, signX, signY, signZ, 0, 0, angle)
		
		if isDebugMode then
			outputDebugString ( "New sign at:" .. signX .. " ".. signY .. " " .. signZ)
		end
		signs = signs + 1
	end

	--Loading of Tutor
	
	local tutorMap = xmlLoadFile( "config.xml" )	
	local tutors = 0
	
	while( xmlFindChild( signMap, "tutor", tutors ) ) do
		local tempID = tutors + 1
		tutorInfo[ tempID ] = { }
		
		local tutor_node = xmlFindChild( tutorMap, "tutor", tutors )
		
		if xmlFindChild( tutor_node, "gateA", 0 ) and xmlFindChild( tutor_node, "gateB", 0 ) then
			
			tutorInfo[ tempID ].ticketCost = tonumber(xmlNodeGetAttribute( tutor_node, "ticketCost")) or 15
			tutorInfo[ tempID ].requiredSpeed = tonumber(xmlNodeGetAttribute( tutor_node, "requiredSpeed")) or 50
			tutorInfo[ tempID ].ticketWanted = tonumber(xmlNodeGetAttribute( tutor_node, "ticketWanted")) or 2
			tutorInfo[ tempID ].distance = tonumber(xmlNodeGetAttribute( tutor_node, "distance")) or 2
			
			local a_node = xmlFindChild( tutor_node, "gateA", 0 )
			tutorInfo[ tempID ].A = { }
			
			tutorInfo[ tempID ].A.posX = tonumber(xmlNodeGetAttribute( a_node, "x" ))
            tutorInfo[ tempID ].A.posY = tonumber(xmlNodeGetAttribute( a_node, "y" ))
            tutorInfo[ tempID ].A.posZ = tonumber(xmlNodeGetAttribute( a_node, "z" ))	
			tutorInfo[ tempID ].A.size = tonumber(xmlNodeGetAttribute( a_node, "size")) or 20
			
			local xA = tutorInfo[ tempID ].A.posX
			local yA = tutorInfo[ tempID ].A.posY
			local zA = tutorInfo[ tempID ].A.posZ
			local sizeA = tutorInfo[ tempID ].A.size
			
			--Marker A			
			tutorInfo[ tempID ].A.marker = createMarker ( xA, yA, zA, "cylinder", sizeA, 0, 0, 255, alpha)
			
			if useBlip then			
				local blip = createBlip(xA, yA, zA, 0, 1, 0, 0, 255, 255, 0, 70, root)
				setBlipVisibleDistance(blip, 200)
			end
		
			
			local b_node = xmlFindChild( tutor_node, "gateB", 0 )
			tutorInfo[ tempID ].B = { }
			
			tutorInfo[ tempID ].B.posX = tonumber(xmlNodeGetAttribute( b_node, "x" ))
            tutorInfo[ tempID ].B.posY = tonumber(xmlNodeGetAttribute( b_node, "y" ))
            tutorInfo[ tempID ].B.posZ = tonumber(xmlNodeGetAttribute( b_node, "z" ))	
			tutorInfo[ tempID ].B.size = tonumber(xmlNodeGetAttribute( b_node, "size")) or 20
			
			local xB = tutorInfo[ tempID ].B.posX
			local yB = tutorInfo[ tempID ].B.posY
			local zB = tutorInfo[ tempID ].B.posZ
			local sizeB = tutorInfo[ tempID ].B.size
			
			--Marker B				
			tutorInfo[ tempID ].B.marker = createMarker ( xB, yB, zB, "cylinder", sizeB, 0, 0, 255, alpha)
			
			if useBlip then			
				local blip = createBlip(xB, yB, zB, 0, 1, 0, 0, 255, 255, 0, 70, root)
				setBlipVisibleDistance(blip, 200)
			end
			
		end
		
		tutors = tutors + 1
	end
end

addEventHandler( "onResourceStart", resourceRoot, init)

function playerEnterMarker(marker)

	if (not isPedInVehicle (source)) then return end
	local vehicle = getPedOccupiedVehicle(source)		
	
	if (getElementType(vehicle) == "vehicle" and validVehicle(vehicle) ) then
	
		local driver = getVehicleOccupant ( vehicle )
		
		if (driver) then					
			if ( driver ~= source ) then return end
			
			-- Speedcamera
			for k, v in pairs( speedCamera ) do
				if marker == speedCamera[ k ].marker then
			
					speed = math.floor(getElementSpeed(vehicle, "kph"))
					
					checkSpeed(driver, speed, speedCamera[ k ].requiredSpeed, speedCamera[ k ].ticketCost, speedCamera[ k ].ticketWanted)					
				end
			end
			
			-- Tutor
			for k, v in pairs( tutorInfo ) do
				if(marker == tutorInfo[ k ].A.marker) or (marker == tutorInfo[ k ].B.marker) then					
					
					local tick =  getElementData ( vehicle, "gateTick" )
					if (tick) then						
						if( getElementData ( vehicle, "tutorID" ) == k ) and ( getElementData ( vehicle, "gateMarker" ) ~= marker ) then
						
							local timePassed = (getTickCount() - tick) / 1000
							local distance = tutorInfo[ k ].distance
							local speed = ( distance/timePassed ) * 3.6
							
							if isDebugMode then
								outputDebugString("Medium speed: " .. speed)
							end	
							
							checkSpeed(driver, speed, tutorInfo[ k ].requiredSpeed, tutorInfo[ k ].ticketCost, tutorInfo[ k ].ticketWanted)
							resetTutor(vehicle)
							return
						else
							resetTutor(vehicle)
							createTutor(vehicle, k, marker)
							
							if isDebugMode then
								outputDebugString("Gate changed or reused; Resetting gate")
							end
							
							return
						end						
					else
						if isDebugMode then
							outputDebugString ( "New Tutor Target" )
						end
						
						createTutor( vehicle, k, marker )
						return						
					end
				end
			end
		end
    end
end
addEventHandler( "onPlayerMarkerHit", root, playerEnterMarker )