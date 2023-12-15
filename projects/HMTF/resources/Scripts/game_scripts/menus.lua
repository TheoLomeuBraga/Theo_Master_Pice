require("components.extras")
require("components.component_all")
require("components.component_index")
require("objects.input")
require("objects.time")
require("objects.global_data")
require("objects.window")
require("short_cuts.create_ui")
require("short_cuts.create_sound")
require("objects.window")
local serializer = require("libs.serialize")
require("math")



local arow_style = deepcopy(empty_style)
arow_style.text_color = { r = 1, g = 1, b = 0, a = 1 }
arow_style.text_size = 0.1

in_main_menu = 0

menu_types = {
    title = "title",
    start = "start",
    config = "config",
    play = "play",
    pause = "pause",
}
menu_selectred = "pause"
local menu_objects = {}
local menus_locations = {
    title = 0,
    start = 1,
    config = 2,
    play = 3,
}

function select_menu(pos)
    menu_objects.base.components.ui_component.position.x = menus_locations[pos]
    menu_objects.base.components.ui_component:set()
end

function save_configs()
    window:get()
    local configs = {
        volume = get_set_global_volume(),
        mouse_sensitivity = global_data:get_var("mouse_sensitivity"),
        full_screen = window.full_screen
    }

    serializer.save_table("config/configs_save.lua", configs)
end

function load_configs()
    local configs = serializer.load_table("config/configs_save.lua")
    if configs ~= nil then
        serializer.save_table("config/configs_save.lua",configs)
        get_set_global_volume(configs.volume)
        global_data:set_var("mouse_sensitivity",configs.mouse_sensitivity)
        window.full_screen = configs.full_screen
        window:set()
    else
        get_set_global_volume(100)
        global_data:set_var("mouse_sensitivity",6)
        window.full_screen = false
        window:set()
    end
end

--button functions

function quit_game(state, id)
    if state == "click" then
        window:close()
    end
end

function go_to_start_menu(state, id)
    if state == "click" then
        select_menu(menu_types.start)
        save_configs()
    end
end

function go_to_title_menu(state, id)
    if state == "click" then
        select_menu(menu_types.title)
    end
end

function go_to_config_menu(state, id)
    if state == "click" then
        select_menu(menu_types.config)
    end
end

function go_to_play_menu(state, id)
    if state == "click" then
        select_menu(menu_types.play)
    end
end

function toogle_full_screen(state, id)
    if state == "click" then
        window:get()
        window.full_screen = not window.full_screen
        window.resolution.x = 256
        window.resolution.y = 224
        window:set()
    end
end

sensitivity_display = {}
function sensitivity_slider(state, id)
    if state == "hold" then
        local drag_obj = game_object(id)
        local pos = drag_obj.components.ui_component.position
        pos.x = pos.x + global_data:get("inputs").mouse_view_x
        pos.x = math.min(0.8 - 2,math.max(0.2 - 2,pos.x))

        local sensitivity = math.floor((pos.x + 1.8) * 168) * 0.3
        sensitivity_display.components.ui_component.text = "sensitivity: " .. sensitivity
        global_data:set_var("mouse_sensitivity", sensitivity)

        sensitivity_display.components.ui_component:set()
        drag_obj.components.ui_component:set()
        
    end
end

volume_display = {}
function volume_slider(state, id)
    if state == "hold" then
        local drag_obj = game_object(id)
        local pos = drag_obj.components.ui_component.position
        pos.x = pos.x + global_data:get("inputs").mouse_view_x
        pos.x = math.min(0.8 - 2,math.max(0.2 - 2,pos.x))

        local volume = math.floor((pos.x + 1.8) * 168)
        volume_display.components.ui_component.text = "volume: " .. volume .. "%"

        get_set_global_volume(volume)

        volume_display.components.ui_component:set()
        drag_obj.components.ui_component:set()
        
    end
end

function start_title_menu()
    --title
    local title_style = deepcopy(empty_style)
    title_style.text_color = { r = 0, g = 1, b = 0, a = 1 }
    title_style.text_size = 0.2
    menu_objects.title = create_ui_element(menu_objects.base.object_ptr, ui_types.common, { x = 0.5, y = 0.85 },
        { x = 2, y = 2 }, "HMTF", nil, title_style)

    --start_button
    local start_style = deepcopy(empty_style)
    start_style.text_color = { r = 1, g = 1, b = 0, a = 1 }
    start_style.text_size = 0.1
    menu_objects.start_text = create_ui_element(menu_objects.base.object_ptr, ui_types.common, { x = 0.5, y = 0.5 },
        { x = 0.2, y = 0.2 }, "start", nil, start_style)

    create_ui_element_with_arows(menu_objects.base.object_ptr, ui_types.common, { x = 0.5, y = 0.5 },
        { x = 0.25, y = 0.2 }, "start", "go_to_start_menu", start_style, arow_style)
end

