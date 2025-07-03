local M = {}

function M.remove_duplicates(array)
  local seen, result = {}, {}
  for _, v in ipairs(array) do
    if not seen[v] then
      table.insert(result, v)
      seen[v] = true
    end
  end
  return result
end

return M
