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

  var whore:Character;
  var whores = ["gf","gfbest"];
  var selectedChar = 0;
  var characters:FlxTypedGroup<Character>;
  var topbars:Array<FlxSprite>=[];

  override function create()
  {
    super.create();

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

    characters = new FlxTypedGroup<Character>();
    add(characters);

    for(name in whores){
      var char = new Character(0,0,name);
      char.screenCenter(XY);
      char.visible=false;
      characters.add(char);
    }
    characters.members[0].visible=true;
    whore = characters.members[0];
  }

  override function beatHit(){
    //whore.dance();
    super.beatHit();
  }

  override function update(elapsed:Float){
    if (FlxG.sound.music != null)
      Conductor.songPosition = FlxG.sound.music.time;
    super.update(elapsed);
    backdrops.y += .5 * (elapsed/(1/120));

    if (controls.BACK)
    {
      FlxG.switchState(new MainMenuState());
    }

  }
}
