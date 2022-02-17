package;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxTimer;
import flixel.util.FlxDestroyUtil;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.FlxObject;
import flixel.FlxBasic;
import states.*;

import Shaders;

class Stage extends FlxTypedGroup<FlxBasic> {
  public static var songStageMap:Map<String,String> = [
    "tutorial" => "hillzoneTails",
    "talentless-fox" => "hillzoneTails",
    "tsuraran-fox" => "hillzoneTailsSwag",
    "no-villains" => "hillzoneSonic",
    "no-bitches" => "hillzoneSonic",
    "die-batsards" => "hillzoneShadow",
    "high-shovel" => "highzoneShadow",
    "taste-for-blood" => "hillzoneDarkSonic",
  ];

  public static var stageNames:Array<String> = [
    "hillzoneTails",
    "hillzoneTailsSwag",
    "hillzoneSonic",
    "hillzoneShadow",
    "highzoneShadow",
    "hillzoneDarkSonic",
  ];

  public var doDistractions:Bool = true;

  // shadow bg
  public var knuckles:FlxSprite;
  public var tails:FlxSprite;

  // misc, general bg stuff

  public var bfPosition:FlxPoint = FlxPoint.get(770,450);
  public var dadPosition:FlxPoint = FlxPoint.get(100,100);
  public var gfPosition:FlxPoint = FlxPoint.get(400,130);
  public var camPos:FlxPoint = FlxPoint.get(100,100);
  public var camOffset:FlxPoint = FlxPoint.get(100,100);

  public var layers:Map<String,FlxTypedGroup<FlxBasic>> = [
    "boyfriend"=>new FlxTypedGroup<FlxBasic>(), // stuff that should be layered infront of all characters, but below the foreground
    "dad"=>new FlxTypedGroup<FlxBasic>(), // stuff that should be layered infront of the dad and gf but below boyfriend and foreground
    "gf"=>new FlxTypedGroup<FlxBasic>(), // stuff that should be layered infront of the gf but below the other characters and foreground
  ];
  public var foreground:FlxTypedGroup<FlxBasic> = new FlxTypedGroup<FlxBasic>(); // stuff layered above every other layer
  public var overlay:FlxSpriteGroup = new FlxSpriteGroup(); // stuff that goes into the HUD camera. Layered before UI elements, still

  public var boppers:Array<Array<Dynamic>> = []; // should contain [sprite, bopAnimName, whichBeats]
  public var dancers:Array<Dynamic> = []; // Calls the 'dance' function on everything in this array every beat

  public var defaultCamZoom:Float = 1.05;

  public var curStage:String = '';

  // other vars
  public var gfVersion:String = 'gf';
  public var gf:Character;
  public var boyfriend:Character;
  public var dad:Character;
  public var currentOptions:Options;
  public var centerX:Float = -1;
  public var centerY:Float = -1;

  override public function destroy(){
    bfPosition = FlxDestroyUtil.put(bfPosition);
    dadPosition = FlxDestroyUtil.put(dadPosition);
    gfPosition = FlxDestroyUtil.put(gfPosition);
    camOffset =  FlxDestroyUtil.put(camOffset);

    super.destroy();
  }


  public function setPlayerPositions(?p1:Character,?p2:Character,?gf:Character){

    if(p1!=null)p1.setPosition(bfPosition.x,bfPosition.y);
    if(gf!=null)gf.setPosition(gfPosition.x,gfPosition.y);
    if(p2!=null){
      p2.setPosition(dadPosition.x,dadPosition.y);
      camPos.set(p2.getGraphicMidpoint().x, p2.getGraphicMidpoint().y);
    }

    if(p1!=null){
      switch(p1.curCharacter){

      }
    }

    if(p2!=null){

      switch(p2.curCharacter){
        case 'gf':
          if(gf!=null){
            p2.setPosition(gf.x, gf.y);
            gf.visible = false;
          }
        case 'dad':
          camPos.x += 400;
        case 'pico':
          camPos.x += 600;
        case 'senpai' | 'senpai-angry':
          camPos.set(p2.getGraphicMidpoint().x + 300, p2.getGraphicMidpoint().y);
        case 'spirit':
          camPos.set(p2.getGraphicMidpoint().x + 300, p2.getGraphicMidpoint().y);
        case 'bf-pixel':
          camPos.set(p2.getGraphicMidpoint().x, p2.getGraphicMidpoint().y);
      }
    }

    if(p1!=null){
      p1.x += p1.posOffset.x;
      p1.y += p1.posOffset.y;
    }
    if(p2!=null){
      p2.x += p2.posOffset.x;
      p2.y += p2.posOffset.y;
    }


  }

