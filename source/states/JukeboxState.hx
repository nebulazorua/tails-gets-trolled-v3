package states;

#if desktop
import Discord.DiscordClient;
#end
import math.*;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxState;
import flixel.util.FlxColor;
import io.newgrounds.NG;
import lime.app.Application;
import haxe.Exception;
using StringTools;
import flixel.util.FlxTimer;
import Options;
import flixel.input.mouse.FlxMouseEventManager;
import flash.events.MouseEvent;
import ui.*;
import flixel.math.FlxAngle;
import flixel.math.FlxPoint;
import flixel.math.FlxMath;
import flixel.util.FlxSort;
import flixel.addons.display.FlxBackdrop;
import flixel.math.FlxRect;

typedef SongInfo = {
  var displayName: String;
  var path: String;
  var inst: String;
  var bpm:Float;
}

class JukeboxState extends MusicBeatState {
  var backdrops:FlxBackdrop;
  var fart:FlxSprite;
  var selection:Int = 0;
  public static var playing:Int = 0;
  var instOn:Bool=false;
  var texts:FlxTypedSpriteGroup<FlxText>;
  var topBounds:Int = 75;
  var fading:Bool=false;
  var instButton:FlxSprite;
  var bottomBounds:Int = 650;
  public static var songData:Array<SongInfo> = [
    {displayName: "Main Menu", path: Paths.music("freakyMenu"), inst: Paths.music("freakyMenu"), bpm: 180},
    {displayName: "Talentless Fox", inst: Paths.inst("talentless-fox"), path: Paths.music("talentlessFoxJukebox"), bpm: 140},
    {displayName: "No Villains", inst: Paths.inst("no-villains"), path: Paths.music("noVillainsJukebox"), bpm: 200},
    {displayName: "Die Batsards", inst: Paths.inst("die-batsards"), path: Paths.music("dieBatsardsJukebox"), bpm: 180},
    {displayName: "High Shovel", inst: Paths.inst("high-shovel"), path: Paths.music("highShovelJukebox"), bpm: 152},
    {displayName: "Taste For Blood", inst: Paths.inst("taste-for-blood"), path: Paths.music("tfbJukebox"), bpm: 200},
    {displayName: "Tsuraran Fox", inst: Paths.inst("tsuraran-fox"), path: Paths.music("tsufoxJukebox"), bpm: 140},
    {displayName: "No Heroes", inst: Paths.inst("no-heroes"), path: Paths.music("noHeroesJukebox"), bpm: 200},
    {displayName: "No Bitches P", inst: Paths.inst("no-bitches-penkaru"), path: Paths.music("penkaruJukebox"), bpm: 200},
    {displayName: "No Bitches M", inst: Paths.inst("no-bitches-matasaki"), path: Paths.music("matasakiJukebox"), bpm: 200},
    {displayName: "Groovy Fox", inst: Paths.inst("groovy-fox"), path: Paths.music("groovyfoxJukebox"), bpm: 125},
  ];

  function onMouseDown(object:FlxObject){
    if(object==instButton){
      instOn = !instOn;
      if(instOn)
        instButton.animation.play('on');
      else
        instButton.animation.play('off');

        Conductor.changeBPM(songData[playing].bpm);
        var path = songData[playing].path;
        var time = FlxG.sound.music.time;
        OptionUtils.options.isInst = instOn;
        OptionUtils.saveOptions(OptionUtils.options);
        if(instOn)
          path = songData[playing].inst;

        FlxG.sound.playMusic(CoolUtil.getSound(path));
        FlxG.sound.music.time = time;
    }else{
        var txt:FlxText = cast object;
        if(texts.members.contains(txt)){
          if(!fading)
            play(txt.ID);
        }
      }
	}

	function onMouseUp(object:FlxObject){
	}

	function onMouseOver(object:FlxObject){
    var txt:FlxText = cast object;
    if(texts.members.contains(txt)){
      changeSelection(txt.ID);
    }
	}

	function onMouseOut(object:FlxObject){

	}


	function scroll(event:MouseEvent){
		changeSelection(selection-event.delta);
	}

  inline function lerp(a:Float,b:Float,c:Float){
    return a+(b-a)*c;
  }

  var rect:FlxRect;

  override function create()
  {
    super.create();
    #if desktop
    // Updating Discord Rich Presence
    DiscordClient.changePresence("Looking at the jukebox", null);
    #end
    playing = OptionUtils.options.jukeboxSong;
    instOn = OptionUtils.options.isInst;
    texts = new FlxTypedSpriteGroup<FlxText>();

    var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('jukebox/gradient'));
    bg.scrollFactor.set();
    bg.setGraphicSize(Std.int(bg.width * 1.1));
    bg.updateHitbox();
    bg.screenCenter();
    bg.antialiasing = true;
    add(bg);

    backdrops = new FlxBackdrop(Paths.image('jukebox/grid'), 0.2, 0.2, true, true);
    backdrops.alpha = 0.15;
    backdrops.x -= 10;
    add(backdrops);

    fart = new FlxSprite(483).loadGraphic(Paths.image('jukebox/art'));
    fart.scrollFactor.set();
    fart.updateHitbox();
    fart.origin.x += 50;
    fart.x -= 50;
    fart.antialiasing = true;
    add(fart);

