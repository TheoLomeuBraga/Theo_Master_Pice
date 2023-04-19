require("TMP_libs.definitions")
require("TMP_libs.components.component_table")
require("TMP_libs.components.component_all")
require("TMP_libs.components.component_index")
require("TMP_libs.objects.game_object")
require("TMP_libs.objects.time")
require("TMP_libs.stystems")
require("TMP_libs.layers_table")
require("TMP_libs.objects.render_layer")




require("math")
json = require("libs.json")


require("TMP_libs.short_cuts.load_2D_map")
require("TMP_libs.short_cuts.create_text")
require("TMP_libs.short_cuts.create_sound")
require("TMP_libs.short_cuts.create_mesh")
require("TMP_libs.short_cuts.create_camera")
require("TMP_libs.short_cuts.fps_counter")
require("TMP_libs.short_cuts.create_render_shader")

require("TMP_libs.material")
require("all_sceanes")


require("run_comunication_test")

require("TMP_libs.objects.input")




function set_resolution()
    window.resolution.x = 720
    window.resolution.y = 720
    window:set()
end

function START()
    print("core iniciando")
    full_test()
    set_resolution()


    --objects_layesrs:create()



    print("divisoria")
    sceanes_db["test3"]:load()
end

function printTableElements(tbl)
    for key, value in ipairs(tbl) do
        print("Element ", key, ": ", value)
    end
end

function UPDATE()
    --[[
    keys_axis:set_text_input_geter(true)
    print(keys_axis:get_text_input())
    ]]

    --[[
    if keys_axis:get_input(input_devices.keyboard,"a") == 1 then
        print("a",keys_axis:get_input(input_devices.keyboard,"a"))
    end
    ]]
    
    --[[
    l = keys_axis:get_input(input_devices.mouse, "left")
    r = keys_axis:get_input(input_devices.mouse, "right")
    print("mouse movement", l, r)
    ]]
    
    --[[
    if keys_axis:get_input_joystick(1,"a") == 1 then
        print("a",keys_axis:get_input_joystick(1,"a"))
    end
    ]]
    rx = keys_axis:get_input_joystick(1,"rx")
    if rx > 0 then
        print("AAAAA:",rx)
    end
    
end

function COLLIDE(collision_info)
end

function END()
end
