require("objects.global_data")
require("objects.input")
require("objects.time")
require("functions")
require("math")

require("components.extras")
require("components.ui_component")

inputs_last_frame = {}

inputs = {
    foward = 0,
    left = 0,
    jump = false,
    interact = false,
    action_1 = false,
    action_2 = false,
    mouse_view_x = 0,
    mouse_view_y = 0,
    analog_view_x = 0,
    analog_view_y = 0,
    mouse_pos_x = 0,
    mouse_pos_y = 0,
    menu = false,
}

function apply_death_zone(input,death_zone)
    local ret = input
    if math.abs(input) < death_zone then
        ret = 0
    end
    return ret
end

function START()
    inputs_last_frame = deepcopy(inputs)
end

local main_input_method = "keyboard"
function UPDATE()
    time:get()

    --print(get_joystick_input(1,"ly"))
    local analog_foward =  -apply_death_zone(get_joystick_input(1,"ly"),0.2)
    local analog_left =  -apply_death_zone(get_joystick_input(1,"lx"),0.2)

    local av_x = apply_death_zone(get_joystick_input(1,"rx"),0.2)-- + get_joystick_input(1,"rotation_z")
    local av_y = apply_death_zone(get_joystick_input(1,"ry"),0.2)-- + -get_joystick_input(1,"movement_x")

    if get_main_input_device() == 0 then

        set_joystick_led(1,0,0,0)

        inputs = {
            foward = get_keyboard_input("w") - get_keyboard_input("s"),
            left = get_keyboard_input("a") - get_keyboard_input("d"),
            jump = get_keyboard_input("space") ,
            interact = get_keyboard_input("e"),
            action_1 = get_mouse_input("left") ,
            action_2 = get_mouse_input("right") ,
            mouse_pos_x = get_mouse_input("normalized_x"),
            mouse_pos_y = get_mouse_input("normalized_y"),
            mouse_view_x = get_mouse_input("movement_x"),
            mouse_view_y = get_mouse_input("movement_y"),
            analog_view_x = 0,
            analog_view_y = 0,
            select = get_mouse_input("left"),
            back = get_keyboard_input("q"),
            menu = get_keyboard_input("escape") ,
        }

    elseif get_main_input_device() == 1 then

        inputs = {
            foward =  analog_foward,
            left =  analog_left,
            jump = get_joystick_input(1,"la"),
            interact = get_joystick_input(1,"north"),
            action_1 = (get_joystick_input(1,"rt")) ,
            action_2 = (get_joystick_input(1,"lt")) ,
            mouse_pos_x = 0,
            mouse_pos_y = 0,
            mouse_view_x = 0,
            mouse_view_y = 0,
            analog_view_x = av_x,
            analog_view_y = av_y,
            select = get_joystick_input(1,"south"),
            back = get_joystick_input(1,"east"),
            menu = get_joystick_input(1,"start"),
        }
        
    end

    if get_mouse_input("movement_x") + get_mouse_input("movement_y") + get_mouse_input("left") > 0.01 then
        main_input_method = "keyboard"
    elseif analog_foward + analog_left + av_x + av_y > 0 or analog_foward + analog_left + av_x + av_y < 0  then
        main_input_method = "joystick"
    end

    inputs.main_input_method = main_input_method
    

    inputs.action_1 = math.max(0,inputs.action_1)
    inputs.action_2 = math.max(0,inputs.action_2)

    if inputs.foward < -0.5 then
        inputs.foward = -1
    elseif inputs.foward > 0.1 then
        inputs.foward = 1
    end
    --inputs.foward = -inputs.foward


    if inputs.left < -1 then
        inputs.left = -1
    elseif inputs.left > 1 then
        inputs.left = 1
    end
    --inputs.left = -inputs.left
    

    
    global_data.inputs = inputs
    global_data.inputs_last_frame = inputs_last_frame
    inputs_last_frame = deepcopy(inputs)

    
    if main_input_method == "keyboard" then
        set_ui_selection_id(0,false)
        set_ui_curson_location({x=get_mouse_input("normalized_x"),y=get_mouse_input("normalized_y")},inputs.action_1 > 0)
    elseif main_input_method == "joystick" then
        set_ui_curson_location({x=0,y=0},false)
        set_ui_selection_id(global_data.ui_selection_id,inputs.action_1 > 0)
    end
    
end

function COLLIDE(collision_info)
end

function END()
end
