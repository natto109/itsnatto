--
-- Copyright (c) 2017, Jesse Freeman. All rights reserved.
--
-- Licensed under the Microsoft Public License (MS-PL) License.
-- See LICENSE file in the project root for full license information.
--
-- Contributors
-- --------------------------------------------------------
-- This is the official list of Pixel Vision 8 contributors:
--
-- Jesse Freeman - @JesseFreeman
-- Christina-Antoinette Neofotistou - @CastPixel
-- Christer Kaitila - @McFunkypants
-- Pedro Medeiros - @saint11
-- Shawn Rakowski - @shwany
--

function PixelVisionOS:CreateCanvas(rect, size, scale, colorOffset, toolTip, emptyColorID, forceDraw)

  -- Create the button's default data
  local data = editorUI:CreateData(rect, nil, toolTip, forceDraw)

  -- Customize the default name by adding Button to it
  data.name = "Canvas" .. data.name

  -- data.showPixelSelection = true
  data.pixelSelectionSize = 1
  data.borderOffset = 0
  data.gridSize = 8
  data.showBGColor = false
  data.selectionCounter = 0
  data.selectionDelay = .2
  data.selectionTime = 0
  data.selectRect = nil
  data.selectedPixelData = nil
  data.brushColorID = 253 -- Second to last color in the tool
  data.showGrid = false

  -- Create a selection canvas
  data.selectionCanvas = NewCanvas(data.rect.w, data.rect.h)
  data.selectionCanvas.wrap = false
  data.selectionCanvas:SetStroke({0}, 1, 1)

  data.gridCanvas = NewCanvas(data.rect.w, data.rect.h)
  data.gridCanvas.wrap = false
  -- TODO find a real empty color


  -- local spriteData = _G["pixelselection1x"]

  -- data.overDrawArgs = {spriteData.spriteIDs, 0, 0, spriteData.width, false, false, DrawMode.Sprite, 36, true, false}

  data.brushDrawArgs = {0, 0, 8, 8, data.brushColorID, DrawMode.Sprite}
  -- DrawRect( 0, 0, 8, 8, 54, DrawMode.Sprite )

  data.onClick = function(tmpData)

    self:CanvasRelease(tmpData, true)

  end

  data.triggerOnFirstPress = function(tmpData)

    self:CanvasPress(tmpData, true)

    -- Trigger fill here since it only happens on the fist press
    if(data.tool == "fill") then

      -- TODO need to set this one on a timer

      -- Update the fill color
      data.paintCanvas:SetPattern({data.brushColor + data.colorOffset}, 1, 1)

      data.paintCanvas:FloodFill(data.startPos.x, data.startPos.y)

      editorUI:Invalidate(data)
    end

    if(data.onFirstPress ~= nil) then
      data.onFirstPress()
    end

  end

  data.penCanErase = false
  data.colorOffset = colorOffset
  data.emptyColorID = emptyColorID or - 1
  data.fill = false
  data.currentCursorID = 1
  -- Default color is 0
  data.brushColor = 0
  data.overColor = -1

  self:ResizeCanvas(data, size, scale)


  -- Clear the background so the mask color shows through
  -- DrawRect(rect.x, rect.y, rect.w, rect.h, emptyColorID, DrawMode.TilemapCache)

  -- data.currentTool = 1 -- default tool

  editorUI:ResetValidation(data)

  return data

end

function PixelVisionOS:ChangeCanvasTool(data, toolName, cursorID)

  -- print("Change canvas tool", toolName)

  data.tool = toolName

  -- Clear the selection when changing tools/
  if(data.tool ~= "selection" and data.selectRect ~= nil) then
    self:CancelCanvasSelection(data)
  end

  -- TODO change the cursor
  if(data.tool == "pen") then

    data.currentCursorID = cursorID or 6
    self:ResetCanvasStroke(data)

  elseif(data.tool == "eraser") then

    data.currentCursorID = cursorID or 7

    ReplaceColor(data.brushColorID, data.emptyColorID)

  else
    data.currentCursorID = 8
    self:ResetCanvasStroke(data)

  end

  -- Save the new cursor for tools that need to restore
  data.defaultCursorID = data.currentCursorID

  -- data.showPixelSelection = data.tool ~= "eyedropper" and data.tool ~= "fill"


  -- TODO change the drawing tool

