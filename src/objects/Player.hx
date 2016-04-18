package objects;

import engine.Sprite;
import luxe.Vector;
import luxe.Color;
import luxe.components.sprite.SpriteAnimation;

import nape.phys.Body;
import nape.shape.Polygon;
import nape.shape.Shape;
import nape.phys.BodyType;
import nape.phys.Material;

import nape.callbacks.PreCallback;
import nape.callbacks.PreFlag;
import nape.callbacks.PreListener;
import nape.callbacks.InteractionType;

import states.Game;

import luxe.importers.tiled.TiledObjectGroup;

import objects.states.StateMachine;

import components.BodySetup;
import components.TouchingChecker;

import components.Blinker;


class Player extends Sprite {

  public var body : Body;
  public var physics : BodySetup;
  /*public var anim : SpriteAnimation;*/
  public var moving : Bool;
  public var canMove: Bool;
  public var core : Shape;
  public var walkForce : Float = 150;
  public var invincible : Bool = false;
  public var onGround : Bool = false;

  public static var shape_name : String = 'rectangle';

  var blinker : Blinker;

  var jumps : Int = 1;

  var rectangle_change : Sprite;
  var rectangle_change_anim : SpriteAnimation;

  var circle_change : Sprite;
  var circle_change_anim : SpriteAnimation;

  public function new (x : Float, y : Float){

    super({
      pos: new Vector(x, y),
      texture: Luxe.resources.texture('assets/images/player.png'),
      name: 'player',
      depth: 3.4,
      size: new Vector(8, 8)
    });

    rectangle_change = new Sprite({
      pos: new Vector(0, 0),
      texture: Luxe.resources.texture('assets/images/rectangle_change.png'),
      name: 'rectangle_change',
      depth: 3.5,
      size: new Vector(26, 26)
    });

    circle_change = new Sprite({
      pos: new Vector(0, 0),
      texture: Luxe.resources.texture('assets/images/circle_change.png'),
      name: 'circle_change',
      depth: 3.5,
      size: new Vector(24, 24)
    });

    rectangle_change.uv.x = rectangle_change.size.x * 10;
    circle_change.uv.x = circle_change.size.x * 10;

    canMove = true;

    physics = add(new BodySetup({
      bodyType: BodyType.DYNAMIC,
      types: [Main.types.Player, Main.types.Movable],
      polygon: Polygon.box(8, 8),
      isBullet: true
    }));

    body = physics.body;
    core = physics.core;

    //Luxe.camera.get('follower').setFollower(this);

    blinker = add( new Blinker({name: 'blinker'}) );

    body.userData.name = 'player';
    core.userData.name = 'player';

    add( new TouchingChecker('player-floor', Main.types.Player, Main.types.Floor, core.id, InteractionType.COLLISION) );

    events.listen('player-floor_onBottom', function(_){
      onGround = true;
      jumps = 1;
      body.setShapeMaterials(Materials.Ground);
    });

    events.listen('player-floor_offBottom', function(_){
      onGround = false;
      body.setShapeMaterials(Materials.Air);
    });

    /*var anim_object = Luxe.resources.json('assets/jsons/player_animation.json');

    anim = add( new SpriteAnimation({ name:'anim' }) );
    anim.add_from_json_object( anim_object.asset.json );*/


    var anim_object = Luxe.resources.json('assets/jsons/animation.json');

    rectangle_change_anim = rectangle_change.add( new SpriteAnimation({ name:'anim' }) );
    rectangle_change_anim.add_from_json_object( anim_object.asset.json );

    circle_change_anim = circle_change.add( new SpriteAnimation({ name:'anim' }) );
    circle_change_anim.add_from_json_object( anim_object.asset.json );

    //Game.drawer.add(body);

    Luxe.physics.nape.space.listeners.add(new PreListener(
      InteractionType.COLLISION,
      Main.types.Player,
      Main.types.Enemy,
      player_collisions,
      /*precedence*/ 1,
      /*pure*/ true
    ));

    uv.x = 0;
    uv.w = 8;

  }

  public function set_rectangle(){

    rectangle_change_anim.animation = 'rectangle_change';
    rectangle_change_anim.play();

    Luxe.timescale = 0.000001;
    Luxe.timer.schedule(0.1, function(){

      Luxe.timescale = 1;
      shape_name = 'rectangle';
      uv.x = 0;

    });

  }

  public function set_circle(){

    circle_change_anim.animation = 'circle_change';
    circle_change_anim.play();

    Luxe.timescale = 0.000001;
    Luxe.timer.schedule(0.1, function(){

      Luxe.timescale = 1;
      shape_name = 'circle';
      uv.x = 8;

    });

  }

  function player_collisions(cb:PreCallback):PreFlag {

    if(invincible){

      return PreFlag.IGNORE_ONCE;

    }

    return PreFlag.ACCEPT_ONCE;
  }

  override public function ondestroy(){

    super.ondestroy();

    //Game.drawer.remove(body);

  }

  override function update(dt:Float) {

    super.update(dt);

    moving = false;

    body.velocity.x = 0;

    if(Luxe.input.inputdown('left') || Main.pressingGamepadLeft) {

      body.velocity.x = -walkForce;
      moving = true;

    } else if(Luxe.input.inputdown('right') || Main.pressingGamepadRight) {

      body.velocity.x = walkForce;
      moving = true;

    }

    if(Luxe.input.inputpressed('up') && onGround) {

      body.velocity.y = -(walkForce + 50);
      moving = true;

    }

    if(Luxe.input.inputpressed('up') && jumps == 1 && onGround == false){
      body.velocity.y = -(walkForce + 50);
      moving = true;
      jumps--;
    }

    if( Luxe.input.inputpressed('shift') ){

      if(shape_name == 'rectangle'){
        set_circle();
      } else if(shape_name == 'circle'){
        set_rectangle();
      }

    }

    pos.x = body.position.x;
    pos.y = body.position.y;

    pos = pos.int();

    circle_change.pos.x = pos.x;
    circle_change.pos.y = pos.y;
    rectangle_change.pos.x = pos.x;
    rectangle_change.pos.y = pos.y;

    Main.pressingGamepadLeft = false;
    Main.pressingGamepadRight = false;
    Main.pressingGamepadUp = false;
    Main.pressingGamepadDown = false;

  }

}
