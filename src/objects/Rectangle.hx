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


class Rectangle extends Sprite {

  public var body : Body;
  public var physics : BodySetup;
  /*public var anim : SpriteAnimation;*/
  public var moving : Bool;
  public var canMove: Bool;
  public var core : Shape;
  public var walkForce : Float = 150;
  public var invincible : Bool = false;
  public var onGround : Bool = false;

  public var shape_name : String = 'rectangle';

  var blinker : Blinker;

  public function new (){

    super({
      pos: new Vector(0, 0),
      texture: Luxe.resources.texture('assets/images/rectangle.png'),
      name: 'rectangle',
      name_unique: true,
      depth: 3.4,
      size: new Vector(8, 8)
    });

    canMove = true;

    physics = add(new BodySetup({
      bodyType: BodyType.KINEMATIC,
      types: [Main.types.Rectangle, Main.types.Movable],
      polygon: Polygon.box(8, 8),
      isBullet: true
    }));

    body = physics.body;
    core = physics.core;

    blinker = add( new Blinker({name: 'blinker'}) );

    body.userData.name = 'rectangle';
    core.userData.name = 'rectangle';

    /*var anim_object = Luxe.resources.json('assets/jsons/player_animation.json');

    anim = add( new SpriteAnimation({ name:'anim' }) );
    anim.add_from_json_object( anim_object.asset.json );*/

    //Game.drawer.add(body);

  }

  public function spawn(level : Level){

    var x = Luxe.utils.random.int(0, level.width - 1);
    var y = Luxe.utils.random.int(0, level.height - 1);

    var tile = level.tiledmap_data.layers[level.collision_layer_id].tiles[y * level.tiledmap_data.width + x];

    if(tile != null){
      if(tile.id == 0){
        body.position.x = (x * 8) + 4;
        body.position.y = (y * 8) + 4;
      }
    }

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
