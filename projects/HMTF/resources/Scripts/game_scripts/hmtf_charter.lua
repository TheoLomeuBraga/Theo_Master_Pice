require("engine_libs.definitions")
require("engine_libs.components.extras")
require("engine_libs.components.component_all")
require("engine_libs.components.component_index")

require("engine_libs.objects.game_object")
require("engine_libs.objects.time")

require("engine_libs.objects.material")
require("engine_libs.objects.global_data")
require("engine_libs.objects.vectors")
require("engine_libs.objects.input")
require("engine_libs.objects.gravity")
require("engine_libs.objects.scene_3D")
require("engine_libs.objects.window")

require("engine_libs.short_cuts.create_camera")
require("engine_libs.short_cuts.create_collision")
require("resources.playable_scene")

require("math")


local this_object = {}
camera = {}
check_top = {}
check_down = {}

direction_reference = {}

local layers = {}

health = 100
max_health = 100
inventory = {
    double_jump = 0,
    jump_booster = 15,
    gun = 0,
    sword = 0,
    super_charger = 0,
}

function START()

    global_data:set("player_object_ptr",this_object_ptr)

    this_object = game_object:new(this_object_ptr)
    camera = create_camera_perspective(this_object_ptr, { x = 0, y = 0.5, z = 0 }, { x = 0, y = 0, z = 0 }, 90, 0.1, 1000)
    set_lisener_object(camera.object_ptr)

    layers = global_data:get_var("layers")
    check_top = create_collision_3D(layers.cenary, Vec3:new(0,0,0), Vec3:new(0,0,0), Vec3:new(0.75,0.75,0.75), true,collision_shapes.cylinder,nil,true)
    check_down = create_collision_3D(layers.cenary, Vec3:new(0,0,0), Vec3:new(0,0,0), Vec3:new(0.75,0.75,0.75), true,collision_shapes.cylinder,nil,true)

    this_object.components[components.transform]:change_rotation(0,0,0)
    
    this_object:add_component(components.physics_3D)
    this_object.components[components.physics_3D].boady_dynamic = boady_dynamics.dynamic
    this_object.components[components.physics_3D].rotate_X = false
    this_object.components[components.physics_3D].rotate_Y = false
    this_object.components[components.physics_3D].rotate_Z = false
    this_object.components[components.physics_3D].friction = 0
    this_object.components[components.physics_3D].gravity_scale = 0
    this_object.components[components.physics_3D].triger = false
    this_object.components[components.physics_3D].collision_shape = collision_shapes.capsule
    this_object.components[components.physics_3D].scale = Vec3:new(1,2,1)
    this_object.components[components.physics_3D]:set()

    direction_reference = game_object:new(this_object_ptr)
    direction_reference:add_component(components.transform)
    direction_reference.components[components.transform]:set()

    
end

speed = 12
mouse_sensitivity = 0

hit_top = false
hit_down = false

local inputs = {}
local inputs_last_frame = {}

camera_rotation = {x=180,y=0}

this_object_physics_3D_seted = false

force_y = 12

inpulse_y = 0

base_directional_inpulse = {x=0,y=0,z=0}
directional_inpulse = {x=0,y=0,z=0}
directional_inpulse_force = 0

friction = 10
air_friction = 0.5

pause_last_frame = false

function aproche_to_zero(num,speed)
    ret = 0
    if math.abs(num) < speed then
        ret = 0
    elseif num < 0 then
        ret = num + speed
    elseif num > 0 then
        ret = num - speed
    end
    return ret
end

function aproche_to_target_value(num,speed,target_value)
    ret = target_value
    if math.abs(num) < speed then
        ret = target_value
    elseif num < target_value then
        ret = num + speed
    elseif num > target_value then
        ret = num - speed
    end
    return ret
end

