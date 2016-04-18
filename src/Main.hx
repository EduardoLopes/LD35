
import luxe.Input;
import luxe.Camera;
import luxe.Color;
import luxe.Vector;
import luxe.Screen;
import luxe.States;

import phoenix.Texture;

import luxe.Parcel;
import luxe.ParcelProgress;

import nape.geom.Vec2;

import states.Game;

class Main extends luxe.Game {

  public static var zoom : Int = 2;
  public static var pressingGamepadLeft : Bool;
  public static var pressingGamepadRight : Bool;
  public static var pressingGamepadUp : Bool;
  public static var pressingGamepadDown : Bool;
  public static var gameResolution : Vector;
  public static var zoomRatio : Vector;
  public static var backgroundBatcher : phoenix.Batcher;
  public static var foregroundBatcher : phoenix.Batcher;
  public static var backgroundBatcherCamera : Camera;
  public static var foregroundBatcherCamera : Camera;
  public static var state: States;
  public static var types : Types;
  public static var materials : Materials;

  override function config(config:luxe.AppConfig) {

    gameResolution = new Vector(config.window.width, config.window.height);

    config.window.width = config.window.width * zoom;
    config.window.height = config.window.height * zoom;

    config.runtime.prevent_default_keys.push(Key.space);

    return config;

  } //config

  override function ready() {

    var parcel = new Parcel({
      fonts : [
        { id:'assets/fonts/font.fnt' },
      ],
      jsons : [
        {id : 'assets/jsons/animation.json'},
      ],
      texts : [
        {id : 'assets/maps/map-1.tmx'},
      ],
      textures : [
        {id : 'assets/images/collision-tile.png'},
        {id : 'assets/images/tileset.png'},
        {id : 'assets/images/player.png'},
        {id : 'assets/images/rectangle.png'},
        {id : 'assets/images/circle.png'},
        {id : 'assets/images/rectangle_change.png'},
        {id : 'assets/images/circle_change.png'},
        {id : 'assets/images/rectangle_explosion.png'},
        {id : 'assets/images/circle_explosion.png'}
      ],
      sounds : []
    });

    phoenix.Texture.default_filter = FilterType.nearest;

    new ParcelProgress({
      parcel      : parcel,
      background  : new Color(1,1,1,0.85),
      oncomplete  : onLoaded
    });

    zoomRatio = new Vector(Luxe.screen.w / gameResolution.x, Luxe.screen.h / gameResolution.y);

    backgroundBatcherCamera = new Camera({
      name: 'background_camera'
    });

    foregroundBatcherCamera = new Camera({
      name: 'foreground_camera'
    });

    backgroundBatcher = Luxe.renderer.create_batcher({
      layer: -1,
      name:'background_batcher',
      camera: backgroundBatcherCamera.view
    });

    foregroundBatcher = Luxe.renderer.create_batcher({
      layer: 3,
      name:'foreground_batcher',
      camera: foregroundBatcherCamera.view
    });

    types = new Types();
    materials = new Materials();

    parcel.load();

  } //ready

  function onLoaded(_){

    state = new States({ name:'state' });
    state.add( new Game() );

    state.set('game');

    update_camera_scale();

  }

  override function ongamepadaxis( event:GamepadEvent ) {

    var dead = 0.21;

    if((event.value > dead && (event.value > 0 && event.value <= 1 )) || (event.value < -dead && (event.value < 0 && event.value <= 1)) ) {

      if(event.axis == 0) {

        pressingGamepadLeft = false;
        pressingGamepadRight = false;

        if(event.value < 0) pressingGamepadLeft = true;
        if(event.value > 0) pressingGamepadRight = true;

      }

      if(event.axis == 1){

        pressingGamepadUp = false;
        pressingGamepadDown = false;

        if(event.value < 0) pressingGamepadUp = true;
        if(event.value > 0) pressingGamepadDown = true;

      }

    } else {

      if(event.axis == 0) {
        pressingGamepadLeft = false;
        pressingGamepadRight = false;
      }

      if(event.axis == 1) {
        pressingGamepadUp = false;
        pressingGamepadDown = false;
      }

    }

  }

  function update_camera_scale(){

    zoomRatio.x = Math.floor(Luxe.screen.w / gameResolution.x);
    zoomRatio.y = Math.floor(Luxe.screen.h / gameResolution.y);

    zoom = Math.floor(Math.max(1, Math.min(zoomRatio.x, zoomRatio.y)));

    var width = gameResolution.x * zoom;
    var height = gameResolution.y * zoom;
    var x = (Luxe.screen.w / 2) - (width / 2);
    var y = (Luxe.screen.h / 2) - (height / 2);

    #if web
    Luxe.camera.zoom = zoom;
    backgroundBatcherCamera.zoom = zoom;
    foregroundBatcherCamera.zoom = zoom;
    #end

    Luxe.camera.viewport.set(x, y, width, height);
    backgroundBatcherCamera.viewport.set(x, y, width, height);
    foregroundBatcherCamera.viewport.set(x, y, width, height);

    var _zoom:Float = Math.max(0, zoom - 1);

    Luxe.camera.pos.x = -((Main.gameResolution.x * _zoom) / 2);
    Luxe.camera.pos.y = -((Main.gameResolution.y * _zoom) / 2);

  }

  override function onwindowsized( e:WindowEvent ):Void {

    update_camera_scale();

  }

  override function onkeyup( e:KeyEvent ) {

    if(e.keycode == Key.escape) {
      Luxe.shutdown();
    }

  } //onkeyup

  override function update(dt:Float) {

  } //update


} //Main
