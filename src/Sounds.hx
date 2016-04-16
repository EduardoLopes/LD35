package;

import snow.types.Types.AudioHandle;
import luxe.resource.Resource;
import snow.types.Types.AudioState;

class Sounds {

  var sounds_resources : Map<String, AudioResource>;
  var sounds_handelers : Map<String, AudioHandle>;

  public function new(){

    sounds_resources = new Map<String, AudioResource>();
    sounds_handelers = new Map<String, AudioHandle>();

  }

  function register(id : String, name : String){

    sounds_resources.set( name,  Luxe.resources.audio( id ) );

  }

  public function play(name : String, stop : Bool = true, volume : Float = 1){

    var handle = sounds_handelers.get( name );
    var resource = sounds_resources.get( name );

    if(stop && handle != null){

      Luxe.audio.stop( handle );

    }

    sounds_handelers.set( name,  Luxe.audio.play( resource.source, volume ) );

  }

  public function volume(name : String, volume : Float){

    var handle = sounds_handelers.get( name );

    if(handle != null){

      Luxe.audio.volume(handle, volume);

    }

  }

  public function stop(name : String){

    var handle = sounds_handelers.get( name );

    if(handle != null){

      Luxe.audio.stop( handle );

    }

  }

  public function reset_all_volumes(){

    for(sound in sounds_handelers){
      Luxe.audio.volume(sound, 1);
    }

  }

}