local twilio = require "plugin.twilio"
local json = require "json"
local widget = require "widget" 

native.showPopup( "requestAppPermission", {appPermission = "android.permission.RECORD_AUDIO", urgency = "Critical", } )

local function twilioListener(event)
	print(event.type .. ": " .. json.encode(event))
end

Runtime:addEventListener("twilioEvent", twilioListener)
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

local tokenServiceUrl = "CAPABILITY_REQUEST_URL"

local buttons = {}
local width = 200
local height = 35
local fontSize = 10

buttons[1] = native.newTextField( 0, 0, width, height-10 )
buttons[1].text = clientName
buttons[1]:resizeFontToFitHeight()
buttons[1]:addEventListener( "userInput", function(e) clientName = e.target.text end )

buttons[2] = native.newTextField( 0, 0, width, height-10 )
buttons[2].text = toName
buttons[2]:resizeFontToFitHeight()
buttons[2]:addEventListener( "userInput", function(e) toName = e.target.text end )


buttons[3] = widget.newButton{ width = width, height = height, fontSize = fontSize, label = "initialize",
	onRelease = function() twilio.initialize(); twilio.release(); network.request( tokenServiceUrl .. clientName, "GET", networkListener ) end}

buttons[4] = widget.newButton{ width = width, height = height, fontSize = fontSize, label = "Disconnect All",
	onRelease = function() twilio.disconnectAll() end}
buttons[5] = widget.newButton{ width = width, height = height, fontSize = fontSize, label = "Print Device Capabilities",
	onRelease = function() print("Capabilities: ".. json.encode(twilio.getCapabilities()) ) end}
buttons[6] = widget.newButton{ width = width, height = height, fontSize = fontSize, label = "Print Device State",
	onRelease = function() print("Device State: " .. tostring(twilio.getState()) ) end}

buttons[7] = widget.newButton{ width = width, height = height, fontSize = fontSize, label = "Connect",
    onRelease = function() twilio.connect({PhoneNumber=toName}) end}

buttons[8] = widget.newButton{ width = width, height = height, fontSize = fontSize, label = "Print Connection Params",
    onRelease = function() print("Connection Params: ".. json.encode(twilio.getConnectionParameters()) ) end}

buttons[9] = widget.newButton{ width = width, height = height, fontSize = fontSize, label = "Print Connection State",
    onRelease = function() print("Connection State: " .. tostring(twilio.getConnectionState())) end}

buttons[10] = widget.newButton{ width = width, height = height, fontSize = fontSize, label = "Accept Incoming Connection",
    onRelease = function() twilio.accept() end}
buttons[11] = widget.newButton{ width = width, height = height, fontSize = fontSize, label = "Ignore Incoming Connection",
    onRelease = function() twilio.ignore() end}
buttons[12] = widget.newButton{ width = width, height = height, fontSize = fontSize, label = "Reject Incoming Connection",
    onRelease = function() twilio.reject() end}
buttons[13] = widget.newButton{ width = width, height = height, fontSize = fontSize, label = "Disconnect Current Connection",
    onRelease = function() twilio.disconnect() end}


local columns = 1
local bttnsInColumn = math.ceil(#buttons/columns)
for i = 1, #buttons do
	local columnNum = math.ceil(i/bttnsInColumn)
	buttons[i].x = display.contentWidth/(columns+1) * columnNum
	buttons[i].y = display.contentHeight/(bttnsInColumn+1) * ((i-1) % bttnsInColumn + 1)
end