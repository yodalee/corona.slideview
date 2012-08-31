-- slideView.lua
-- 
-- Version 1.0 
--
-- Copyright (C) 2010 ANSCA Inc. All Rights Reserved.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy of 
-- this software and associated documentation files (the "Software"), to deal in the 
-- Software without restriction, including without limitation the rights to use, copy, 
-- modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, 
-- and to permit persons to whom the Software is furnished to do so, subject to the 
-- following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all copies 
-- or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
-- INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
-- PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
-- FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR 
-- OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER 
-- DEALINGS IN THE SOFTWARE.

-- modify by yodalee at 20120830
-- 2012-08-30: [add] callback function for customize slide but a simple image

module(..., package.seeall)

local screenW = display.contentWidth
--local screenH = display.contentHeight
local viewableScreenW, viewableScreenH = display.viewableContentWidth, display.viewableContentHeight
local screenOffsetW, screenOffsetH = display.contentWidth -  display.viewableContentWidth, display.contentHeight - display.viewableContentHeight

local itemNum = nil
local items = nil
local touchListener, nextItem, prevItem, cancelMove, initItem
local slideBackground
local imageNumberText, imageNumberTextShadow

function newItem(params)
	local data = params.data
	local top = params.top
	local bottom = params.bottom
	local callback = params.callback
	local id = params.id
	local x = params.x
	local y = params.y

	local thisItem = display.newGroup()
	thisItem.id = id
	thisItem.data = data
	thisItem.top = top
	thisItem.bottom = bottom
	local t = callback(data)
	thisItem:insert( t )
	thisItem:setReferencePoint(display.CenterReferencePoint)
	if thisItem.width > 0.6*viewableScreenW then
		thisItem.xScale, thisItem.yScale = 0.6*viewableScreenW/thisItem.width,0.6*viewableScreenW/thisItem.width
	end
	if x then thisItem.x = x end
	if y then thisItem.y = y end
	return thisItem
end

function new(params)
	local textSize = 48
	local data = params.data
	local background = params.background
	local top = params.top or 20
	local bottom = params.bottom or 48
	local pad = 20
	local callback = params.callback

	local screenH = viewableScreenH-(top+bottom)

	local g = display.newGroup()
		
	if background then
		slideBackground = display.newImage(background, 0, 0, true)
	else
		slideBackground = display.newRect( 0, 0, screenW, screenH )
		slideBackground:setFillColor(0, 0, 0)
	end
	g:insert(slideBackground)
	
	items = {}
	for i = 1,2 do
		local thisItem = newItem{
			data = data[i],
			top = top,
			bottom = bottom,
			callback = callback,
			id = i,
			x = screenW*1.5+pad,
			y = screenH*.5
		}
		if (i == 1) then thisItem.x = screenW*.5 end -- all items offscreen except the first one
		g:insert(thisItem)
		items[i] = thisItem
	end
	
	itemNum = 1
	g.x = 0
	g.y = top + display.screenOriginY
	function touchListener (self, touch) 
		local phase = touch.phase
		print("slides", phase)
		if ( phase == "began" ) then
            -- Subsequent touch events will target button even if they are outside the contentBounds of button
            display.getCurrentStage():setFocus( self )
            self.isFocus = true

			startPos = touch.x
			prevPos = touch.x
        elseif( self.isFocus ) then
			if ( phase == "moved" ) then
				if tween then transition.cancel(tween) end
				print(itemNum)
				local delta = touch.x - prevPos
				prevPos = touch.x
				items[itemNum].x = items[itemNum].x + delta
				if (items[itemNum-1]) then
					items[itemNum-1].x = items[itemNum-1].x + delta
				end
				if (items[itemNum+1]) then
					items[itemNum+1].x = items[itemNum+1].x + delta
				end
			elseif ( phase == "ended" or phase == "cancelled" ) then
				dragDistance = touch.x - startPos
				print("dragDistance: " .. dragDistance)
				if (dragDistance < -40 and itemNum < #items) then nextItem()
				elseif (dragDistance > 40 and itemNum > 1) then prevItem()
				else cancelMove()
				end
				if ( phase == "cancelled" ) then cancelMove() end
                -- Allow touch events to be sent normally to the objects they "hit"
                display.getCurrentStage():setFocus( nil )
                self.isFocus = false
			end
		end
					
		return true
		
	end
	function cancelTween()
		if prevTween then transition.cancel(prevTween) end
		prevTween = tween 
	end
	function nextItem()
		tween = transition.to( items[itemNum], {time=400, x=(screenW*.5 + pad)*-1, transition=easing.outExpo } )
		tween = transition.to( items[itemNum+1], {time=400, x=screenW*.5, transition=easing.outExpo } )
		itemNum = itemNum + 1
		if itemNum+1 <= #data then
			local thisItem = newItem{
				data = data[itemNum+1],
				top = top,
				bottom = bottom,
				callback = callback,
				id = i,
				x = screenW * 1.5 + pad,
				y = screenH*.5
			}
			g:insert(thisItem)
			items[itemNum+1] = thisItem
		end
		if itemNum-2>0 then items[itemNum-2]:removeSelf() end

		initItem(itemNum)
	end
	
	function prevItem()
		tween = transition.to( items[itemNum], {time=400, x=screenW*1.5+pad, transition=easing.outExpo } )
		tween = transition.to( items[itemNum-1], {time=400, x=screenW*.5, transition=easing.outExpo } )
		itemNum = itemNum - 1
		if itemNum-1 > 0 then
			local thisItem = newItem{
				data = data[itemNum-1],
				top = top,
				bottom = bottom,
				callback = callback,
				id = i,
				x = -1 * screenW*1.5-pad,
				y = screenH*.5
			}
			g:insert(thisItem)
			items[itemNum-1] = thisItem
		end
		if itemNum+2 <= #data then items[itemNum+2]:removeSelf() end
		initItem(itemNum)
	end
	
	function cancelMove()
		tween = transition.to( items[itemNum], {time=400, x=screenW*.5, transition=easing.outExpo } )
		tween = transition.to( items[itemNum-1], {time=400, x=(screenW*.5 + pad)*-1, transition=easing.outExpo } )
		tween = transition.to( items[itemNum+1], {time=400, x=screenW*1.5+pad, transition=easing.outExpo } )
	end
	function initItem(num)
		if (num < #items) then
			items[num+1].x = screenW*1.5 + pad			
		end
		if (num > 1) then
			items[num-1].x = (screenW*.5 + pad)*-1
		end
		--setSlideNumber()
	end

	slideBackground.touch = touchListener
	slideBackground:addEventListener( "touch", slideBackground )

	------------------------
	-- Define public methods
	
	--function g:jumpToImage(num)
	--	local i
	--	print("jumpToImage")
	--	print("#items", #items)
	--	for i = 1, #items do
	--		if i < num then items[i].x = -screenW*.5;
	--		elseif i > num then items[i].x = screenW*1.5 + pad
	--		else items[i].x = screenW*.5 - pad
	--		end
	--	end
	--	itemNum = num
	--	initItem(itemNum)
	--end
	function g:cleanUp()
		print("slides cleanUp")
		slideBackground:removeEventListener("touch", touchListener)
	end

	return g	
end

