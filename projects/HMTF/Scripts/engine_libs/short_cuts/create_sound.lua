require("components.extras")
require("objects.game_object")
require("components.transform")
require("components.audio_source")

function create_audio(father,music_path,loop,volume)
    ret = game_object(create_object(father)) 
    ret.components.audio_source.path = music_path
    ret.components.audio_source.loop = loop
    ret.components.audio_source.volume = volume
    ret.components.audio_source:set()
    return ret
end


function create_3D_audio(father,pos,music_path,loop,volume,min_distance,atenuation)
    ret = game_object(create_object(father)) 
    ret.components.transform.position = deepcopy(pos)
    ret.components.transform:set()
    ret.components.audio_source.path = music_path
    ret.components.audio_source.loop = loop
    ret.components.audio_source.volume = volume
    ret.components.audio_source.min_distance = min_distance
    ret.components.audio_source.atenuation = atenuation
    ret.components.audio_source:set()
    return ret
end