function UPDATE()

    time:get()
    gravity:get()

    mouse_sensitivity = global_data:get("mouse_sensitivity")

    

    inputs = global_data:get("inputs")
    inputs_last_frame = global_data:get("inputs_last_frame")

    if inputs.menu > 0 and not (inputs_last_frame.menu > 0) then
        if menu.obj == nil then
            menu.open()
        else
            menu.close()
        end
    end

    enable_cursor(global_data:get("pause") > 0)
    

    if global_data:get("pause") < 1 then
        
        this_object.components[components.transform]:get()
        local pos = deepcopy(this_object.components[components.transform].position)

        --hit top
        check_top.components[components.transform]:change_position(pos.x,pos.y + 1.75 ,pos.z)
        check_top.components[components.physics_3D]:get()
        hit_top = tablelength(check_top.components[components.physics_3D].objs_touching) > 1
    
        --hit down
        check_down.components[components.transform]:change_position(pos.x,pos.y - 1.75 ,pos.z)
        check_down.components[components.physics_3D]:get()
        hit_down = tablelength(check_down.components[components.physics_3D].objs_touching) > 1

        --move camera
        window:get()
        camera_rotation.x = camera_rotation.x-(inputs.mouse_view_x) * mouse_sensitivity * 20
        camera_rotation.y = math.max(math.min(camera_rotation.y-((inputs.mouse_view_y) * mouse_sensitivity * 20),90),-90)
        

        if not this_object_physics_3D_seted then
            this_object.components[components.physics_3D]:set()
            this_object_physics_3D_seted = not this_object_physics_3D_seted
        end
        
        
        
        --get floor info
        local hit = false
        local hit_info = {}
        hit,hit_info = raycast_3D(direction_reference.components[components.transform]:get_global_position(0,-1,0),direction_reference.components[components.transform]:get_global_position(0,-10,0))
        if not hit or not hit_down then
            hit_info.normal = {x=0,y=1,z=0}
        end

        --get movement direction
        local input_dir = direction_reference.components[components.transform]:get_local_direction(inputs.foward ,0,-inputs.left )
        local move_dir = crossProduct(input_dir,hit_info.normal)
        

        --hit floor
        if hit_down and not (inpulse_y > 0)  then

            inpulse_y = 0
            
            directional_inpulse_force = aproche_to_zero(directional_inpulse_force,time.delta * friction)

        end

        --jump
        if hit_down and inpulse_y <= 0 and inputs.jump > 0 and not (inputs_last_frame.jump > 0) then
            inpulse_y = force_y
            base_directional_inpulse = deepcopy(input_dir)
            directional_inpulse_force = inventory.jump_booster + speed
        end

        --ajust directional inpulse direction
        if (input_dir.x ~= 0 and input_dir.z ~=0) and (input_dir.x > base_directional_inpulse.x) or (input_dir.x < base_directional_inpulse.x) or (input_dir.z > base_directional_inpulse.z) or (input_dir.z < base_directional_inpulse.z) then
            base_directional_inpulse.x = aproche_to_target_value(base_directional_inpulse.x,air_friction * time.delta * math.abs(input_dir.x),input_dir.x)
            base_directional_inpulse.z = aproche_to_target_value(base_directional_inpulse.z,air_friction * time.delta * math.abs(input_dir.z),input_dir.z)
        end

        --ajust directional inpulse force
        if (input_dir.x > 0 and base_directional_inpulse.x < 0) or (input_dir.x < 0 and base_directional_inpulse.x > 0) or (input_dir.z > 0 and base_directional_inpulse.z < 0) or (input_dir.z < 0 and base_directional_inpulse.z > 0) then
            directional_inpulse_force = aproche_to_target_value(directional_inpulse_force,air_friction * time.delta,speed) 
        end


        directional_inpulse  = crossProduct(base_directional_inpulse,hit_info.normal)

        --hit cealing
        if hit_top and inpulse_y > 0 then
            inpulse_y = 0
        end

        --move
        if hit_down and not (inpulse_y > 0) then
            this_object.components[components.physics_3D]:set_linear_velocity((move_dir.x * speed) * time.sacale,(move_dir.y * speed) + inpulse_y * time.sacale,(move_dir.z * speed)  * time.sacale)
        else 
            this_object.components[components.physics_3D]:set_linear_velocity((directional_inpulse.x * directional_inpulse_force) * time.sacale,inpulse_y + (directional_inpulse.y * directional_inpulse_force) * time.sacale,(directional_inpulse.z * directional_inpulse_force)  * time.sacale)
        end
        

        if not hit_down then
            inpulse_y = inpulse_y + ( time.delta * gravity.force.y )
        end
        

    end

    camera.components[components.transform]:change_rotation(camera_rotation.y,0,0)
    this_object.components[components.transform]:change_rotation(0,camera_rotation.x,0)
    pause_last_frame = global_data:get("pause") < 1

end

function COLLIDE(collision_info)
end

function END()
    remove_object(camera.object_ptr)
    remove_object(check_top.object_ptr)
    remove_object(check_down.object_ptr)
    global_data:set("player_object_ptr","")
end