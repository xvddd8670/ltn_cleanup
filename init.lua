local handler = require("event_handler")

local function register_event()
  if storage.ltn_event_id then
    script.on_event(storage.ltn_event_id, handler.handle_event)
  end
end

local function on_init_or_configuration_changed()
  local event_id = remote.call("logistic-train-network", "on_requester_remaining_cargo")
  storage.ltn_event_id = event_id
  register_event()
end

script.on_init(on_init_or_configuration_changed)
script.on_configuration_changed(on_init_or_configuration_changed)
script.on_load(register_event)
