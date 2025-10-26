-- Configuration constants
local TILE_SIZE = 32
local SCREENSHOT_RESOLUTION = 2000
local SCREENSHOT_ZOOM = 0.5
local NEIGHBOR_CHECK_RADIUS = 2

function detect_bounds()
  -- Find the things that define the bounds of a base
  local entities = game.player.surface.find_entities_filtered{name = {
    "assembling-machine-1",
    "assembling-machine-2",
    "assembling-machine-3",
    "big-electric-pole",
    "big-mining-drill",
    "biochamber",
    "burner-mining-drill",
    "captive-biter-spawner",
    "centrifuge",
    "chemical-plant",
    "crusher",
    "cryogenic-plant",
    "electric-mining-drill",
    "electromagnetic-plant",
    "express-transport-belt",
    "express-underground-belt",
    "fast-transport-belt",
    "fast-underground-belt",
    "foundry",
    "gun-turret",
    "medium-electric-pole",
    "oil-refinery",
    "pipe-to-ground",
    "pipe",
    "pumpjack",
    "railgun-turret",
    "roboport",
    "rocket-silo",
    "rocket-turret",
    "small-electric-pole",
    "solar-panel",
    "stone-wall",
    "substation",
    "train-stop",
    "transport-belt",
    "turbo-transport-belt",
    "turbo-underground-belt",
    "underground-belt"
  }} 
  local y_max = 0
  local y_min = 0
  local x_max = 0
  local x_min = 0
  for key, value in pairs(entities) do
    local x = value.position.x
    local y = value.position.y
    if x < x_min and is_near_other(value) then
      x_min = math.floor(x)
    elseif x > x_max and is_near_other(value) then
      x_max = math.floor(x)
    end
    if y < y_min and is_near_other(value) then
      y_min = math.floor(y)
    elseif y > y_max and is_near_other(value) then
      y_max = math.floor(y)
    end
  end
  return x_min, x_max, y_min, y_max
end

function is_near_other(entity)
  -- Check if an entity is nearby another entity
  -- Note: find_entities includes the entity itself, so we check for > 1
  local x = entity.position.x
  local y = entity.position.y
  local nearby = entity.surface.find_entities({
    {x - NEIGHBOR_CHECK_RADIUS, y - NEIGHBOR_CHECK_RADIUS},
    {x + NEIGHBOR_CHECK_RADIUS, y + NEIGHBOR_CHECK_RADIUS}
  })
  -- More than 1 means the entity itself plus at least one neighbor
  return #nearby > 1
end

commands.add_command("screenshot_grid", nil, function(command)
  game.print("Taking a grid of screenshots...")
  
  local x_min, x_max, y_min, y_max = detect_bounds()
  
  -- Calculate factory dimensions and center point
  local factory_width = x_max - x_min
  local factory_height = y_max - y_min
  local x_center = (x_max + x_min) / 2
  local y_center = (y_max + y_min) / 2
  
  -- Calculate how many tiles wide/tall each screenshot covers in world coordinates
  local tiles_per_screenshot_x = SCREENSHOT_RESOLUTION / TILE_SIZE / SCREENSHOT_ZOOM
  local tiles_per_screenshot_y = SCREENSHOT_RESOLUTION / TILE_SIZE / SCREENSHOT_ZOOM
  
  -- Calculate grid radius (number of screenshots needed in each direction from center)
  local x_radius = math.ceil(factory_width / tiles_per_screenshot_x / 2)
  local y_radius = math.ceil(factory_height / tiles_per_screenshot_y / 2)
  
  -- Disable extra textures on the surface that will add noise to the map
  game.player.surface.daytime = 0
  game.player.surface.show_clouds = false
  game.player.surface.destroy_decoratives({})

  -- Capture screenshots in a grid pattern
  -- Loop indices range from -radius to +radius to center the grid on the factory
  for row_offset = -y_radius, y_radius do
      for col_offset = -x_radius, x_radius do
          -- Calculate world position for this grid cell
          local screenshot_x = col_offset * tiles_per_screenshot_x + x_center
          local screenshot_y = row_offset * tiles_per_screenshot_y + y_center
          
          -- Convert loop indices to 0-based filename indices for stitching
          local filename_row = row_offset + y_radius
          local filename_col = col_offset + x_radius
          
          game.take_screenshot {
              resolution = {x = SCREENSHOT_RESOLUTION, y = SCREENSHOT_RESOLUTION},
              zoom = SCREENSHOT_ZOOM,
              position = {screenshot_x, screenshot_y},
              show_entity_info = true,
              anti_alias = false,
              path = "image_" .. filename_row .. "_" .. filename_col .. ".png"
          }
      end
  end
  
  game.print("Done.")
end)
