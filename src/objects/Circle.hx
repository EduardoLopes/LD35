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

import nape.callbacks.CbEvent;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;

import nape.callbacks.CbType;

import nape.callbacks.PreCallback;
import nape.callbacks.PreFlag;
import nape.callbacks.PreListener;
import nape.callbacks.InteractionType;
import nape.shape.Shape;

import states.Game;

import luxe.importers.tiled.TiledObjectGroup;

import objects.states.StateMachine;

import components.BodySetup;
import components.TouchingChecker;
import nape.callbacks.CbType;

import components.Blinker;


class Circle extends Sprite {

  public var body : Body;
  public var physics : BodySetup;
  /*public var anim : SpriteAnimation;*/
  public var moving : Bool;
  public var canMove: Bool;
  public var core : Shape;
  public var walkForce : Float = 150;
  public var invincible : Bool = false;
  public var onGround : Bool = false;

  public var shape_name : String = 'circle';

  var blinker : Blinker;

  var type : CbType;

  var collected : Bool = false;

  public function new (){

    super({
      pos: new Vector(0, 0),
      texture: Luxe.resources.texture('assets/images/circle.png'),
      name: 'circle',
      name_unique: true,
      depth: 3.4,
      size: new Vector(8, 8)
    });

    canMove = true;

    type = new CbType();

    physics = add(new BodySetup({
      bodyType: BodyType.KINEMATIC,
      types: [Main.types.Circle, type],
      shapeType: BodyShape.Circle,
      radius: 4,
      isBullet: false,
    }));

    body = physics.body;
    core = physics.core;

    core.sensorEnabled = true;

    blinker = add( new Blinker({name: 'blinker'}) );

    body.userData.name = 'circle';
    core.userData.name = 'circle';

    var interactionListener_ongoing = new InteractionListener(
      CbEvent.ONGOING, InteractionType.SENSOR,
      Main.types.Player,
      type,
      function (cb:InteractionCallback){

        kill();
        collected = true;

      }
    );

    Luxe.physics.nape.space.listeners.add(interactionListener_ongoing);

    /*var anim_object = Luxe.resources.json('assets/jsons/player_animation.json');

    anim = add( new SpriteAnimation({ name:'anim' }) );
    anim.add_from_json_object( anim_object.asset.json );*/

    //Game.drawer.add(body);

  }

  public function kill(){

    get('blinker').cancel();

    collected = false;
    visible = false;
    active = false;

    /*Game.drawer.remove(body);*/

    body.space = null;

    Game.circle_emitter.busy.remove(this);
    Game.circle_emitter.free.add(this);

  }

  public function spawn(x : Int, y : Int){

    collected = false;
    visible = true;
    active = true;

    body.space = Luxe.physics.nape.space;

    body.position.x = x;
    body.position.y = y;

  }

  override public function ondestroy(){

    super.ondestroy();

    //Game.drawer.remove(body);

  }

  override function update(dt:Float) {

    super.update(dt);

    pos.x = body.position.x;
    pos.y = body.position.y;

    pos = pos.int();

  }

}
