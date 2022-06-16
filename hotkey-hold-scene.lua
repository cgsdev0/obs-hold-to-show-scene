obs             = obslua
source_name     = ""
prev_scene_name = ""

hotkey_id       = obs.OBS_INVALID_HOTKEY_ID

function hotkey_handler(pressed)
	if not pressed then
		local source = obs.obs_get_source_by_name(prev_scene_name)
		if source ~= nil then
			obs.obs_frontend_set_current_scene(source)
			obs.obs_source_release(source)
		end
		return
	end

	local source = obs.obs_get_source_by_name(source_name)
	if source ~= nil then
		local prev_source = obs.obs_frontend_get_current_scene()
		prev_scene_name = obs.obs_source_get_name(prev_source)
		obs.obs_frontend_set_current_scene(source)
		obs.obs_source_release(prev_source)
		obs.obs_source_release(source)
	end
end

----------------------------------------------------------

-- A function named script_properties defines the properties that the user
-- can change for the entire script module itself
function script_properties()
	local props = obs.obs_properties_create()

	local p = obs.obs_properties_add_list(props, "scene", "Scene", obs.OBS_COMBO_TYPE_EDITABLE, obs.OBS_COMBO_FORMAT_STRING)
	local sources = obs.obs_frontend_get_scenes()
	if sources ~= nil then
		for _, source in ipairs(sources) do
			source_id = obs.obs_source_get_unversioned_id(source)
			local name = obs.obs_source_get_name(source)
			if source_id == "scene" then
				obs.obs_property_list_add_string(p, name, name)
			end
		end
	end
	obs.source_list_release(sources)

	return props
end

-- A function named script_description returns the description shown to
-- the user
function script_description()
	return "Adds a hotkey that can be held to switch to a particular scene.\n\nMade by https://twitch.tv/badcop_"
end

-- A function named script_update will be called when settings are changed
function script_update(settings)
	source_name = obs.obs_data_get_string(settings, "scene")
end

-- A function named script_defaults will be called to set the default settings
function script_defaults(settings)
end

-- A function named script_save will be called when the script is saved
--
-- NOTE: This function is usually used for saving extra data (such as in this
-- case, a hotkey's save data).  Settings set via the properties are saved
-- automatically.
function script_save(settings)
	local hotkey_save_array = obs.obs_hotkey_save(hotkey_id)
	obs.obs_data_set_array(settings, "show_hotkey", hotkey_save_array)
	obs.obs_data_array_release(hotkey_save_array)
end

-- a function named script_load will be called on startup
function script_load(settings)
	-- Connect hotkey and activation/deactivation signal callbacks
	--
	-- NOTE: These particular script callbacks do not necessarily have to
	-- be disconnected, as callbacks will automatically destroy themselves
	-- if the script is unloaded.  So there's no real need to manually
	-- disconnect callbacks that are intended to last until the script is
	-- unloaded.
	hotkey_id = obs.obs_hotkey_register_frontend("hold_to_show_scene", "Hold to Show Scene", hotkey_handler)
	local hotkey_save_array = obs.obs_data_get_array(settings, "show_hotkey")
	obs.obs_hotkey_load(hotkey_id, hotkey_save_array)
	obs.obs_data_array_release(hotkey_save_array)
end