end

function PixelVisionOS:SetCanvasPixels(data, pixelData)
  data.paintCanvas:SetPixels(pixelData)
end

function PixelVisionOS:UpdateCanvas(data, hitRect)

  -- Make sure we have data to work with and the component isn't disabled, if not return out of the update method
  if(data == nil) then
    return
  end

  

  -- If the button has data but it's not enabled exit out of the update
  if(data.enabled == false) then

    -- If the button is disabled but still in focus we need to remove focus
    if(data.inFocus == true) then
      editorUI:ClearFocus(data)
    end

    -- See if the button needs to be redrawn.
    self:RedrawCanvas(data)

    -- Shouldn't update the button if its disabled
    return

  end

  -- Make sure we don't detect a collision if the mouse is down but not over this button
  if(editorUI.collisionManager.mouseDown and data.inFocus == false) then
    -- See if the button needs to be redrawn.
    self:RedrawCanvas(data)
    return
  end

  -- If the hit rect hasn't been overridden, then use the buttons own hit rect
  if(hitRect == nil) then
    hitRect = data.hitRect or data.rect
  end

  local overrideFocus = (data.inFocus == true and editorUI.collisionManager.mouseDown)

  local inRect = editorUI.collisionManager:MouseInRect(hitRect)

  -- Ready to test finer collision if needed
  if(inRect == true or overrideFocus) then

    -- Draw a selection rect on top of everything
    if(data.selectRect ~= nil) then

      data.selectionTime = data.selectionTime + editorUI.timeDelta

      if(data.selectionTime > data.selectionDelay) then
        data.selectionCounter = data.selectionCounter + 1
        if(data.selectionCounter > 1) then
          data.selectionCounter = 0
        end

        data.selectionTime = 0
          
        data.selectionCanvas:LinePattern(2, data.selectionCounter)

        end
      
      
      end

      local tmpPos = NewPoint(
        editorUI.collisionManager.mousePos.x - data.rect.x,
        editorUI.collisionManager.mousePos.y - data.rect.y
      )

      -- Modify scale
      tmpPos.x = tmpPos.x / data.scale
      tmpPos.y = tmpPos.y / data.scale

    

      if(data.selectRect ~= nil) then
        
        if(data.selectRect:Contains(tmpPos) == true) then

          data.currentCursorID = 9

        else

          data.currentCursorID = data.defaultCursorID
         
        end

      else

        data.currentCursorID = data.defaultCursorID

      end

    -- If we are in the collision area, set the focus
    editorUI:SetFocus(data, data.currentCursorID)

    -- if(data.showPixelSelection) then

    local position = 
    {
      x = Clamp(math.floor((editorUI.collisionManager.mousePos.x - data.rect.x) / data.gridSize), 0, editorUI.spriteSize.X * data.scale - 1),
      y = Clamp(math.floor((editorUI.collisionManager.mousePos.y - data.rect.y) / data.gridSize), 0, editorUI.spriteSize.y * data.scale -1 ),
    }

    data.toolTip = string.format("Over pixel (%02d,%02d)", position.x, position.y)

    if(data.tool == "eyedropper") then

      local tmpColor = data.paintCanvas:ReadPixelAt(tmpPos.x, tmpPos.y) - data.colorOffset

      -- TODO this is duplicated below

      -- Update over color if using eye picker
      -- if(pixelVisionOS.paletteMode == true) then

        -- TODO this is hard coded to look for a palette color picker

        -- Shift the value to offset for the palette
        -- tmpColor = tmpColor + PaletteOffset(paletteColorPickerData.pages.currentSelection - 1)

      -- end

      ReplaceColor(data.brushColorID, tmpColor + data.colorOffset)

    end


    -- Only update the over rect if the mouse is over the canvas
    if(inRect == true and data.tool ~= "select") then

      -- Update over rect position
      -- data.overDrawArgs[2] = (position.x * data.gridSize) + data.rect.x - data.borderOffset
      -- data.overDrawArgs[3] = (position.y * data.gridSize) + data.rect.y - data.borderOffset
      data.brushDrawArgs[1] = (position.x * data.gridSize) + data.rect.x - data.borderOffset
      data.brushDrawArgs[2] = (position.y * data.gridSize) + data.rect.y - data.borderOffset
      -- Draw over rect
      -- editorUI:NewDraw("DrawSprites", data.overDrawArgs)
      
      if(data.tool ~= "eyedropper") then
        editorUI:NewDraw("DrawRect", data.brushDrawArgs)
      end

    end

    -- end

    -- Check to see if the button is pressed and has an onAction callback
    if(editorUI.collisionManager.mouseReleased == true) then

      -- Click the button
      data.onClick(data)
      data.firstPress = true

    elseif(editorUI.collisionManager.mouseDown) then

      data.mouseState = "dragging"


      if(data.firstPress ~= false) then

        -- Save start position
        data.startPos = NewPoint(tmpPos.x, tmpPos.y)

        -- if(data.triggerOnFirstPress ~= nil) then
        -- Call the onPress method for the button
        data.triggerOnFirstPress(data)
        -- end

        data.mouseState = "pressed"

        -- Change the flag so we don't trigger first press again
        data.firstPress = false

        

      end

      self:DrawOnCanvas(data, tmpPos)

    end

  else

    if(data.inFocus == true) then
      self:CanvasPress(data, true)
      data.firstPress = true
      -- If we are not in the button's rect, clear the focus
      editorUI:ClearFocus(data)

    end

  end

  if(data.inFocus == false and data.selectRect ~= nil) then

    -- print("Clear", MouseButton(0) == true)

    if(MouseButton(0) == true) then
      self:CancelCanvasSelection(data)
    end

  end

  -- TODO need to make sure we have focus

  if(data.selectRect ~= nil) then

    -- Capture keys to switch between different tools and options
    if( Key(Keys.Back, InputState.Released)) then
      
        -- print("Selection - Delete", self.selectRect)

        self:CutPixels(data)

        -- Clear the selection
        self:CancelCanvasSelection(data, false)        
    
    elseif(Key(Keys.Escape, InputState.Released)) then

      self:CancelCanvasSelection(data)

    end

  end

  -- Trigger click if released out of bounds to save drawing
  if(editorUI.collisionManager.mouseReleased == true and data.mouseState == "dragging") then
    -- Click the button
    data.onClick(data)
    data.firstPress = true
    
  end

  -- Make sure we don't need to redraw the button.
  self:RedrawCanvas(data)