function start_start_menu()
    local button = deepcopy(empty_style)

    button.text_size = 0.1

    button.text_color = { r = 1, g = 1, b = 0, a = 1 }
    create_ui_element_with_arows(menu_objects.base.object_ptr, ui_types.common, { x = -0.5, y = 0.8 },
        { x = 0.5, y = 0.15 }, "play", "go_to_play_menu", button, arow_style)

    button.text_color = { r = 0, g = 1, b = 1, a = 1 }
    create_ui_element_with_arows(menu_objects.base.object_ptr, ui_types.common, { x = -0.5, y = 0.5 },
        { x = 0.5, y = 0.15 }, "config", "go_to_config_menu", button, arow_style)

    button.text_color = { r = 1, g = 0, b = 0, a = 1 }
    create_ui_element_with_arows(menu_objects.base.object_ptr, ui_types.common, { x = -0.5, y = 0.2 },
        { x = 0.5, y = 0.15 }, "exit", "quit_game", button, arow_style)
end

function start_config_menu()
    --title
    local title_style = deepcopy(empty_style)
    title_style.text_color = { r = 1, g = 1, b = 0, a = 1 }
    title_style.text_size = 0.1
    create_ui_element(menu_objects.base.object_ptr, ui_types.common, { x = -1.5, y = 0.85 },{ x = 2, y = 2 }, "config", nil, title_style)

    exit_style = deepcopy(title_style)
    exit_style.text_color = { r = 1, g = 0, b = 0, a = 1 }
    exit_hover_style = deepcopy(exit_style)
    exit_hover_style.background_color = { r = 1, g = 0.5, b = 0.5, a = 1 }
    create_ui_element(menu_objects.base.object_ptr, ui_types.common, { x = -1.8, y = 0.85 },{ x = 0.1, y = 0.1 }, "<", "go_to_start_menu", {exit_style,exit_hover_style})

    title_style.text_color = { r = 1, g = 1, b = 1, a = 1 }

    --drag button test
    --create_ui_element(menu_objects.base.object_ptr, ui_types.common, { x = -1.5, y = 0.5 },{ x = 0.1, y = 0.1 }, "", "drag_test", exit_hover_style)

    

    --add sensitivity control

    local configs = serializer.load_table("config/configs_save.lua")
    
    
    sensitivity_display = create_ui_element(menu_objects.base.object_ptr, ui_types.common, { x = -1.5, y = 0.6 },{ x = 0.5, y = 0.17 }, "sensitivity: " .. configs.mouse_sensitivity, nil, title_style)

    local sensitivity_slider_pos = ((configs.mouse_sensitivity / 30) * 0.6) + 0.2 
    create_ui_element(menu_objects.base.object_ptr, ui_types.common, { x = sensitivity_slider_pos - 2, y = 0.55 },{ x = 0.2, y = 0.15 }, "^", "sensitivity_slider", {title_style,arow_style,arow_style})

    local slider_bar = deepcopy(title_style)
    slider_bar.background_color = { r = 1, g = 1, b = 0, a = 1 }
    create_ui_element(menu_objects.base.object_ptr, ui_types.common, { x = -1.5, y = 0.58 },{ x = 0.6, y = 0.005 }, "", nil, slider_bar)
    
    --add volume control
    volume_display = create_ui_element(menu_objects.base.object_ptr, ui_types.common, { x = -1.5, y = 0.3 },{ x = 0.5, y = 0.17 }, "volume: " .. configs.volume .. "%", nil, title_style)

    local volume_slider_pos = ((configs.volume / 100) * 0.6) + 0.2 
    print(volume_slider_pos)
    --local volume_slider_pos = 0.5
    create_ui_element(menu_objects.base.object_ptr, ui_types.common, { x = volume_slider_pos - 2, y = 0.25 },{ x = 0.2, y = 0.15 }, "^", "volume_slider", {title_style,arow_style,arow_style})

    local slider_bar = deepcopy(title_style)
    slider_bar.background_color = { r = 1, g = 1, b = 0, a = 1 }
    create_ui_element(menu_objects.base.object_ptr, ui_types.common, { x = -1.5, y = 0.28 },{ x = 0.6, y = 0.005 }, "", nil, slider_bar)

    --toogle_full_screen
    local button = deepcopy(title_style)
    button.text_size = 0.06
    create_ui_element_with_arows(menu_objects.base.object_ptr, ui_types.common, { x = -1.5, y = 0.1 }, { x = 0.5, y = 0.17 },"toogle full screen", "toogle_full_screen", button)
end

function start_all_menus()
    local base_x_location = 0

    if in_main_menu > 0 then
        --background
        local background_style = deepcopy(empty_style)
        background_style.background_color = { r = 0, g = 0.2, b = 0.2, a = 1 }
        background_style.text_color = { r = 0, g = 1, b = 0, a = 1 }
        background_style.background_image = "resources/Textures/null.png"
        create_ui_element(this_object.object_ptr, ui_types.common, { x = 0.5, y = 0.5 }, { x = 1, y = 1 }, "", nil,
            background_style)
    end


    --base
    local base_style = advanced_ui_style()

    menu_objects.base = create_ui_element(this_object.object_ptr, ui_types.common, { x = 0, y = 0 }, { x = 0, y = 0 }, "",
        nil, deepcopy(empty_style))

    start_title_menu()
    start_start_menu()
    start_config_menu()
end

function START()
    global_data:set_var("pause", 1)
    time:set_speed(0)

    local layers = global_data:get_var("layers")

    this_object = game_object(this_object_ptr)

    start_all_menus()
    --show_pause_menu(true)
end

function UPDATE()

end

function END()
    time:set_speed(1)
    global_data:set_var("pause", 0)
    save_configs()
end

function COLLIDE(collision_info)
end
