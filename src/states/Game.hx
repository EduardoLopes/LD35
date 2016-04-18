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
import nape.geom.Vec2;

import nape.shape.Shape;

import luxe.Text;

import objects.ObjectPool;
import objects.Player;
import objects.Rectangle;
import objects.Circle;
import objects.RectangleExplosion;
import objects.CircleExplosion;

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
  public var level : Level;
  public static var rectangle_emitter : ObjectPool<Rectangle>;
  public static var circle_emitter : ObjectPool<Circle>;
  public static var rectangle_explosion_emitter : ObjectPool<RectangleExplosion>;
  public static var circle_explosion_emitter : ObjectPool<CircleExplosion>;

  var time_to_spawn : Float = 5;
  var timer_to_spawn : Float = 5;

  public static var score_text : Text;
  public static var score : Int = 0;

  public function new() {

    super({ name:'game' });

    drawer = new DebugDraw({
      depth: 100
    });

    Luxe.timescale = 1;

    Luxe.physics.nape.debugdraw = drawer;
    Luxe.physics.nape.draw = true;

    connect_input();

    rectangle_emitter = new ObjectPool<Rectangle>(function(){
      return new Rectangle();
    });

    circle_emitter = new ObjectPool<Circle>(function(){
      return new Circle();
    });

    rectangle_explosion_emitter = new ObjectPool<RectangleExplosion>(function(){
      return new RectangleExplosion();
    });

    circle_explosion_emitter = new ObjectPool<CircleExplosion>(function(){
      return new CircleExplosion();
    });

    score_text = new Text({
      text: '0',
      pos : new Vector(12 * 8, 7 * 8),
      point_size : 32,
      color: new luxe.Color().rgb(0x6d1254),
      font: Luxe.resources.font('assets/fonts/font.fnt'),
      align: center,
      bounds : new luxe.Rectangle(0, 0, 6*8, 6*8),
      depth: 1
    });

/*    Main.backgroundBatcherCamera.pos.x = -(CameraFollower.screenMiddle.x);
    Main.backgroundBatcherCamera.pos.y = -(CameraFollower.screenMiddle.y);
    Main.foregroundBatcherCamera.pos.x = -(CameraFollower.screenMiddle.x);
    Main.foregroundBatcherCamera.pos.y = -(CameraFollower.screenMiddle.y);*/

    var res = Luxe.resources.text('assets/maps/map-1.tmx');

    level = new Level({
      tiled_file_data : res.asset.text,
      pos : new Vector(0, 0) ,
      asset_path : 'assets/images'
    });

    level.display({ visible: true, scale:1 });

    player = new Player(240 / 2, 170 / 2);

  }

  override function onenter<T>(_:T) {

    //Main.sounds.reset_all_volumes();

    Game.score = 0;
    Game.score_text.text = Std.string(Game.score);

    enable();

    timer_to_spawn = time_to_spawn;

    //Luxe.camera.get('follower').resetCamera();

    player.body.position.x = 270 / 2;
    player.body.position.y = 170 / 2;
    Player.dead = false;

    for(i in 0...20){
      spawn();
    }

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

    Luxe.input.bind_gamepad('up', 2);

    Luxe.input.bind_key('shift', Key.space);

    Luxe.input.bind_gamepad('shift', 4);
    Luxe.input.bind_gamepad('shift', 5);

  }

  function spawn(){

    var x = Luxe.utils.random.int(0, level.width - 1);
    var y = Luxe.utils.random.int(0, level.height - 1);

    var bodies : nape.phys.BodyList = Luxe.physics.nape.space.bodiesUnderPoint(Vec2.weak((x * 8) + 4, (y * 8) + 4));

    if(bodies.empty() == true){
      if(Luxe.utils.random.bool(0.5)){
        rectangle_emitter.get().spawn((x * 8) + 4, (y * 8) + 4);
      } else {
        circle_emitter.get().spawn((x * 8) + 4, (y * 8) + 4);
      }
    }

  }

  override function update(dt:Float){

    timer_to_spawn -= dt;

    if(timer_to_spawn < 0){

      timer_to_spawn = time_to_spawn;

      for(i in 0...Luxe.utils.random.int(1, 5)){
        spawn();
      }

    }

  }

  override function onleave<T>(_:T) {

/*    player.destroy();
    player = null;*/

    disable();

    for(rect in rectangle_emitter.busy){
      rect.kill();
    }

    for(circle in circle_emitter.busy){
      circle.kill();
    }

    for(rect_explosion in rectangle_explosion_emitter.busy){
      rect_explosion.free();
    }

    for(circle_explosion in circle_explosion_emitter.busy){
      circle_explosion.free();
    }

  }

}