local twilio = require "plugin.twilio"
local json = require "json"
local widget = require "widget" 


-- Request necessary permissions before doing anything twilio related.
native.showPopup( "requestAppPermission", {appPermission = "android.permission.RECORD_AUDIO", urgency = "Critical", } )


-- Create a listener that for all twilio events
local function twilioListener(event)
	print(event.type .. ": " .. json.encode(event))
end

Runtime:addEventListener("twilioEvent", twilioListener)

--Enable presence events (disabled by default)
twilio.setReceivePresenceEvents(true)

local capabilityToken = ""
local clientName = "client"
local toName = "toClient"
local function networkListener( event )

    if ( event.isError ) then
        print( "Network error: ", event.response )
    else
        print ( "RESPONSE: " .. event.response )
        capabilityToken = event.response
        twilio.createDevice(capabilityToken)
    end
end

--Url for requesting the capability token
local tokenServiceUrl = "CAPABILITY_REQUEST_URL"

local buttons = {}
local width = 200
local height = 35
local fontSize = 10


--Set the client name
buttons[1] = native.newTextField( 0, 0, width, height-10 )
buttons[1].text = clientName
buttons[1]:resizeFontToFitHeight()
buttons[1]:addEventListener( "userInput", function(e) clientName = e.target.text end )


--set the name of the call receiver
buttons[2] = native.newTextField( 0, 0, width, height-10 )
buttons[2].text = toName
buttons[2]:resizeFontToFitHeight()
buttons[2]:addEventListener( "userInput", function(e) toName = e.target.text end )


--Initialize twilio and request a capability token. Since token expires after a certain period of time, you have to reqquest it every time the app relaunches
buttons[3] = widget.newButton{ width = width, height = height, fontSize = fontSize, label = "initialize",
	onRelease = function() twilio.initialize(); twilio.release(); network.request( tokenServiceUrl .. clientName, "GET", networkListener ) end}

-- Disconnect All calls
buttons[4] = widget.newButton{ width = width, height = height, fontSize = fontSize, label = "Disconnect All",
	onRelease = function() twilio.disconnectAll() end}

-- Current capabilities of the Device. Returns table
buttons[5] = widget.newButton{ width = width, height = height, fontSize = fontSize, label = "Print Device Capabilities",
	onRelease = function() print("Capabilities: ".. json.encode(twilio.getCapabilities()) ) end}

--Retrieves the current state of the device. Returns a string. Possible values are OFFLINE, READY, and BUSY.
buttons[6] = widget.newButton{ width = width, height = height, fontSize = fontSize, label = "Print Device State",
	onRelease = function() print("Device State: " .. tostring(twilio.getState()) ) end}

--Creates a new connection to the Twilio application specified in the capability token of the Device.
buttons[7] = widget.newButton{ width = width, height = height, fontSize = fontSize, label = "Connect",
    onRelease = function() twilio.connect({PhoneNumber=toName}) end}


--Retrieves the set of application parameters associated with this connection. Returns a table.
buttons[8] = widget.newButton{ width = width, height = height, fontSize = fontSize, label = "Print Connection Params",
    onRelease = function() print("Connection Params: ".. json.encode(twilio.getConnectionParameters()) ) end}

--Retrieves the current state of the connection. Returns a string. Possible values are PENDING, CONNECTING, CONNECTED, and DISCONNECTED.
buttons[9] = widget.newButton{ width = width, height = height, fontSize = fontSize, label = "Print Connection State",
    onRelease = function() print("Connection State: " .. tostring(twilio.getConnectionState())) end}

--Accepts an incoming connection request.
buttons[10] = widget.newButton{ width = width, height = height, fontSize = fontSize, label = "Accept Incoming Connection",
    onRelease = function() twilio.accept() end}

--Ignores an incoming connection request.
buttons[11] = widget.newButton{ width = width, height = height, fontSize = fontSize, label = "Ignore Incoming Connection",
    onRelease = function() twilio.ignore() end}

--Rejects an incoming connection request.
buttons[12] = widget.newButton{ width = width, height = height, fontSize = fontSize, label = "Reject Incoming Connection",
    onRelease = function() twilio.reject() end}

--Disconnect the connection.
buttons[13] = widget.newButton{ width = width, height = height, fontSize = fontSize, label = "Disconnect Current Connection",
    onRelease = function() twilio.disconnect() end}


--postion the buttons
local columns = 1
local bttnsInColumn = math.ceil(#buttons/columns)
for i = 1, #buttons do
	local columnNum = math.ceil(i/bttnsInColumn)
	buttons[i].x = display.contentWidth/(columns+1) * columnNum
	buttons[i].y = display.contentHeight/(bttnsInColumn+1) * ((i-1) % bttnsInColumn + 1)
end