  public function new(stage:String,currentOptions:Options, distractions:Bool=true){
    super();
    if(stage=='halloween')stage='spooky'; // for kade engine shenanigans
    curStage=stage;
    this.currentOptions=currentOptions;
    doDistractions = distractions;
    overlay.scrollFactor.set(0,0); // so the "overlay" layer stays static

    switch (stage){
      case 'hillzoneTails':
        defaultCamZoom = 1;
        curStage = 'hillzoneTails';
        var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('sky','chapter1'));
        bg.antialiasing = true;
        bg.scrollFactor.set(0.4, 0.4);
        bg.active = false;
        add(bg);

        var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('grass','chapter1'));
        stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
        stageFront.updateHitbox();
        stageFront.antialiasing = true;
        stageFront.scrollFactor.set(0.9, 0.9);
        stageFront.active = false;
        add(stageFront);

        var stageCurtains:FlxSprite = new FlxSprite(-450, -150).loadGraphic(Paths.image('foreground','chapter1'));
        stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.87));
        stageCurtains.updateHitbox();
        stageCurtains.antialiasing = true;
        stageCurtains.scrollFactor.set(1.3, 1.3);
        stageCurtains.active = false;

        centerX = bg.getMidpoint().x;
        centerY = bg.getMidpoint().y;

        foreground.add(stageCurtains);
      case 'hillzoneTailsSwag':
        defaultCamZoom = 1;
        curStage = 'hillzoneTailsSwag';
        var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('skySwag','chapter1'));
        bg.antialiasing = true;
        bg.scrollFactor.set(0.4, 0.4);
        bg.active = false;
        add(bg);

        var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('grassSwag','chapter1'));
        stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
        stageFront.updateHitbox();
        stageFront.antialiasing = true;
        stageFront.scrollFactor.set(0.9, 0.9);
        stageFront.active = false;
        add(stageFront);

        var stageCurtains:FlxSprite = new FlxSprite(-450, -150).loadGraphic(Paths.image('foregroundSwag','chapter1'));
        stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.87));
        stageCurtains.updateHitbox();
        stageCurtains.antialiasing = true;
        stageCurtains.scrollFactor.set(1.3, 1.3);
        stageCurtains.active = false;

        centerX = bg.getMidpoint().x;
        centerY = bg.getMidpoint().y;

        foreground.add(stageCurtains);
      case 'hillzoneSonic':
        defaultCamZoom = 1;
        curStage = 'hillzoneSonic';
        var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('sky','chapter2'));
        bg.antialiasing = true;
        bg.scrollFactor.set(0.4, 0.4);
        bg.active = false;
        add(bg);

        var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('grass','chapter2'));
        stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
        stageFront.updateHitbox();
        stageFront.antialiasing = true;
        stageFront.scrollFactor.set(0.9, 0.9);
        stageFront.active = false;
        add(stageFront);

        var stageCurtains:FlxSprite = new FlxSprite(-450, -150).loadGraphic(Paths.image('foreground','chapter2'));
        stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.87));
        stageCurtains.updateHitbox();
        stageCurtains.antialiasing = true;
        stageCurtains.scrollFactor.set(1.3, 1.3);
        stageCurtains.active = false;

        centerX = bg.getMidpoint().x;
        centerY = bg.getMidpoint().y;

        foreground.add(stageCurtains);
      case 'hillzoneShadow':
        defaultCamZoom = .9;
        bfPosition.x = 1029;
        bfPosition.y = 384;

        //dadPosition.x -= 100;
        dadPosition.x = -125;
        dadPosition.y = -10;

        gfPosition.x = 305;
        gfPosition.y = 10;
        gfVersion = 'gfbest';
        curStage = 'hillzoneShadow';
        var bg:FlxSprite = new FlxSprite(-835,-550).loadGraphic(Paths.image('shadowbg','chapter3'));
        bg.antialiasing = true;
        bg.scrollFactor.set(1.05, 1.05);
        bg.active = false;
        add(bg);

        var thisthing:FlxSprite = new FlxSprite(-880,-730).loadGraphic(Paths.image('shadowbg3','chapter3'));
        thisthing.antialiasing = true;
        thisthing.scrollFactor.set(1.025, 1.025);
        thisthing.active = false;
        add(thisthing);

        var thisotherthing:FlxSprite = new FlxSprite(-815,-375).loadGraphic(Paths.image('shadowbg2','chapter3'));
        thisotherthing.antialiasing = true;
        thisotherthing.scrollFactor.set(1.025, 1.025);
        thisotherthing.active = false;
        add(thisotherthing);

        var grass:FlxSprite = new FlxSprite(-815,450).loadGraphic(Paths.image('shadowbg4','chapter3'));
        grass.antialiasing = true;
        grass.active = false;
        add(grass);

        centerX = 900;
        centerY = 300;

        if(doDistractions){
          tails = new FlxSprite();
          tails.frames = Paths.getSparrowAtlas('tails','chapter3');
          tails.animation.addByPrefix("idle","IDLET",24,false);
          tails.animation.addByPrefix("shoot","SHOOTT",24,false);
          tails.animation.addByPrefix("shootKill","SHOOTSCARET",24,false);
          tails.animation.play("idle",true);
          tails.antialiasing=true;
          tails.x = 200;
          tails.y = 60;
          add(tails);

          knuckles = new FlxSprite();
          knuckles.frames = Paths.getSparrowAtlas('knuckles','chapter3');
          knuckles.animation.addByPrefix("idle","IDLEK",24,false);
          knuckles.animation.addByPrefix("shoot","SHOOTK",24,false);
          knuckles.animation.addByPrefix("shootKill","SHOOTSCAREK",24,false);
          knuckles.animation.play("idle",true);
          knuckles.antialiasing=true;
          knuckles.x = 770;
          knuckles.y = 80;
          layers.get("gf").add(knuckles);

          /*tailsShocked = new FlxSprite();
          tailsShocked.frames = Paths.getSparrowAtlas('scared','chapter3');
          tailsShocked.animation.addByPrefix("shock","scared mark",6,false);
          tailsShocked.animation.play("shock",true);
          tailsShocked.x = 773;
          tailsShocked.y = 5;
          add(tailsShocked);

          knuxShocked = new FlxSprite();
          knuxShocked.frames = Paths.getSparrowAtlas('scared','chapter3');
          knuxShocked.animation.addByPrefix("shock","scared mark",6,false);
          knuxShocked.animation.play("shock",true);
          knuxShocked.x = 300;
          knuxShocked.y = -35;
          add(knuxShocked);*/

        }

      case 'highzoneShadow':
        gfVersion = 'gfbest';
        bfPosition.x += 325;
        dadPosition.x -= 0;
        defaultCamZoom = .9;
        curStage = 'highzoneShadow';
        var bg:FlxSprite = new FlxSprite(-350, -200).loadGraphic(Paths.image('stageback_HS','chapter3'));
        bg.antialiasing = true;
        bg.scrollFactor.set(0.4, 0.4);
        bg.active = false;
        add(bg);

        var stageFront:FlxSprite = new FlxSprite(-725, 600).loadGraphic(Paths.image('stagefront_HS','chapter3'));
        stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
        stageFront.updateHitbox();
        stageFront.antialiasing = true;
        stageFront.scrollFactor.set(1, 1);
        stageFront.active = false;
        add(stageFront);

        centerX = 600;
        centerY = 500;


      case 'hillzoneDarkSonic':
        gfVersion = 'gfbest';
        defaultCamZoom = 1;
        bfPosition.x += 100;
        var sky:FlxSprite = new FlxSprite().loadGraphic(Paths.image("tfbbg3","chapter3"));
        sky.antialiasing=true;
        sky.scrollFactor.set(.3,.3);
        sky.x = -458;
        sky.y = -247;
        add(sky);

        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("tfbbg2","chapter3"));
        bg.antialiasing=true;
        bg.scrollFactor.set(.7,.7);
        bg.x = -480.5;
        bg.y = 410;
        add(bg);

        var fg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("tfbbg","chapter3"));
        fg.antialiasing=true;
        fg.scrollFactor.set(1, 1);
        fg.x = -541;
        fg.y = -96.5;
        add(fg);

        centerX = 400;
        centerY = 500;

      case 'blank':
        centerX = 400;
        centerY = 130;
      default:
        defaultCamZoom = 1;
        curStage = 'stage';
        var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback','shared'));
        bg.antialiasing = true;
        bg.scrollFactor.set(0.9, 0.9);
        bg.active = false;
        add(bg);

        var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront','shared'));
        stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
        stageFront.updateHitbox();
        stageFront.antialiasing = true;
        stageFront.scrollFactor.set(0.9, 0.9);
        stageFront.active = false;
        add(stageFront);

        var stageCurtains:FlxSprite = new FlxSprite(-450, -150).loadGraphic(Paths.image('stagecurtains','shared'));
        stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.87));
        stageCurtains.updateHitbox();
        stageCurtains.antialiasing = true;
        stageCurtains.scrollFactor.set(1.3, 1.3);
        stageCurtains.active = false;

        centerX = bg.getMidpoint().x;
        centerY = bg.getMidpoint().y;

        foreground.add(stageCurtains);
      }
  }


  public function beatHit(beat){
    for(b in boppers){
      if(beat%b[2]==0){
        b[0].animation.play(b[1],true);
      }
    }
    for(d in dancers){
      d.dance();
    }

    switch(curStage){
      case 'hillzoneShadow':
      if(doDistractions){
        if(beat%2==0){
          if(knuckles.animation.curAnim.name!='shootKill')
            if(knuckles.animation.curAnim.name=='idle' || knuckles.animation.curAnim.finished)
              knuckles.animation.play('idle',true);

          if(tails.animation.curAnim.name!='shootKill')
            if(tails.animation.curAnim.name=='idle' || tails.animation.curAnim.finished)
              tails.animation.play('idle',true);

        }
      }
    }

  }

  override function update(elapsed:Float){


    super.update(elapsed);
  }


}
