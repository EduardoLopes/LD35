package components;

import luxe.Component;

import luxe.Vector;
import luxe.Visual;

class Blinker extends Component {

  var object : Visual;
  var time : Float = 0;
  var interval : Float = 0;
  var intervalTimer : Float = 0;
  var callOnCompleteCallback : Bool = false;
  var onCompleteCallback:Void->Void;
  var delay : Float = 0;

  override function init() {

    object = cast entity;

  }

  public function blink(Time : Float, Interval : Float, OnCompleteCallback:Void->Void, Delay : Float = 0){

    time = Time;
    interval = intervalTimer = Interval;
    callOnCompleteCallback = true;
    onCompleteCallback = OnCompleteCallback;
    delay = Delay;

  }

  public function cancel(){

    time = 0;
    interval = intervalTimer = 0;
    callOnCompleteCallback = false;
    onCompleteCallback = null;

  }

  override function update(dt:Float):Void {

    delay -= dt;

    if(delay >= 0) return;

    if(time > 0){

      time -= dt;
      intervalTimer -= dt;

      if(intervalTimer <= 0){
        object.visible = !object.visible;
        intervalTimer = interval;
      }

    } else if(callOnCompleteCallback){

      if(onCompleteCallback != null){
        onCompleteCallback();
        callOnCompleteCallback = false;
      }

    }

  }

}