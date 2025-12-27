-- Existing OnyxMinimap code (preserve this)

-- Added code for heatmap capabilities:
function OnyxMinimap:enableHeatmapVisualization(activityData)
  if not activityData then return end

  -- Clear existing heatmap layer
  self:removeHeatmapLayer()

  -- Create heatmap layer
  local heatmapLayer = {}
  for _, activity in ipairs(activityData) do
    local pos = activity.position
    local intensity = activity.intensity

    -- Draw a heat point based on activity intensity
    if pos and intensity then
      table.insert(heatmapLayer, {
        x = pos.x,
        y = pos.y,
        intensity = intensity,
      })
    end
  end

  -- Render the layer on the minimap
  self:renderHeatmapLayer(heatmapLayer)
end

function OnyxMinimap:removeHeatmapLayer()
  -- Logic to clear current heatmap layer
end

function OnyxMinimap:renderHeatmapLayer(layerData)
  for _, heatPoint in ipairs(layerData) do
    -- Draw heat point visualization on the minimap
    self:drawHeatPoint(heatPoint.x, heatPoint.y, heatPoint.intensity)
  end
end

function OnyxMinimap:drawHeatPoint(x, y, intensity)
  -- Visualization logic for individual heat points
  -- The stronger the intensity, the more prominent the color
end