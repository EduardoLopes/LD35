package components;

import luxe.Component;

import nape.callbacks.CbEvent;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.CbType;
import nape.dynamics.ArbiterList;

import nape.callbacks.InteractionType;
import nape.callbacks.PreFlag;
import nape.dynamics.Arbiter;

@:enum abstract Touching(Int) from Int to Int{
  var NONE    = 0;
  var TOP     = 1;
  var RIGHT   = 2;
  var BOTTOM  = 4;
  var LEFT    = 8;
  var WALL    = 2 | 8;
  var ANY    = 1 | 2 | 4 | 8;
}

class TouchingChecker extends Component {

  var object : Dynamic;
  var objectType1 : CbType;
  var objectType2 : CbType;
  var lastWallEvent:String;
  var lastGroundEvent:String;
  var lastLeftWallEvent:String;
  var lastRightWallEvent:String;
  var lastColladingEvent:String;
  var wallEvent:String;
  var groundEvent:String;
  var leftWallEvent:String;
  var rightWallEvent:String;
  var colladingEvent:String;
  var touching:Touching;
  var wasTouching:Touching;
  var swapped:Bool = false;
  /*
      InteractionListener callback is not called in some frames,
      this function helpes figure out if i was called or not
  */
  var touchingFunctionUpdated:Bool = false;

  var interactionListener_ongoing : InteractionListener;
  var interactionListener_end : InteractionListener;

  var shape_id : Int;

  public function new(componentName:String, ObjectType1 : CbType, ObjectType2 : CbType, shapeID : Int){

    super({name: componentName});

    objectType1 = ObjectType1;
    objectType2 = ObjectType2;

    shape_id = shapeID;

  }

  override function init() {

    object = cast entity;

    interactionListener_ongoing = new InteractionListener(
      CbEvent.ONGOING, InteractionType.COLLISION,
      objectType1,
      objectType2,
      onGoing
    );

    interactionListener_end = new InteractionListener(
      CbEvent.END, InteractionType.COLLISION,
      objectType1,
      objectType2,
      end
    );

    Luxe.physics.nape.space.listeners.add(interactionListener_ongoing);
    Luxe.physics.nape.space.listeners.add(interactionListener_end);

  }

  override function onremoved(){

    if(interactionListener_ongoing != null){
      Luxe.physics.nape.space.listeners.remove(interactionListener_ongoing);
    }

    if(interactionListener_end != null){
      Luxe.physics.nape.space.listeners.remove(interactionListener_end);
    }

    interactionListener_ongoing = null;
    interactionListener_end = null;

  }

  function checkAbriter(arbiter:Arbiter):Void{

    var colArb = arbiter.collisionArbiter;

    if(arbiter.state == PreFlag.IGNORE || arbiter.state == PreFlag.IGNORE_ONCE) return;

    if(colArb.shape1.id != shape_id){

      if(colArb.normal.y == 1) touching |= Touching.TOP;
      if(colArb.normal.x == 1) touching |= Touching.LEFT;
      if(colArb.normal.y == -1) touching |= Touching.BOTTOM;
      if(colArb.normal.x == -1) touching |= Touching.RIGHT;

    } else {

      if(colArb.normal.y == 1) touching |= Touching.BOTTOM;
      if(colArb.normal.x == 1) touching |= Touching.RIGHT;
      if(colArb.normal.y == -1) touching |= Touching.TOP;
      if(colArb.normal.x == -1) touching |= Touching.LEFT;

    }

  }

  function checkContacts(arbiters:ArbiterList):Void{

    arbiters.foreach(checkAbriter);

    touchingFunctionUpdated = true;

  }

  function onGoing(cb:InteractionCallback){

    checkContacts(cb.arbiters);

  }

  function end(cb:InteractionCallback){

    checkContacts(cb.arbiters);

  }

  function isTouching(direction:Touching){

    return (touching & direction) != Touching.NONE;

  }

  function justTouched(direction:Touching){

    return isTouching(touching) && (wasTouching & direction) == Touching.NONE;

  }

  override function update(dt:Float):Void{

    if(touchingFunctionUpdated == false || object == null) return null;

    if( isTouching(Touching.RIGHT) ){
      rightWallEvent = name+'_onRight';
    } else {
      rightWallEvent = name+'_offRight';
    }

    if( isTouching(Touching.LEFT)  ){
      leftWallEvent = name+'_onLeft';
    } else {
      leftWallEvent = name+'_offLeft';
    }

    if( isTouching(Touching.WALL)  ){
      wallEvent = name+'_onSide';
    } else {
      wallEvent = name+'_offSide';
    }

    if( isTouching(Touching.BOTTOM)  ){
      groundEvent = name+'_onBottom';
    } else {
      groundEvent = name+'_offBottom';
    }

    if( isTouching(Touching.ANY)  ){
      colladingEvent = name+'_collading';
    } else {
      colladingEvent = name+'_wasCollading';
    }

    if( rightWallEvent != lastRightWallEvent ){

      object.events.fire(rightWallEvent);
      lastRightWallEvent = rightWallEvent;

    }

    if( leftWallEvent != lastLeftWallEvent ){

      object.events.fire(leftWallEvent);
      lastLeftWallEvent = leftWallEvent;

    }

    if( wallEvent != lastWallEvent ){

      object.events.fire(wallEvent);
      lastWallEvent = wallEvent;

    }

    if( groundEvent != lastGroundEvent ){

      object.events.fire(groundEvent);
      lastGroundEvent = groundEvent;

    }

    if( colladingEvent != lastColladingEvent ){

      object.events.fire(colladingEvent);
      lastColladingEvent = colladingEvent;

    }

    //clean up collision index
    wasTouching = touching;
    touching = Touching.NONE;

    touchingFunctionUpdated = false;

  }
}