--[[--------------------------------------------------------------------------
	CleverBot API for gLua
	
	License:
		The MIT License (MIT)
		
		Copyright (c) 2017 Mista-Tea
		
		
		Permission is hereby granted, free of charge, to any person obtaining a copy
		of this software and associated documentation files (the "Software"), to deal
		in the Software without restriction, including without limitation the rights
		to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
		copies of the Software, and to permit persons to whom the Software is
		furnished to do so, subject to the following conditions:
		
		The above copyright notice and this permission notice shall be included in all
		copies or substantial portions of the Software.
		
		THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
		IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
		FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
		AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
		LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
		OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
		SOFTWARE.
		
	Changelog:
		- Created March 19th, 2017

----------------------------------------------------------------------------]]

--[[--------------------------------------------------------------------------
-- Namespace Tables
--------------------------------------------------------------------------]]--

-- Create our namespace to hold class functions and variables
CleverBot = {
	URL_BASE         = "http://www.cleverbot.com/getreply?wrapper=MistaTeaLuaAPI&key=%s",
	URL_WRAPPER      = "&wrapper=MistaTeaLuaAPI",
	URL_APIKEY       = "&key=%s", -- obtain an API key at https://www.cleverbot.com/api/
	URL_INPUT        = "&input=%s",
	URL_CONVERSATION = "&cs=%s"
}
CleverBot.__index = CleverBot

-- Make our table callable via CleverBot() and return an instance object with the given API key
setmetatable( CleverBot, {
	__call = function( self, key )
		return setmetatable( {APIKEY = key, __index = self}, self )
	end
})

--[[--------------------------------------------------------------------------
-- Localized Functions & Variables
--------------------------------------------------------------------------]]--

local util = util
local http = http
local string = string
local assert = assert

--[[--------------------------------------------------------------------------
-- Namespace Functions
--------------------------------------------------------------------------]]--

-- Get/Set the API key
function CleverBot:GetAPIKey() return self.APIKEY       end
function CleverBot:SetAPIKey( key )   self.APIKEY = key end
-- Get/Set the CleverBot state (changes each call, maintains the conversation history)
function CleverBot:GetConversationID() return self.CONVERSATION_ID      end
function CleverBot:SetConversationID( id )    self.CONVERSATION_ID = id end
-- Get/Set the response from CleverBot
function CleverBot:GetResponse() return self.RESPONSE end
function CleverBot:SetResponse( str )   self.RESPONSE = str end
	
-- From https://gist.github.com/ignisdesign/4323051
function CleverBot:URLEncode( str )
	return str
	:gsub( '\n', '\r\n' )
	:gsub( '([^%w])', function( c ) return ("%%%02X"):format( string.byte( c ) ) end )
	:gsub( " ", "+" )
end

--[[--------------------------------------------------------------------------
--
-- 	CleverBot:Send( string, function, function, table )
--
--	Sends the given message to CleverBot. If successful, a JSON string will be returned
--	containing the response along with many of key-values. On failure, an error message will be returned.
--
--	Passing success and fail callbacks will allow asychronous handling of the output from CleverBot.
--]]--
function CleverBot:Send( text, callbackSuccess, callbackFail, headers )
	assert( isstring( self.APIKEY ), "Please set a valid API key via CleverBot:SetAPIKey()" )
	
	local url = self:BuildURL( text )
	
	local success = function( body, size, headers, code )
		if ( self ) then
			local json = util.JSONToTable( body )
			self:SetConversationID( json.cs )
			self:SetResponse( json.output )
			
			if ( callbackSuccess ) then
				callbackSuccess( json.output )
			end
		end
	end
	
	local fail = function( err )
		if ( self ) then
			if ( callbackFail ) then
				callbackFail( err )
			end
		end
	end
	
	http.Fetch( url, success, fail, headers )
end

--[[--------------------------------------------------------------------------
--
-- 	CleverBot:BuildURL( string )
--
--	Builds the URL string to query the CleverBot API with. The very first call
--	of a new CleverBot instance will not have a conversation ID, while every
--	subsequent call will have a new conversation ID each time. This is used to
--	maintain the current conversation with CleverBot, rather than starting a new
--	one on every request.
--]]--
function CleverBot:BuildURL( text )
	return
		self.URL_BASE:format( self.APIKEY )
		.. self.URL_WRAPPER
		.. self.URL_INPUT:format( self:URLEncode( text ) )
		.. (self.CONVERSATION_ID and self.URL_CONVERSATION:format( self.CONVERSATION_ID ) or '')
end