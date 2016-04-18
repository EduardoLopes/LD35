package states;

import luxe.States;
import luxe.Input;
import luxe.Vector;

import nape.callbacks.CbEvent;
import nape.callbacks.InteractionType;

import nape.callbacks.PreCallback;
import nape.callbacks.PreFlag;
import nape.callbacks.PreListener;

import luxe.physics.nape.DebugDraw;
/*import components.CameraFollower;*/

import nape.shape.Shape;

import luxe.Text;

import objects.ObjectPool;
import objects.Player;

import phoenix.Texture.ClampType;

enum Direction {
  LEFT;
  RIGHT;
  TOP;
  BOTTOM;
  NONE;
}

class Game extends State {

  public static var drawer : DebugDraw;
  public static var player : Player;

  public function new() {

    super({ name:'game' });

    drawer = new DebugDraw({
      depth: 100
    });

    Luxe.physics.nape.debugdraw = drawer;
    Luxe.physics.nape.draw = true;

    connect_input();

/*    Main.backgroundBatcherCamera.pos.x = -(CameraFollower.screenMiddle.x);
    Main.backgroundBatcherCamera.pos.y = -(CameraFollower.screenMiddle.y);
    Main.foregroundBatcherCamera.pos.x = -(CameraFollower.screenMiddle.x);
    Main.foregroundBatcherCamera.pos.y = -(CameraFollower.screenMiddle.y);*/

  }

  override function onenter<T>(_:T) {

    //Main.sounds.reset_all_volumes();

    enable();

    //Luxe.camera.get('follower').resetCamera();

    var res = Luxe.resources.text('assets/maps/map-1.tmx');

    var level = new Level({
      tiled_file_data : res.asset.text,
      pos : new Vector(0, 0) ,
      asset_path : 'assets/images'
    });

    level.display({ visible: true, scale:1 });

    player = new Player(240, 170);

  }


  function collisionEnemyPlayerHandeler(cb:PreCallback):PreFlag {

    var colArb = cb.arbiter.collisionArbiter;
    var ignone:Bool = false;

    var shape1 : Shape;
    var shape2 : Shape;

    if(!cb.swapped){
      shape1 = colArb.shape2;
      shape2 = colArb.shape1;
    } else {
      shape1 = colArb.shape1;
      shape2 = colArb.shape2;
    }

    if(shape2.userData.type == 'tilemap'){

      if(shape1.body.velocity.x > 0){

        if(shape1.bounds.x + shape1.bounds.width < shape2.bounds.x + 1.5){
          ignone = true;
        }

      } else if(shape1.body.velocity.x < 0) {

        if(shape1.bounds.x > (shape2.bounds.x + shape2.bounds.width) - 1.5){
          ignone = true;
        }

      }

      if(shape1.body.velocity.y > 0){

        if(shape1.bounds.y + shape1.bounds.height < shape2.bounds.y + 1.5){
          ignone = true;
        }

      } else if(shape1.body.velocity.y < 0) {

        if(shape1.bounds.y > (shape2.bounds.y + shape2.bounds.height) - 1.5){
          ignone = true;
        }

      }

    }

    if(ignone){
      return PreFlag.IGNORE_ONCE;
    }

    return PreFlag.ACCEPT;

  }

  function connect_input() {


    Luxe.input.bind_key('left', Key.left);
    Luxe.input.bind_key('left', Key.key_a);

    Luxe.input.bind_key('right', Key.right);
    Luxe.input.bind_key('right', Key.key_d);

    Luxe.input.bind_key('up', Key.key_w);
    Luxe.input.bind_key('up', Key.up);

    Luxe.input.bind_key('down', Key.key_s);
    Luxe.input.bind_key('down', Key.down);

    Luxe.input.bind_gamepad('turn_left', 4);
    Luxe.input.bind_gamepad('turn_right', 5);

  }

  override function update(dt:Float){

  }

  override function onleave<T>(_:T) {

/*    player.destroy();
    player = null;*/

  }

}