end

function PixelVisionOS:DrawOnCanvas(data, mousePos, toolID)

  -- Get the start position for a new drawing
  if(data.startPos ~= nil) then

    -- Test for the data.tool and perform a draw action
    if(data.tool == "pen") then

      if(data.penCanErase == true) then

        local overColorID = data.paintCanvas:ReadPixelAt(mousePos.x, mousePos.y) - data.colorOffset

        if(overColorID > 0) then
          data.tmpPaintCanvas:SetStroke({data.emptyColorID}, 1, 1)
        else
          self:ResetCanvasStroke(data)
        end

        data.tmpPaintCanvas:SetStrokePixel(mousePos.x, mousePos.y)

      else

        self:ResetCanvasStroke(data)

        data.tmpPaintCanvas:DrawLine(data.startPos.x, data.startPos.y, mousePos.x, mousePos.y)

      end


      data.startPos = NewPoint(mousePos.x, mousePos.y)

      editorUI:Invalidate(data)

    elseif(data.tool == "eraser") then

      -- Change the stroke the empty color
      data.tmpPaintCanvas:SetStroke({data.emptyColorID}, 1, 1)

      data.tmpPaintCanvas:DrawLine(data.startPos.x, data.startPos.y, mousePos.x, mousePos.y)
      data.startPos = NewPoint(mousePos.x, mousePos.y)

      editorUI:Invalidate(data)

    elseif(data.tool == "line") then

      data.tmpPaintCanvas:Clear()

      self:ResetCanvasStroke(data)

      data.tmpPaintCanvas:DrawLine(data.startPos.x, data.startPos.y, mousePos.x, mousePos.y, data.fill)

      -- force the paint canvas to redraw
      data.paintCanvas:Invalidate()

      editorUI:Invalidate(data)

    elseif(data.tool == "box") then


      data.tmpPaintCanvas:Clear()

      self:ResetCanvasStroke(data)

      data.tmpPaintCanvas:DrawSquare(data.startPos.x, data.startPos.y, mousePos.x, mousePos.y, data.fill)

      -- force the paint canvas to redraw
      data.paintCanvas:Invalidate()

      editorUI:Invalidate(data)

    elseif(data.tool == "select") then

      if(data.mouseState == "pressed") then

        if(data.selectRect == nil) then

            data.selectionState = "new"
  
            data.selectRect = NewRect(data.startPos.x, data.startPos.y, 0, 0)
  
        else
          
          if(data.selectRect:Contains(mousePos) == true) then

            data.selectionState = "newmove"

            data.moveOffset = NewPoint(data.selectRect.X - mousePos.X, data.selectRect.Y - mousePos.Y)

            if(data.selectedPixelData == nil) then
            
              data.selectedPixelData = self:CutPixels(data)--data.paintCanvas:GetPixels(data.selectRect.Left, data.selectRect.Top, data.selectRect.Right, data.selectRect.Bottom)
              -- print("selectedPixelData",  #data.selectedPixelData.pixelData, dump(data.selectedPixelData))
            
            end
            -- print("data.moveOffset", data.moveOffset)

            -- TODO copy pixel data from selection into memory
            -- TODO delete pixel data from selection

          else

            self:CancelCanvasSelection(data)
            -- data.selectionState = "none"

            -- data.selectRect = nil
            -- data.selectionSize = nil

          end

        end

      elseif(data.mouseState == "dragging")  then

        if(data.selectRect ~= nil) then
          if(data.selectionState == "new" or data.selectionState == "resize") then

            data.selectionState = "resize"

            -- print("resize", data.selectRect, mousePos, , )

            data.selectRect.X = math.min(data.startPos.X, mousePos.X)
            data.selectRect.Y = math.min(data.startPos.Y, mousePos.Y)
            data.selectRect.Width = Clamp(math.abs(mousePos.X - data.startPos.X), 0, data.paintCanvas.width)
            data.selectRect.Height = Clamp(math.abs(mousePos.Y - data.startPos.Y), 0, data.paintCanvas.height)

          else

            -- print("data.selectionState", data.selectionState)

            

            editorUI.cursorID = 2

            data.selectRect.X = mousePos.X + data.moveOffset.X --  data.selectionSize.X
            data.selectRect.Y = mousePos.Y + data.moveOffset.Y --  data.selectionSize.Y
            
            -- if(data.selectionState == "move" and data.selectedPixelData == nil) then
              
            --   data.selectedPixelData = self:CutPixels(data)--data.paintCanvas:GetPixels(data.selectRect.Left, data.selectRect.Top, data.selectRect.Right, data.selectRect.Bottom)

            --   print("Selected pixels", #data.selectedPixelData.pixelData, dump(data.selectedPixelData))




            -- end

            data.selectionState = "move"

          end
        end

      end

      -- print("Selection", data.selectionState)

    elseif(data.tool == "circle") then

      data.tmpPaintCanvas:Clear()

      self:ResetCanvasStroke(data)

      data.tmpPaintCanvas:DrawEllipse(data.startPos.x, data.startPos.y, mousePos.x, mousePos.y, data.fill)

      -- force the paint canvas to redraw
      data.paintCanvas:Invalidate()

      editorUI:Invalidate(data)

    elseif(data.tool == "eyedropper") then

      -- TODO this doesn't appear to do anything
      data.overColor = data.paintCanvas:ReadPixelAt(mousePos.x, mousePos.y) - data.colorOffset

      if(data.overColor > pixelVisionOS.colorsPerSprite) then
        data.overColor = -1
      end

      -- TODO should we display this value or that it is out of bounds?

    end


  end

  -- end

end

function PixelVisionOS:CutPixels(data)

  if(data.selectRect == nil) then
    return
  end

  local selection =
  {
    size = NewRect(data.selectRect.X, data.selectRect.Y, data.selectRect.Width, data.selectRect.Height)
  }

  selection.pixelData = data.paintCanvas:GetPixels(selection.size.X, selection.size.Y, selection.size.Width, selection.size.Height)

  -- Convert the mask colors to the tool's mask color
  for i = 1, #selection.pixelData do
      if(selection.pixelData[i] == 255) then
        selection.pixelData[i] = -1
      end
  end

  selection.pixelData[i] = 5

  local bgColor = data.showBGColor and gameEditor:BackgroundColor() + 256 or data.emptyColorID


  -- Change the stroke to a single pixel of white
  data.tmpPaintCanvas:SetStroke({bgColor}, 1, 1)

  -- Change the stroke to a single pixel of white
  data.tmpPaintCanvas:SetPattern({bgColor}, 1, 1)

  -- Adjust right and bottom to account for 1 px border
  data.tmpPaintCanvas:DrawSquare(selection.size.Left, selection.size.Top, selection.size.Right - 1, selection.size.Bottom -1, true)

  return selection
    
end

function PixelVisionOS:FillCanvasSelection(data, colorID)

  if(data.selectRect == nil) then
    return
  end
  
  if(data.selectedPixelData == nil) then
    data.selectedPixelData = self:CutPixels(data)

  end

  for i = 1, #data.selectedPixelData.pixelData do
    data.selectedPixelData.pixelData[i] = colorID or (data.brushColor + data.colorOffset)
  end

  --Fire a release event
  self:CanvasRelease(data, true)

end

function PixelVisionOS:CancelCanvasSelection(data, mergeSelection, action)

  if(mergeSelection ~= false and data.selectedPixelData ~= nil) then
    data.paintCanvas:SetPixels(data.selectRect.Left, data.selectRect.Top, data.selectedPixelData.size.Width, data.selectedPixelData.size.Height, data.selectedPixelData.pixelData)
    data.paintCanvas:Invalidate()
  end
 
  data.selectedPixelData = nil
  data.selectionState = "none"
  data.selectRect = nil
  -- data.defaultCursorID = 7
  -- self.cursorID = 7
  -- self.mouseCursor:SetCursor(data.defaultCursorID)


  -- print("Cursor", data.defaultCursorID)

  if(action ~= false) then
    --Fire a release event
    self:CanvasRelease(data, true)
  end

end

function PixelVisionOS:ResetCanvasStroke(data)

  -- print("ResetCanvasStroke")
  local tmpColor = data.brushColor

  local realBrushColor = tmpColor + data.colorOffset

  -- Change the stroke to a single pixel
  data.tmpPaintCanvas:SetStroke({realBrushColor}, 1, 1)
  data.tmpPaintCanvas:SetPattern({realBrushColor}, 1, 1)

  -- Check to see if we are in palete mode
  -- if(se/lf.paletteColorPickerData ~= nil) then

  --   -- TODO this is hard coded to look for a palette color picker

  --   -- TODO this is not finding the palette picker?
    -- print("Test", self.paletteColorPickerData)
  --   -- Shift the value to offset for the palette
    -- tmpColor = tmpColor + PaletteOffset(self.paletteColorPickerData.pages.currentSelection - 1)

  -- end

  ReplaceColor(data.brushColorID, tmpColor + data.colorOffset)

end

function PixelVisionOS:InvalidateCanvas(data)

  data.paintCanvas:Invalidate()

end

function PixelVisionOS:RedrawCanvas(data)


  if(data == nil) then
    return
  end

  local bgColor = data.showBGColor and gameEditor:BackgroundColor() + 256 or data.emptyColorID

  if(data.paintCanvas.invalid == true) then

    -- Draw the final canvas to the display on each frame
    data.paintCanvas:DrawPixels(data.rect.x, data.rect.y, DrawMode.TilemapCache, data.scale, data.emptyColorID, bgColor)

    data.paintCanvas:ResetValidation()

  end

  if(data.tmpPaintCanvas.invalid == true) then

    -- Draw the tmp layer on top of everything since it has the active drawing's pixel data
    data.tmpPaintCanvas:DrawPixels(data.rect.x, data.rect.y, DrawMode.TilemapCache, data.scale, bgColor, data.emptyColorID)

    -- data.tmpPaintCanvas:ResetValidation()

  end

  if(data.selectedPixelData ~= nil) then
    data.tmpLayerCanvas:Clear()
    data.tmpLayerCanvas:SetPixels(data.selectRect.Left, data.selectRect.Top, data.selectedPixelData.size.Width, data.selectedPixelData.size.Height, data.selectedPixelData.pixelData)
    data.tmpLayerCanvas:DrawPixels(data.rect.x, data.rect.y, DrawMode.TilemapCache, data.scale, bgColor, data.emptyColorID)
    data.paintCanvas.Invalidate()
    -- data.tmpLayerCanvas.ResetValidation()
  end

  -- TODO need to find a way to only draw this when the canvas has been invalidated
  if(data.showGrid == true) then
    data.gridCanvas:DrawPixels(data.rect.x, data.rect.y, DrawMode.Sprite, 1, -1, -1)
  end

  -- if(data.selectionCanvas.invalid == true) then
    
  if(data.selectRect  ~= nil) then

    data.selectionCanvas:Clear()

  -- Loop through pixels and invert if needed

  -- Draw the canvas to the display
  if(math.abs(data.selectRect.Width) > 0 and math.abs(data.selectRect.Height) > 0) then

    -- Adjust right and bottom by 1 so selection is inside of selected pixels
    data.selectionCanvas:DrawSquare(data.selectRect.Left * data.scale, data.selectRect.Top * data.scale, data.selectRect.Right * data.scale - 1, data.selectRect.Bottom * data.scale -1, false)

    bgColor = data.showBGColor and gameEditor:BackgroundColor() + 256 or -1

    data.selectionCanvas:DrawPixels(data.rect.x, data.rect.y, DrawMode.Sprite, 1, -1, -1)
  end

  end

  -- end

end

-- Use this to perform a click action on a button. It's used internally when a mouse click is detected.
function PixelVisionOS:CanvasRelease(data, callAction)

  -- print("Canvas Release")


  -- Clear the start position
  data.startPos = nil

  data.mouseState = data.mouseState == "released" and "up" or "released"


  -- print("Released")
  -- Return if the selection rect is nil
  -- if(data.selectRect ~= nil) then
  --   return
  -- end

  if(data.tmpPaintCanvas.invalid == true) then

    -- Merge the pixel data from the tmp canvas into the main canvas before it renders
    data.paintCanvas:MergeCanvas(data.tmpPaintCanvas, 0, true)

    -- Clear the canvas
    data.tmpPaintCanvas:Clear()

    -- Normally clearing the canvas invalidates it but se want to reset it until its drawn in again
    data.tmpPaintCanvas:ResetValidation()

    -- print("Merged tmp canvas")

  end

  if(data.selectRect ~= nil and (data.selectRect.Width == 0 or data.selectRect.Height == 0)) then
    data.selectRect = nil
  end

  -- if(data.selectedPixelData ~= nil) then
  --   data.tmpLayerCanvas:Clear()
  --   print("Draw" , data.selectRect)
  --   -- data.tmpLayerCanvas:SetPixels(data.selectRect.Left, data.selectRect.Top, 1, 1, data.selectedPixelData)
  --   data.tmpLayerCanvas.Invalidate()
  -- end

  -- if(data.tmpLayerCanvas.invalid == true) then

  --   print("Copy layer to paint canvas")

  --   data.paintCanvas:MergeCanvas(data.tmpLayerCanvas, 0, true)

  --   data.tmpLayerCanvas.Clear()

  --   data.tmpLayerCanvas:ResetValidation()

  -- end

  if(data.selectionCanvas.invalid == true) then

    data.selectionCanvas:ResetValidation()

  end

  local oldPixelData = nil

  if(data.selectedPixelData ~= nil) then

    oldPixelData = data.paintCanvas:GetPixels()

    -- data.paintCanvas:MergeCanvas(data.selectionCanvas, 0, true)

  --  prin/t("Pixels", dump(data.selectedPixelData.pixelData))

   --TODO need to test for a special key down and toggle ignoring transparency
   data.ignoreMaskColor = true
    
    data.paintCanvas:SetPixels(data.selectRect.Left, data.selectRect.Top, data.selectedPixelData.size.Width, data.selectedPixelData.size.Height, data.selectedPixelData.pixelData)
    

  end

  -- trigger the canvas action callback
  if(data.onAction ~= nil and callAction ~= false) then

    -- Trigger the onAction call back and pass in the double click value if the button is set up to use it
    data.onAction()

  end

  if(oldPixelData ~= nil) then
    data.paintCanvas:SetPixels(oldPixelData)
    data.paintCanvas:Invalidate()
  end

end

function PixelVisionOS:CanvasPress(data, callAction)

  -- print("onPress", "Update canvas")

  data.tmpPaintCanvas:Invalidate()

  if(data.onPress ~= nil and callAction ~= false) then

    -- Trigger the onPress
    data.onPress()

  end

end

function PixelVisionOS:ResizeCanvas(data, size, scale, pixelData)

  if(data.selectRect ~= nil) then
    self:CancelCanvasSelection(data, true, false)
  end

  data.rect.w = size.x * scale
  data.rect.h = size.y * scale
  
  -- Create a new canvas for drawing into
  data.paintCanvas = NewCanvas(size.x, size.y)

  -- Create a temporary canvas
  data.tmpPaintCanvas = NewCanvas(size.x, size.y)

  -- Create a layer canvas
  data.tmpLayerCanvas = NewCanvas(size.x, size.y)

  -- Set scale for calculation
  data.scale = scale or 1

  -- TODO need to copy pixel data over to the canvas
  if(pixelData ~= nil) then

    local total = #pixelData

    -- print("Total Pixels", total)
    for i = 1, total do

      local color = pixelData[i]

      pixelData[i] = color == -1 and data.emptyColorID or (color + data.colorOffset)

    end

    data.paintCanvas:SetPixels(0, 0, size.x, size.y, pixelData);

  end
 
  -- Redraw the grid
  data.gridCanvas:Clear()
  
  local columns = data.rect.w / scale
  local rows = data.rect.h / scale

  data.gridCanvas:SetStroke({0}, 1, 1)

  for i = 0, rows do
      data.gridCanvas:DrawLine(0, i * scale - 1, data.rect.w, i * scale - 1)
      for j = 0, columns do
        data.gridCanvas:DrawLine(j*scale -1 , 0, j*scale -1 , data.rect.h)
      end
  end

end

function PixelVisionOS:GetCanvasSize(data)

  return NewRect(data.rect.x, data.rect.y, data.paintCanvas.width, data.paintCanvas.height)
end

function PixelVisionOS:ToggleCanvasFill(data, value)

  data.fill = value

  return data.fill

end

function PixelVisionOS:ToggleCanvasCentered(data, value)

  value = value or not data.tmpPaintCanvas:DrawCentered()

  data.tmpPaintCanvas:DrawCentered(value)

  return value

end

function PixelVisionOS:CanvasBrushColor(data, value)

  -- print("Value", value)

  data.brushColor = value
  self:ResetCanvasStroke(data)

end

function PixelVisionOS:CanvasColorOffset(data, value)

  data.colorOffset = value

  -- TODO need to change brush color

end

function PixelVisionOS:GetCanvasPixelData(data)

  -- TODO should this subtract the color offset?

  return data.paintCanvas:GetPixels()

end

function PixelVisionOS:ClearCanvas(data)

  data.paintCanvas:Clear()

end


-- local brushSizes = {16, 8, 8, 8, 4}

function PixelVisionOS:ChangeCanvasPixelSize(data, size)

  -- data.pixelSelectionSize = size

  data.brushDrawArgs[3] = size-- brushSizes[size]
  data.brushDrawArgs[4] = size --brushSizes[size]

  -- Calculate the gridSize TODO this is off because we don't support scale 3 so clamping
  data.gridSize = size--Clamp((3 - data.pixelSelectionSize) * 8, 4, 16)

end
