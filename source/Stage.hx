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
    "stage",
    "hillzoneTails",
    "hillzoneTailsSwag",
    "hillzoneSonic",
    "hillzoneShadow",
    "highzoneShadow",
    "hillzoneDarkSonic",
  ];

  public var doDistractions:Bool = true;

  // spooky bg
  public var halloweenBG:FlxSprite;
  var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;


  // philly bg
  public var lightFadeShader:BuildingEffect;
  public var phillyCityLights:FlxTypedGroup<FlxSprite>;
  public var phillyTrain:FlxSprite;
  public var trainSound:FlxSound;
  public var curLight:Int = 0;

  public var trainMoving:Bool = false;
	public var trainFrameTiming:Float = 0;

	public var trainCars:Int = 8;
	public var trainFinishing:Bool = false;
	public var trainCooldown:Int = 0;

  // limo bg
  public var fastCar:FlxSprite;
  public var limo:FlxSprite;
  var fastCarCanDrive:Bool=true;

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

  function lightningStrikeShit():Void
  {
    FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
    halloweenBG.animation.play('lightning');

    lightningOffset = FlxG.random.int(8, 24);

    boyfriend.playAnim('scared', true);
    gf.playAnim('scared', true);
  }

  function resetFastCar():Void
  {
    fastCar.x = -12600;
    fastCar.y = FlxG.random.int(140, 250);
    fastCar.velocity.x = 0;
    fastCarCanDrive = true;
  }

  function fastCarDrive()
  {
    FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

    fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
    fastCarCanDrive = false;
    new FlxTimer().start(2, function(tmr:FlxTimer)
    {
      resetFastCar();
    });
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

  public function new(stage:String,currentOptions:Options){
    super();
    if(stage=='halloween')stage='spooky'; // for kade engine shenanigans
    curStage=stage;
    this.currentOptions=currentOptions;

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
        defaultCamZoom = 1;
        bfPosition.x += 265;
        bfPosition.y -= 50;
        //dadPosition.x -= 100;
        dadPosition.x -= 125;
        dadPosition.y -= 50;

        gfPosition.y -= 75;
        curStage = 'hillzoneShadow';
        var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('shadowbg','chapter3'));
        bg.antialiasing = true;
        bg.scrollFactor.set(1.05, 1.05);
        bg.active = false;
        bg.screenCenter();
        bg.offset.set(-150,100);
        add(bg);

        var thisthing:FlxSprite = new FlxSprite().loadGraphic(Paths.image('shadowbg3','chapter3'));
        thisthing.antialiasing = true;
        thisthing.scrollFactor.set(1.025, 1.025);
        thisthing.active = false;
        thisthing.screenCenter();
        thisthing.offset.set(-150,100);
        add(thisthing);

        var thisotherthing:FlxSprite = new FlxSprite().loadGraphic(Paths.image('shadowbg2','chapter3'));
        thisotherthing.antialiasing = true;
        thisotherthing.scrollFactor.set(1.025, 1.025);
        thisotherthing.active = false;
        thisotherthing.screenCenter();
        thisotherthing.offset.set(-150,100);
        add(thisotherthing);

        var grass:FlxSprite = new FlxSprite().loadGraphic(Paths.image('shadowbg4','chapter3'));
        grass.antialiasing = true;
        grass.active = false;
        grass.screenCenter();
        grass.offset.set(-150,100);
        add(grass);

        centerX = bg.getMidpoint().x;
        centerY = bg.getMidpoint().y;
      case 'highzoneShadow':
        bfPosition.x += 325;
        dadPosition.x -= 0;
        defaultCamZoom = 1;
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

        centerX = bg.getMidpoint().x;
        centerY = bg.getMidpoint().y;


      case 'hillzoneDarkSonic':
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

    if(doDistractions){

      switch(curStage){
        case 'limo':
          if (FlxG.random.bool(10) && fastCarCanDrive)
            fastCarDrive();
        case 'spooky':
          if (FlxG.random.bool(10) && beat > lightningStrikeBeat + lightningOffset)
          {
            lightningStrikeBeat = beat;
            lightningStrikeShit();
          }
        case 'philly':
          if (!trainMoving)
            trainCooldown += 1;

          if (beat%4== 0)
          {
            phillyCityLights.forEach(function(light:FlxSprite)
            {
              light.visible = false;
            });

            curLight = FlxG.random.int(0, phillyCityLights.length - 1);

            phillyCityLights.members[curLight].visible = true;
            phillyCityLights.members[curLight].alpha = 1;
            lightFadeShader.setAlpha(0);
          }

          if (beat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
          {
            trainCooldown = FlxG.random.int(-4, 0);
            trainStart();
          }
      }
    }
  }

  override function update(elapsed:Float){
    switch(curStage){
      case 'philly':
        if (trainMoving)
        {
          trainFrameTiming += elapsed;

          if (trainFrameTiming >= 1 / 24)
          {
            updateTrainPos();
            trainFrameTiming = 0;
          }
        }
        lightFadeShader.addAlpha((Conductor.crochet / 1000) * FlxG.elapsed * 1.5);
    }


    super.update(elapsed);
  }

  function trainStart():Void
  {
    trainMoving = true;
    trainSound.play(true,0);
  }

  var startedMoving:Bool = false;

  function updateTrainPos():Void
  {
    if (trainSound.time >= 4700)
    {
      startedMoving = true;
      gf.playAnim('hairBlow');
    }

    if (startedMoving)
    {
      if(currentOptions.picoCamshake)
        PlayState.currentPState.camGame.shake(.0025,.1,null,true,X);

      phillyTrain.x -= 400;

      if (phillyTrain.x < -2000 && !trainFinishing)
      {
        phillyTrain.x = -1150;
        trainCars -= 1;

        if (trainCars <= 0)
          trainFinishing = true;
      }

      if (phillyTrain.x < -4000 && trainFinishing)
        trainReset();
    }
  }

  function trainReset():Void
  {
    gf.playAnim('hairFall');
    phillyTrain.x = FlxG.width + 200;
    trainMoving = false;
    // trainSound.stop();
    // trainSound.time = 0;
    trainCars = 8;
    trainFinishing = false;
    startedMoving = false;
  }

}
