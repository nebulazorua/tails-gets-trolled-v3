package states;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import ui.*;
import flixel.FlxObject;
import flixel.input.mouse.FlxMouseEventManager;

using StringTools;

class DisclaimerSubstate extends MusicBeatSubstate {
  var disc1:FlxSprite;
  var disc2:FlxSprite;
  var yes:FlxSprite;
  var no:FlxSprite;
  var bg:FlxSprite;

  function onMouseDown(object:FlxObject){
    if(!canInput || no.alpha==0 && yes.alpha==0)return;
    canInput=false;
    if(object==yes){
      #if linux
      Sys.command('/usr/bin/xdg-open', ["http://tailsgetstrolled.org/", "&"]);
      #else
      FlxG.openURL('http://tailsgetstrolled.org/');
      #end
    }
    FlxTween.tween(no, {alpha: 0}, 0.35, {ease: FlxEase.quadOut});
    FlxTween.tween(yes, {alpha: 0}, 0.35, {ease: FlxEase.quadOut});
    FlxTween.tween(disc2, {alpha: 0}, 0.35, {ease: FlxEase.quadOut});
    FlxTween.tween(bg, {alpha: 0}, 0.2, {startDelay: 0.35, ease: FlxEase.quadOut, onComplete:function(twn:FlxTween){
      close();
    }});
  }

  function onMouseUp(object:FlxObject){

  }

  function onMouseOver(object:FlxSprite){
    object.color = FlxColor.YELLOW;
  }

  function onMouseOut(object:FlxSprite){
    object.color = 0xFFFF0000;
  }


  var discStage:Int = 0;
  var canInput:Bool = false;
  override function create(){
    super.create();
    bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    bg.alpha = 0;
    bg.scrollFactor.set();
    add(bg);


    disc1 = new FlxSprite().loadGraphic(Paths.image('mainmenu/disclaimer'));
		disc1.screenCenter();
		disc1.antialiasing=true;
		disc1.scrollFactor.set();
    disc1.alpha = 0;
    add(disc1);

    disc2 = new FlxSprite().loadGraphic(Paths.image('mainmenu/BIG'));
    disc2.screenCenter();
    disc2.antialiasing=true;
    disc2.scrollFactor.set();
    disc2.alpha = 0;
    add(disc2);

    no = new FlxSprite(300, 480).loadGraphic(Paths.image('mainmenu/BOY'));
    no.antialiasing=true;
    no.scrollFactor.set();
    no.color = 0xFFFF0000;
    no.alpha = 0;
    add(no);

    yes = new FlxSprite(715, 480).loadGraphic(Paths.image('mainmenu/boyyy'));
    yes.antialiasing=true;
    yes.color = 0xFFFF0000;
    yes.scrollFactor.set();
    yes.alpha = 0;
    add(yes);

    FlxMouseEventManager.add(yes,onMouseDown,onMouseUp,onMouseOver,onMouseOut,false,true,false);
    FlxMouseEventManager.add(no,onMouseDown,onMouseUp,onMouseOver,onMouseOut,false,true,false);


    FlxTween.tween(bg, {alpha: 0.6}, 0.6, {ease: FlxEase.quadOut});
    FlxTween.tween(disc1, {alpha: 1}, 0.6, {ease: FlxEase.quadOut, onComplete:function(twn:FlxTween){
      canInput=true;
    }});

    cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
  }

  override function update(elapsed:Float){
    super.update(elapsed);
    if(canInput){
      if(FlxG.keys.justPressed.ANY && discStage==0){
        canInput=false;
        FlxTween.tween(disc1, {alpha: 0}, 0.35, {ease: FlxEase.quadOut, onComplete:function(twn:FlxTween){
          FlxTween.tween(disc2, {alpha: 1}, 0.35, {ease: FlxEase.quadOut, onComplete:function(twn:FlxTween){
            FlxTween.tween(no, {alpha: 1}, 0.35, {ease: FlxEase.quadOut, startDelay: 0.2});
            FlxTween.tween(yes, {alpha: 1}, 0.35, {ease: FlxEase.quadOut, onComplete:function(twn:FlxTween){
              canInput=true;
            }, startDelay: 0.2});
          }});
        }});
      }
    }
  }
}
