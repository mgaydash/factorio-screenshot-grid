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
  return y_max, y_min, x_max, x_min
end

function is_near_other(entity)
  -- Check if an entity is nearby another entity
  local x = entity.position.x
  local y = entity.position.y
  local nearby = entity.surface.find_entities({{x-2, y-2}, {x+2, y+2}})
  if #nearby > 1 then
    return true
  else
    return false
  end
end

commands.add_command("hello", nil, function(command)
  game.print("Hello, Nauvis!")
end)

commands.add_command("pos", nil, function(command)
  local x = game.player.position.x
  local y = game.player.position.y
  x = math.floor(x)
  y = math.floor(y)
  game.print(x .. ", " .. y)
end)

commands.add_command("detect", nil, function(command)
  game.print("Detecting edges of civilization...")
  local y_max, y_min, x_max, x_min = detect_bounds()
  
  -- draw left edge -- at x min -- start from y min; go to y max
  game.print("[ x_min: " .. x_min .. " | x_max: " .. x_max .. " | y_min: " .. y_min .. " | y_max: " .. y_max .. " ]")
  for i = y_min, y_max, 1 do
    game.player.surface.create_entity{name = "inserter", position = {x=x_min - 10, y=i}, direction = defines.direction.north}
  end

  -- draw right edge -- at x max -- start from y min; go to y max
  for i = y_min, y_max, 1 do
    game.player.surface.create_entity{name = "inserter", position = {x=x_max + 10, y=i}, direction = defines.direction.north}
  end

  -- draw top edge -- at y min -- start from x min; go to x max
  for i = x_min, x_max, 1 do
    game.player.surface.create_entity{name = "inserter", position = {x=i, y=y_min - 10}, direction = defines.direction.north}
  end

  -- draw bottom edge -- at y max -- start from x min; go to x max
  for i = x_min, x_max, 1 do
    game.player.surface.create_entity{name = "inserter", position = {x=i, y=y_max + 10}, direction = defines.direction.north}
  end

  game.print("Done.")
end)

commands.add_command("screenshot_grid", nil, function(command)
  game.print("Taking a grid of screenshots...")
  
  local y_max, y_min, x_max, x_min = detect_bounds()
  local tile_size = 32
  local x_size = 2000
  local y_size = 2000
  local zoom = 0.5
  local x_center = (x_max + x_min) / 2
  local y_center = (y_max + y_min) / 2
  local anti_alias = false
  local ent_info = true
  
  -- Dividing by 2 because we need a radius and have the whole distance between edges
  local x_radius = math.ceil((math.abs(x_min) + math.abs(x_max)) * tile_size / x_size / 2 * zoom)
  local y_radius = math.ceil((math.abs(y_min) + math.abs(y_max)) * tile_size / y_size / 2 * zoom)

  -- Disable extra textures on the surface that will add noise to the map
  game.player.surface.daytime = 0
  game.player.surface.show_clouds = false
  game.player.surface.destroy_decoratives({})

  -- Capture screenshots in a grid pattern
  -- Loop indices range from -radius to +radius to center the grid on the factory
  for row_offset = -y_radius, y_radius do
      for col_offset = -x_radius, x_radius do
          -- Calculate world position for this grid cell
          local screenshot_x = col_offset * x_size / tile_size / zoom + x_center
          local screenshot_y = row_offset * y_size / tile_size / zoom + y_center
          
          -- Convert loop indices to 0-based filename indices for stitching
          local filename_row = row_offset + y_radius
          local filename_col = col_offset + x_radius
          
          game.take_screenshot {
              resolution = {x = x_size, y = y_size},
              zoom = zoom,
              position = {screenshot_x, screenshot_y},
              show_entity_info = ent_info,
              anti_alias = anti_alias,
              path = "image_" .. filename_row .. "_" .. filename_col .. ".png"
          }
      end
  end
  game.print("Done.")
end)