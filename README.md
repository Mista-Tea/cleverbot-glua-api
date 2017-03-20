# cleverbot-glua-api
An OOP implementation of the CleverBot API for gLua (includes non-standard Lua functions).
Obtain an API key at https://www.cleverbot.com/api/

See the condensed branch if you want to drop this into your own addon https://github.com/Mista-Tea/cleverbot-glua-api/tree/condensed

## Functions
```lua
-- Creates a new CleverBot instance with the given API key
CleverBot( str )

-- Sends the given string to the CleverBot API. Passing callback functions will allow
-- you to handle the responses when they arrive asynchronously
CleverBot:Send( str, callbackSuccess, callbackFail, headers )

-- Sets the API key if you didn't provide it when creating the CleverBot instance
CleverBot:SetAPIKey( str )
-- Gets the API key if it has been set
CleverBot:GetAPIKey()

-- Gets the last response from CleverBot
CleverBot:GetResponse()

-- Gets the conversation ID, or nil if nothing has been sent to CleverBot yet
CleverBot:GetConversationID()
```

## Basic Usage
```lua
-- Creates a new CleverBot instance with the given API key
local bot = CleverBot( "<YOUR_API_KEY>" )

-- Sends "Hello, world!" to the CleverBot API and prints out the response (or error)
bot:Send( "Hello, world!", print, print )
```

## Other Examples
```lua
local bot = CleverBot()
bot:SetAPIKey( "<YOUR_API_KEY>" )

bot:Send( "Hello, world!",
    function( response ) -- success
        -- Remove unwanted characters from the response
        response = response:gsub( "\n", "" ):gsub( "\r", "" ):gsub( ":", "" ):gsub( ";", "" )
        
        -- Make console say the response
        game.ConsoleCommand( "say " .. response )
    end,
    function( err ) -- fail
        -- Print out the error message to console
        ErrorNoHalt( "CleverBot error: " .. tostring(err) )
    end
)
```
