-- Test plugin to add a red dot before file icons

local function setup(state)
	-- Save the original icon function
	state.original_icon = Entity.icon
	
	-- Override the icon function
	Entity.icon = function(self)
		-- Get the original icon
		local original = state.original_icon(self)
		
		-- Add a red dot before the icon
		local red_dot = ui.Span("● "):fg("#ee7b70")
		
		-- Combine them
		return ui.Line { red_dot, original }
	end
end

return { setup = setup }