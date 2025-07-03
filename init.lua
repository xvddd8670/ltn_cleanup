local handler = require("event_handler")

local function on_init_or_configuration_changed()
  local event_id = remote.call("logistic-train-network", "on_requester_remaining_cargo")
  script.on_event(event_id, handler.handle_event)
end

script.on_init(on_init_or_configuration_changed)
script.on_configuration_changed(on_init_or_configuration_changed)
