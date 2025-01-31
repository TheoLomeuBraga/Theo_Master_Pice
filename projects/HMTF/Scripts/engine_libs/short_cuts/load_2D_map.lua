require("components.extras")
require("definitions")

require("objects.game_object")
require("components.transform")
require("components.render_tile_map")


require("math")
require("io")
json = require "libs.json"

function load_2D_map(father,pos,rot,sca,tile_map_path,tile_set_path,mat)
    ret = {tile_map_info={},tile_set_info={},map_object={}}

    --tile_map_info
    file = assert(io.open(tile_map_path, "rb"))
    file_content = file:read("*all")
    file:close()
    ret.tile_map_info = deepcopyjson(json.decode(file_content))

    --tile_set_info
    file = assert(io.open(tile_set_path, "rb"))
    file_content = file:read("*all")
    file:close()
    ret.tile_set_info = deepcopyjson(json.decode(file_content))
    
    

    --map_object
    ret.map_object = game_object(create_object(father))
    ret.map_object.components.transform.position = deepcopy(pos)
    ret.map_object.components.transform.rotation = deepcopy(rot)
    ret.map_object.components.transform.scale = deepcopy(sca)
    ret.map_object.components.transform:set()
    
    ret.map_object.components.render_tile_map.render_tilemap_only_layer = -1
    ret.map_object.components.render_tile_map.tile_map_local = tile_map_path
    ret.map_object.components.render_tile_map.tile_set_local = tile_set_path
    ret.map_object.components.render_tile_map.material = deepcopy(mat)
    ret.map_object.components.render_tile_map:set()

    

    return ret
end

