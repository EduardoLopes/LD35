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

  var blinker : Blinker;

  public function new (x : Float, y : Float){

    super({
      pos: new Vector(x, y),
      texture: Luxe.resources.texture('assets/images/player.png'),
      name: 'player',
      depth: 3.4,
      size: new Vector(8, 8)
    });

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

    add( new TouchingChecker('player-floor', Main.types.Player, Main.types.Floor, core.id) );

    events.listen('player-floor_onBottom', function(_){
      onGround = true;
      body.setShapeMaterials(Materials.Ground);
    });

    events.listen('player-floor_offBottom', function(_){
      onGround = false;
      body.setShapeMaterials(Materials.Air);
    });

    /*var anim_object = Luxe.resources.json('assets/jsons/player_animation.json');

    anim = add( new SpriteAnimation({ name:'anim' }) );
    anim.add_from_json_object( anim_object.asset.json );*/

    //Game.drawer.add(body);

    Luxe.physics.nape.space.listeners.add(new PreListener(
      InteractionType.COLLISION,
      Main.types.Player,
      Main.types.Enemy,
      player_collisions,
      /*precedence*/ 1,
      /*pure*/ true
    ));

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

    if(Luxe.input.inputdown('up') && onGround) {

      body.velocity.y = -(walkForce + 50);
      moving = true;

    }

    pos.x = body.position.x;
    pos.y = body.position.y;

    pos = pos.int();

    Main.pressingGamepadLeft = false;
    Main.pressingGamepadRight = false;
    Main.pressingGamepadUp = false;
    Main.pressingGamepadDown = false;

  }

}
