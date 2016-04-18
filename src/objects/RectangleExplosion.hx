package objects;

import states.Game;

import luxe.Vector;
import luxe.components.sprite.SpriteAnimation;

class RectangleExplosion extends engine.Sprite {

  var anim : SpriteAnimation;

  public function new (){

    super({
      name: 'rectangle_explosion',
      name_unique: true,
      size: new Vector(32, 32),
      depth: 5,
      texture: Luxe.resources.texture('assets/images/rectangle_explosion.png')
    });

    visible = false;

    var anim_object = Luxe.resources.json('assets/jsons/animation.json');

    anim = add( new SpriteAnimation({ name:'anim' }) );
    anim.add_from_json_object( anim_object.asset.json );

    events.listen('animation.rectangle_explosion.end', function(_){

      free();

    });

  }

  public function set_alive(x, y){

    pos.x = x;
    pos.y = y;

    visible = true;
    active = true;

    anim.animation = 'rectangle_explosion';
    anim.play();

  }

  public function free(){

    if( Game.rectangle_explosion_emitter.busy.remove(this) ){
      Game.rectangle_explosion_emitter.free.add(this);
      visible = false;
      active = false;
    };

  }

}