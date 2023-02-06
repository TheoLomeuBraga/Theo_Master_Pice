require("TMP_libs.definitions")
require("TMP_libs.components.component_table")
require("TMP_libs.components.component_all")
require("TMP_libs.components.component_index")
require("TMP_libs.objects.game_object")
require("TMP_libs.objects.time")
require("TMP_libs.stystems")
require("TMP_libs.input")
require("TMP_libs.layers_table")
require("TMP_libs.objects.render_layer")


require("math")
json = require("libs.json")


require("TMP_libs.short_cuts.load_2D_map")
require("TMP_libs.short_cuts.create_text")
require("TMP_libs.short_cuts.create_sound")
require("TMP_libs.short_cuts.create_mesh")
require("TMP_libs.short_cuts.create_camera")

require("TMP_libs.material")


camera = nil
map_info = nil

objects_layesrs = layers_table:new_2D()





function clean_layer(ptr)
    obj = game_object:new(ptr)
    obj:get_family()
    --obj:get()
    i = 0
    print("childrens_size",obj.childrens_size)
    while i < obj.childrens_size do
        remove_object(obj.childrens[i])
        i = i + 1
    end
    
end

function setup_objects()
    objects_layesrs:create()
    camera = create_camera_ortho(objects_layesrs.camera,Vec3:new(-1, 0, 0),Vec3:new(0, 0, 0),20,20,720,720,0.1,100)
    tile_map_material = material:new()
    tile_map_material.shader = "resources/Shaders/sprite"

    --map_info = load_2D_map(father,pos,rot,sca,tile_map_path,tile_set_path,tile_set_images_folder,tile_map_material)
end

function initialize_render_layers()
    --[[
    window.res.x = 720
    window.res.y = 720
    window:set()
    --]]

    renders_layers.layers_size = 4

    renders_layers.layers[1] = render_layer:new()
    renders_layers.layers[1].end_render = false
    renders_layers.layers[1].use_deeph = true
    renders_layers.layers[1].clean_color = false
    renders_layers.layers[1].start_render = true

    renders_layers.layers[2] = render_layer:new()
    renders_layers.layers[2].end_render = false
    renders_layers.layers[2].use_deeph = true
    renders_layers.layers[2].clean_color = false
    renders_layers.layers[2].start_render = false

    renders_layers.layers[3] = render_layer:new()
    renders_layers.layers[3].end_render = true
    renders_layers.layers[3].use_deeph = true
    renders_layers.layers[3].clean_color = false
    renders_layers.layers[3].start_render = false

    renders_layers:set()
    
end

t = tile:new()
tm = tile_map:new()
function START()
    
	print("core iniciando")
    window.res.x = 720
    window.res.y = 720
    window:set()

    initialize_render_layers()
    
    setup_objects()
    
    
    
    
    
    
    

end



function UPDATE()
    
    
end

function COLIDE(Colision)
end

function END()
end






