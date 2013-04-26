-- 
-- Abstract: Slide View sample app
--  
-- Version: 1.0
-- 
-- Sample code is MIT licensed, see http://www.coronalabs.com/links/code/license
-- Copyright (C) 2010 Corona Labs Inc. All Rights Reserved.
--
-- Demonstrates how to display a set of images in a series that 
-- the user can swipe from left to right, using the methods 
-- provided in slideView.lua.

display.setStatusBar( display.HiddenStatusBar ) 

--local slideView = require("slideView")
local slideView = require("slideView_loadatonce")
	
local myImages = {
	"myPhotos1.jpg",
	"myPhotos2.jpg",
	"myPhotos3.jpg",
	"myPhotos4.jpg",
	"myPhotos5.jpg",
	"myPhotos6.jpg",
	"myPhotos7.jpg",
	"myPhotos8.jpg"
}		

--slideView.new( myImages )
local slide = slideView.new{
	data = myImages,
	callback = function(row1)
		local group = display.newGroup()
		local graph = display.newImage(row1, 0,0,true)
		group:insert(graph)
		return group
	end
}

local function garbagePrinting()
	collectgarbage("collect")
    local memUsage_str = string.format( "memUsage = %.3f KB", collectgarbage( "count" ) )
    print( memUsage_str )
    local texMemUsage_str = system.getInfo( "textureMemoryUsed" )
    texMemUsage_str = texMemUsage_str/1000
    texMemUsage_str = string.format( "texMemUsage = %.3f MB", texMemUsage_str )
    print( texMemUsage_str )
end

Runtime:addEventListener( "enterFrame", garbagePrinting )
--[[

-- Examples of other parameters:

-- Show a background image behind the slides
slideView.new( myImages, "bg.jpg" )

-- Insert space at the top and bottom
slideView.new( myImages, nil, 40, 60 )

--]]

