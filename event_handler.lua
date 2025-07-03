local utils = require("utils")

local function station_exists(surface, station_name)
  for _, stop in ipairs(surface.find_entities_filtered{type="train-stop"}) do
    if stop.backer_name == station_name then return true end
  end
  return false
end

local function handle_event(event)
  local train = event.train
  local train_id = train and train.id or "неизвестно"
  local content_arr = {}

  for _, cw in ipairs(train.cargo_wagons) do
    local inv = cw.get_inventory(defines.inventory.cargo_wagon)
    if inv and inv.valid then
      for i = 1, #inv do
        local st = inv[i]
        if st.valid_for_read then table.insert(content_arr, st.name) end
      end
    end
  end

  for _, fw in ipairs(train.fluid_wagons) do
    for fname, amt in pairs(fw.get_fluid_contents()) do
      if amt > 0 then table.insert(content_arr, fname) end
    end
  end

  content_arr = utils.remove_duplicates(content_arr)

	local liquids_there = false
	local fluid_count = 0
	local items_there = false
	local items_count = 0
	

	for i = 1, #content_arr do
	  local v = content_arr[i]
	  local icon
	  if prototypes.item[v] then
		icon = "item"
		items_there = true
		items_count = items_count + 1
	  elseif prototypes.fluid[v] then
		icon = "fluid"
		liquids_there = true
		fluid_count = fluid_count + 1
	  else
		icon = "unknown"
	  end
	  content_arr[i] = "[" .. icon .. "=" .. v .. "]"
	end

	if not (train and train.valid and train.schedule and #train.schedule.records>0) then
		game.print({"", "[color=red]", "[LTN Cleanup] ", {"text-to-chat.error-shedule-epmty"}, "[/color]"})
		return
	end
	
	if liquids_there 
	and items_there
	then
		game.print({"", "[color=red]", "[LTN Cleanup] ", {"text-to-chat.error-mixed-cargo"}, "[/color]"})
		game.print({"", "[color=red]", "[LTN Cleanup] ", {"text-to-chat.train-stopped"}, "[/color]"})
		game.print({"", "[color=red]", "[LTN Cleanup] ", {"text-to-chat.player-intervention"}, "[/color]"})
		game.print({"", "[color=red]", "[LTN Cleanup] ", {"text-to-chat.player-recommended"}, "[/color]"})
		train.manual_mode = true
		return
	end
	
	if fluid_count > 1 then
		game.print({"", "[color=red]", "[LTN Cleanup] ", {"text-to-chat.error-fluid-count"}, "[/color]"})
		game.print({"", "[color=red]", "[LTN Cleanup] ", {"text-to-chat.train-stopped"}, "[/color]"})
		game.print({"", "[color=red]", "[LTN Cleanup] ", {"text-to-chat.player-intervention"}, "[/color]"})
		game.print({"", "[color=red]", "[LTN Cleanup] ", {"text-to-chat.player-recommended"}, "[/color]"})
		train.manual_mode = true
		return
	end
	
	game.print({"", "[color=yellow]", "[LTN Cleanup]", {"text-to-chat.train-id"}, train_id, " ", {"text-to-chat.remaining-cargo"}, table.concat(content_arr,", "), "[/color]"})

  -- ищем cleanup-станцию
  local cleanup_station
    if #content_arr == 1 then
	  for _, name in ipairs(content_arr) do
		local cand = "[virtual-signal=ltn-cleanup-station]" .. name
		if station_exists(train.front_stock.surface, cand) then 
			cleanup_station = cand 
			break 
		end
	  end
	end
	


  if not cleanup_station
     and station_exists(train.front_stock.surface, "[virtual-signal=ltn-cleanup-station][virtual-signal=ltn-item-cleanup-station]")
     and not liquids_there
  then
	cleanup_station = "[virtual-signal=ltn-cleanup-station][virtual-signal=ltn-item-cleanup-station]" 
  end

  if cleanup_station then
    local old = train.schedule.records
    local first = old[1]
    train.schedule = {
      current = 1,
      records = {
        {station=cleanup_station, wait_conditions={{type="empty",ticks=300}}},
        first
      }
    }
    train.manual_mode = false
    game.print({"", "[color=yellow]", "[LTN Cleanup] ", {"text-to-chat.train-id"}, train.id, " ", {"text-to-chat.going-to"}, cleanup_station, "[/color]"})
  else
    game.print({"","[color=red]", "[LTN Cleanup] ", {"text-to-chat.cleanup-station-no-found"}, "[/color]"})
	if #content_arr > 1 then
	    game.print({"","[color=red]", "[LTN Cleanup] ", {"text-to-chat.error-item-count"}, "[/color]"})
	end
    game.print({"","[color=red]", "[LTN Cleanup] ", {"text-to-chat.train-stopped"}, "[/color]"})
	game.print({"", "[color=red]", "[LTN Cleanup] ", {"text-to-chat.player-intervention"}, "[/color]"})
	game.print({"", "[color=red]", "[LTN Cleanup] ", {"text-to-chat.player-recommended"}, "[/color]"})
    train.manual_mode = true
  end
end

return {handle_event = handle_event}
