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

class GFSelectState extends MusicBeatState
{
  var backdrops:FlxBackdrop;

  var tweens:Map<FlxObject,FlxTween> = [];
  var left:FlxSprite;
  var right:FlxSprite;
  var whore:Character;
  public static var whores = ["gf","gfbetter", "gfbest", "gfbminus", "gfeminus"];

  var afterChapter3:Array<String> = ["gfbminus","gfeminus"];
  var selectableWhores:Array<String>=[];
  var selectedChar:Int = 0;
  var characters:FlxTypedGroup<Character>;
  var topbars:FlxTypedGroup<FlxSprite>;

  override function create()
  {
    super.create();
    FlxG.save.data.clearedCh3Notif=true;
    for(gf in whores){
      if(!afterChapter3.contains(gf) || FlxG.save.data.finishedCh3){
        selectableWhores.push(gf);
      }
    }

    selectedChar = whores.indexOf(OptionUtils.options.gfSkin);
    if(selectedChar==-1){
      OptionUtils.options.gfSkin = whores[0];
      OptionUtils.saveOptions(OptionUtils.options);
      selectedChar=0;
    }
    var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('humantrafficking/bg'));
    bg.scrollFactor.set();
    bg.setGraphicSize(Std.int(bg.width * 1.1));
    bg.updateHitbox();
    bg.screenCenter();
    bg.antialiasing = true;
    add(bg);


    backdrops = new FlxBackdrop(Paths.image('humantrafficking/grid'), 0.2, 0.2, true, true);
    backdrops.color = 0xFFBF0000;
    backdrops.alpha = 0.15;
    backdrops.x -= 35;
    add(backdrops);

    var circle:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('humantrafficking/circle'));
    circle.scrollFactor.set();
    circle.setGraphicSize(Std.int(circle.width * 1.1));
    circle.updateHitbox();
    circle.screenCenter();
    circle.antialiasing = true;
    add(circle);

    var esc:FlxSprite = new FlxSprite(60,25).loadGraphic(Paths.image('humantrafficking/esc'));
    esc.scrollFactor.set();
    esc.updateHitbox();
    esc.antialiasing = true;
    add(esc);

    left = new FlxSprite(-80).loadGraphic(Paths.image('humantrafficking/left arrow'));
    left.scrollFactor.set();
    left.setGraphicSize(Std.int(left.width * 1));
    left.updateHitbox();
    left.screenCenter();
    left.x -= 300;
    left.antialiasing = true;
    add(left);

    right = new FlxSprite(-80).loadGraphic(Paths.image('humantrafficking/right arrow'));
    right.scrollFactor.set();
    right.setGraphicSize(Std.int(right.width * 1));
    right.updateHitbox();
    right.screenCenter();
    right.x += 300;
    right.antialiasing = true;
    add(right);

    characters = new FlxTypedGroup<Character>();
    add(characters);

    topbars = new FlxTypedGroup<FlxSprite>();
    add(topbars);

    #if desktop
    // Updating Discord Rich Presence
    DiscordClient.changePresence("Selecting a new GF", null);
    #end

    for(name in selectableWhores){
      var char = new Character(0,0,name);
      char.screenCenter(XY);
      char.visible=false;
      characters.add(char);

      var bar = new FlxSprite(-80).loadGraphic(Paths.image('humantrafficking/bar/${name}'));
      bar.scrollFactor.set();
      bar.setGraphicSize(Std.int(bar.width * 1));
      bar.updateHitbox();
      bar.visible = false;
      bar.x = FlxG.width - bar.width;
      bar.antialiasing = true;
      topbars.add(bar);
    }
    characters.members[selectedChar].visible=true;
    topbars.members[selectedChar].visible=true;
    whore = characters.members[selectedChar];
  }

  override function beatHit(){
    for(c in characters){
      c.dance();
    }
    super.beatHit();
  }

  override function switchTo(next:FlxState){
    for(c in characters){
      c.destroy();
    }
		return super.switchTo(next);
	}

  function change(delta:Int){
    topbars.members[selectedChar].visible=false;
    selectedChar += delta;
    if(selectedChar<0)selectedChar = characters.length-1;
    if(selectedChar>characters.length-1)selectedChar = 0;
    whore.visible=false;
    whore = characters.members[selectedChar];
    whore.visible=true;
    topbars.members[selectedChar].visible=true;
  }

  override function update(elapsed:Float){
    if (FlxG.sound.music != null)
      Conductor.songPosition = FlxG.sound.music.time;
    super.update(elapsed);
    backdrops.y += .5 * (elapsed/(1/120));

    if (controls.BACK)
    {
      OptionUtils.options.gfSkin = selectableWhores[selectedChar];
      OptionUtils.saveOptions(OptionUtils.options);
      FlxG.switchState(new MainMenuState());
    }

    if(controls.LEFT_P){
      left.x = FlxG.width/2 - left.width/2 - 325;
      if(tweens[left]!=null)tweens[left].cancel();
      tweens[left] = FlxTween.tween(left, {x: FlxG.width/2 - left.width/2 - 300}, .2, {
        ease: FlxEase.quadOut,
        onComplete:function(twn:FlxTween){
          twn.cancel();
          tweens[left]=null;
          twn.destroy();
        }
      });
      change(-1);
    }

    if(controls.RIGHT_P){
      right.x = FlxG.width/2 - right.width/2 + 325;
      if(tweens[right]!=null)tweens[right].cancel();
      tweens[right] = FlxTween.tween(right, {x: FlxG.width/2 - right.width/2 + 300}, .2, {
        ease: FlxEase.quadOut,
        onComplete:function(twn:FlxTween){
          twn.cancel();
          tweens[right]=null;
          twn.destroy();
        }
      });
      change(1);
    }

  }
}
