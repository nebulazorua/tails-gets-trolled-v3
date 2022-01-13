package states;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.util.FlxTimer;
import flixel.addons.display.FlxBackdrop;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import math.Random;
import flixel.util.FlxColor;
import lime.utils.Assets;
import Options;
import flixel.FlxObject;
import flixel.input.mouse.FlxMouseEventManager;
import flash.events.MouseEvent;
import flixel.FlxState;
import openfl.filters.ShaderFilter;
import EngineData.WeekData;
import EngineData.SongData;
import haxe.Json;
import sys.io.File;
import openfl.media.Sound;
import flixel.effects.FlxFlicker;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import ui.*;
import Shaders;
#if cpp
import Sys;
import sys.FileSystem;
#end


using StringTools;

class Sidemenu extends MusicBeatState
{
	public static var unlocked:Array<Bool> = [true, true, false, false];
	var boxes:FlxTypedGroup<Box>;
	var backdrops:FlxBackdrop;
	var curSelected:Int = 0;
	var tweens:Map<FlxObject,FlxTween> = [];
	var selected:Bool = false;
	var canhover:Bool = false;
	var bf:Boyfriend;
	var p2:Character;

	function onMouseDown(obj:FlxObject){}

	function onMouseUp(obj:FlxObject){}

	function onMouseOver(obj:FlxObject){
		if(!selected && canhover){
			FlxG.sound.play(Paths.sound('scrollMenu'));
			if(tweens[obj]!=null)
				tweens[obj].cancel();
			tweens[obj] = FlxTween.tween(obj, {"scale.x": 1.05,"scale.y": 1.05}, .25, {
				ease: FlxEase.quadInOut
			});
		}
	}

	function onMouseOut(obj:FlxObject){
		if(tweens[obj]!=null)
			tweens[obj].cancel();
		tweens[obj] = FlxTween.tween(obj, {"scale.x": 1,"scale.y": 1}, .25, {
			ease: FlxEase.quadInOut
		});
	}

	function scroll(event:MouseEvent){
		changeSelection(-event.delta);
	}

	override function create()
	{
		super.create();
		FlxG.mouse.visible=true;

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}


		#if desktop
		DiscordClient.changePresence("In the Side Menus", null);
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		backdrops = new FlxBackdrop(Paths.image('freeplay/bluestuff'), 0.2, 0.2, true, true);
		backdrops.x -= 35;
		add(backdrops);
		new FlxTimer().start(0.0000001, function(tmr:FlxTimer){
			backdrops.y += 1;
		},0);

		var white = new NoteEffect();

		bf = new Boyfriend(0,0, 'bf');
		bf.screenCenter();
		bf.x += 490;
		bf.y += 120;
		bf.setGraphicSize(Std.int(bf.width * 1.25));
		bf.shader = white.shader;
		bf.antialiasing = true;
		white.setFlash(1);
		add(bf);

		p2 = new Character(0,0, Random.fromArray(['shadow','sonic','tails']));
		p2.screenCenter();
		p2.shader = white.shader;
		p2.x -= 600;
		p2.y -= 150;
		p2.setGraphicSize(Std.int(p2.width * 1.18));
		if (p2.curCharacter == 'shadow')
			p2.setGraphicSize(Std.int(p2.width * (1.18 + p2.charData.scale)));
		add(p2);

		boxes = new FlxTypedGroup<Box>();
		add(boxes);

		for (i in 0...4){
			var box:Box = new Box(unlocked[i],Std.string(i));
			box.screenCenter(X);
			boxes.add(box);
			box.y = 10 + (i * 178) + 1000;
			FlxTween.tween(box, {y: box.y - 1000}, 1.1 + (i * 0.15) ,{ease: FlxEase.cubeInOut,
				onComplete: function(twn:FlxTween)
				{
					canhover = true;
				}
			});
			FlxMouseEventManager.add(box,onMouseDown,onMouseUp,onMouseOver,onMouseOut);
		}

		changeSelection();
	}

	function switchlestate(thingy:String) {
		switch (thingy)
		{
			case '0':
				FreeplayState.ismain = true;
				FlxG.switchState(new FreeplayState());
			case '1':
				FreeplayState.ismain = false;
				FlxG.switchState(new FreeplayState());
		}
	}

	var idkanymore:String;

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		Conductor.songPosition = FlxG.sound.music.time;

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			FlxG.switchState(new MainMenuState());
		}

	for (i in boxes){//shuttup im sleepy
		if (selected)
			{
				if (i.pathname != idkanymore)
					{
						FlxTween.tween(i, {alpha: 0}, 0.3, {
							ease: FlxEase.sineOut});
					}
			}
		if (FlxG.mouse.overlaps(i)) {
			if (FlxG.mouse.justPressed) {
				if (!selected){
					if (i.pathname == 'lock'){
						FlxG.sound.play(Paths.sound('lockSelected'));
						FlxG.camera.shake(0.005,0.25,null,true);
					}
					else{
						idkanymore = i.pathname;
						FlxG.sound.play(Paths.sound('confirmMenu'));
						selected = true;
						FlxTween.tween(i, {y: 276}, 0.5, {
							ease: FlxEase.sineInOut});
						if(OptionUtils.options.menuFlash){
							FlxFlicker.flicker(i, 1.25, 0.1, false, false, function(flick:FlxFlicker){
								switchlestate(i.pathname);
							});
						}else{
							new FlxTimer().start(1.25, function(tmr:FlxTimer){
								switchlestate(i.pathname);
							});
						}
					}
				}
			}
		}

	}
	}

	function changeSelection(change:Int = 0,additive:Bool=true)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if(additive){
			curSelected += change;

			if (curSelected < 0)
				curSelected = 3;
			if (curSelected >= 4)
				curSelected = 0;
		}else{
			curSelected=change;
		}
	}

	override function beatHit()
		{
			if (curBeat % 2 == 0)
				{
					p2.dance();
					bf.dance();
				}
			super.beatHit();
		}

	override function switchTo(next:FlxState){
		FlxG.stage.removeEventListener(MouseEvent.MOUSE_WHEEL,scroll);

		return super.switchTo(next);
	}
}

class Box extends FlxSprite
{
	public var pathname:String;
	public function new(unlocked:Bool, path:String){
		super();
		antialiasing=true;
		if (unlocked){
			loadGraphic(Paths.image('freeplay/${path}'));
		}
		else{
			loadGraphic(Paths.image('freeplay/lock'));
			path = 'lock';
		}
		this.pathname = path;
		updateHitbox();
	}
}