    var box = new FlxSprite().loadGraphic(Paths.image('jukebox/box'));
    box.scrollFactor.set();
    box.screenCenter();
    box.antialiasing=true;
    add(box);

    instButton = new FlxSprite();
    instButton.frames = Paths.getSparrowAtlas('jukebox/instbutton');
    instButton.animation.addByPrefix('on','on',0);
    instButton.animation.addByPrefix('off','off',0);
    if(instOn)
      instButton.animation.play('on');
    else
      instButton.animation.play('off');

    instButton.updateHitbox();
    instButton.x = 47;
    instButton.y = 315;
    instButton.scrollFactor.set();
    instButton.antialiasing=true;
    FlxMouseEventManager.add(instButton,onMouseDown,onMouseUp,onMouseOver,onMouseOut);
    add(instButton);


    add(texts);

    rect = new FlxRect(0,0,box.width,box.height);

    for(idx in 0...songData.length){
      var data = songData[idx];
      var name = data.displayName;

      var text = new FlxText(445, 126 + (36 * idx), 0, name, 24);
      text.setFormat(Paths.font("arial.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.TRANSPARENT);
      text.ID=idx;
      FlxMouseEventManager.add(text,onMouseDown,onMouseUp,onMouseOver,onMouseOut,false,true,false);
      texts.add(text);
    }

    updateSelection();
    FlxG.stage.addEventListener(MouseEvent.MOUSE_WHEEL,scroll);

  }

  var timer:Float = 0;
  var scaleTimer:Float = 1;
  override function beatHit(){
    scaleTimer = 0;
    fart.scale.set(1.2,1.2);
  }

  function updateSelection(){
    for(text in texts.members){
      if(text.ID==selection){
        text.borderColor = FlxColor.YELLOW;
        text.color = FlxColor.YELLOW;
      }else{
        text.color = FlxColor.WHITE;
        text.borderColor = FlxColor.TRANSPARENT;
      }
    }
  }

  function changeSelection(newSelect:Int){
    if(selection==newSelect)return;
    FlxG.sound.play(Paths.sound('scrollMenu'));
    selection=newSelect;
    if(selection>songData.length-1){
      selection=0;
    }
    if(selection<0){
      selection=songData.length-1;
    }
    updateSelection();
  }

  function play(play:Int){
    playing = play;
    fading=true;
    FlxG.sound.music.fadeOut(.5, 0, function(twn:FlxTween){
      fading=false;
      Conductor.changeBPM(songData[playing].bpm);
      var path = songData[playing].path;
      if(instOn)
        path = songData[playing].inst;

      FlxG.sound.playMusic(CoolUtil.getSound(path));
      FlxG.sound.music.fadeIn(.5,0,1);
    });
    OptionUtils.options.jukeboxSong = selection;
    OptionUtils.saveOptions(OptionUtils.options);
  }

  override function update(elapsed:Float){
    if (FlxG.sound.music != null)
      Conductor.songPosition = FlxG.sound.music.time;
    timer += elapsed;
    backdrops.y += .5 * (elapsed/(1/120));
    scaleTimer += elapsed/0.5;
    if(scaleTimer>1)scaleTimer=1;

    fart.angle = FlxMath.fastCos(timer * 2)*5;
    var scale = lerp(1.2, 1, scaleTimer);
    fart.scale.set(scale,scale);

    for(text in texts.members){
      if(text.y > bottomBounds - text.height/2){
        var rect = text.clipRect==null?new FlxRect(0,0,text.width*2,0):text.clipRect; // why make a new FlxRect if we can use clipRect that already exists
        var y:Float = bottomBounds + text.height/2 - text.y;
        var h:Float = text.frameHeight;
        y -= h;
        rect.y = y;
        rect.height = h;

        text.clipRect = rect;
      }else if(text.y < topBounds + text.height/2){
        var rect = text.clipRect==null?new FlxRect(0,0,text.width*2,0):text.clipRect; // why make a new FlxRect if we can use clipRect that already exists
        var h:Float = text.frameHeight*2;
        var y:Float = topBounds+text.height/2-text.y;

        h -= y;

        rect.y = y;
        rect.height = h;

        text.clipRect = rect;
      }else{
        text.clipRect=null;
      }
    }

    var scroll = selection>14?40*(selection-14):0;

    texts.y = lerp(texts.y,-scroll,Main.adjustFPS(.1));

    if (controls.BACK)
    {
      // TODO: save jukebox selection
      FlxG.switchState(new MainMenuState());
    }

    if (controls.ACCEPT)
    {
      playing = selection;
      if(!fading){
        play(playing);
      }
    }

    if(controls.DOWN_P)
      changeSelection(selection+1);


    if(controls.UP_P)
      changeSelection(selection-1);

    super.update(elapsed);
  }

  override function switchTo(next:FlxState){
    // Do all cleanup of stuff here! This makes it so you dont need to copy+paste shit to every switchState
    FlxG.stage.removeEventListener(MouseEvent.MOUSE_WHEEL,scroll);

    return super.switchTo(next);
  }

}
