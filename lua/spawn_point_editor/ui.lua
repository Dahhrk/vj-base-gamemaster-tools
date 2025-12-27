-- Minimal UI integration using the Onyx library

local SPAWN_UI = {}

-- UI Initialization code
function SPAWN_UI:Initialize()
    self.minimap = Onyx.Minimap({
        grid = true,
        onClick = function(x, y)
            RunConsoleCommand("add_spawn_point", x, y, 0, 10, "Default")
        end
    })

    self.controls = Onyx.Panel({
        components = {
            Onyx.Button({
                text = "Add Spawn",
                onClick = function()
                    -- Trigger creation process
                end
            }),
            Onyx.Button({
                text = "Remove Spawn",
                onClick = function()
                    -- Trigger removal process
                end
            }),
            Onyx.Dropdown({
                label = "Spawn Group",
                items = { "Default", "Wave_1", "Allies", "Enemies" },
                onChange = function(selectedGroup)
                    -- Change default group for new spawns
                end
            }),
            Onyx.Slider({
                label = "Radius",
                min = 1,
                max = 100,
                step = 1,
                onChange = function(value)
                    -- Adjust radius value
                end
            })
        }
    })
end

function SPAWN_UI:UpdateMinimap(points)
    -- Update minimap visualization
    self.minimap:ClearPoints()
    for _, point in ipairs(points) do
        self.minimap:AddPoint(point.position.x, point.position.y, { radius = point.radius, color = self:GetGroupColor(point.group) })
    end
end

function SPAWN_UI:GetGroupColor(group)
    local colors = {
        Default = Color(255, 255, 255),
        Wave_1 = Color(0, 255, 0),
        Allies = Color(0, 0, 255),
        Enemies = Color(255, 0, 0)
    }
    return colors[group] or Color(255, 255, 255)
end

return SPAWN_UI