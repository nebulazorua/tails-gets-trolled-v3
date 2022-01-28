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

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;
	public var currentOptions:Options;

	var menuItems:FlxTypedGroup<FNFSprite>;
	var sideMenuItems:FlxTypedGroup<FNFSprite>;
	var artBoxes:FlxTypedGroup<FNFSprite>;
	var layering:FlxTypedGroup<FNFSprite>;
	var optionShit:Array<String> = ['story mode', 'freeplay', 'options', 'promo'];
	var sideOptions:Array<String> = ['credits','jukebox','gf'];
	var backdrops:FlxBackdrop;
	var tweens:Map<FlxObject,FlxTween> = [];

	var magenta:FlxSprite;
	var camFollow:FlxObject;

	var fov = Math.PI/2;
  var near = 0;
  var far = 2;

  function FastTan(rad:Float) // thanks schmoovin
  {
    return FlxMath.fastSin(rad) / FlxMath.fastCos(rad);
  }

	function onMouseDown(object:FlxObject){
		if(!selectedSomethin){
			for(idx in 0...sideMenuItems.length){
				var obj = sideMenuItems.members[idx];
				if(object==obj){
					if(tweens[object]!=null)tweens[object].cancel();
					var object:FlxSprite = cast object;
					object.scale.x = .9;
					object.scale.y = .9;
				}
			}
		}
	}

	function onMouseUp(object:FlxObject){
		if(!selectedSomethin){
			for(idx in 0...sideMenuItems.length){
				var obj = sideMenuItems.members[idx];
				if(object==obj && obj.scale.x == .9 && obj.scale.y == .9){
					var object:FlxSprite = cast object;
					pressSideMenu(idx);
					if(tweens[object]!=null)tweens[object].cancel();
					tweens[object] = FlxTween.tween(object, {"scale.x": 1.1,"scale.y": 1.1}, .6, {
						ease: FlxEase.elasticOut,
						onComplete:function(twn:FlxTween){
							twn.cancel();
							tweens[object]=null;
							twn.destroy();
						}
					});
				}
			}
		}
	}

	function onMouseOver(object:FlxObject){
		if(!selectedSomethin){
			for(idx in 0...sideMenuItems.length){
				var obj = sideMenuItems.members[idx];
				if(obj==object){
					if(tweens[object]!=null)tweens[object].cancel();

					tweens[object] = FlxTween.tween(object, {"scale.x": 1.1,"scale.y": 1.1}, .15, {
						ease: FlxEase.quadOut,
						onComplete:function(twn:FlxTween){
							twn.cancel();
							tweens[object]=null;
							twn.destroy();
						}
					});
				}
			}
		}
	}

	function onMouseOut(object:FlxObject){
		if(!selectedSomethin){
			for(idx in 0...sideMenuItems.length){
				var obj = sideMenuItems.members[idx];
				if(obj==object){
					if(tweens[object]!=null)tweens[object].cancel();

					tweens[object] = FlxTween.tween(object, {"scale.x": 1,"scale.y": 1}, .15, {
						ease: FlxEase.quadOut,
						onComplete:function(twn:FlxTween){
							twn.cancel();
							tweens[object]=null;
							twn.destroy();
						}
					});
				}
			}
		}
	}


	function scroll(event:MouseEvent){
		changeItem(-event.delta);
	}

	function pressSideMenu(which:Int){
		switch(which){
			case 2:
				FlxG.switchState(new GFSelectState());
		}
	}

	function accept(){
		if (optionShit[curSelected] == 'promo')
		{
			#if linux
			Sys.command('/usr/bin/xdg-open', ["http://tailsgetstrolled.org/", "&"]);
			#else
			FlxG.openURL('http://tailsgetstrolled.org/');
			#end
		}
		else
		{
			selectedSomethin = true;
			FlxG.sound.play(Paths.sound('confirmMenu'));
			if(OptionUtils.options.menuFlash){
				FlxFlicker.flicker(magenta, 1.1, 0.15, false);
			}else{
				magenta.visible=true;
			}

			FlxTween.tween(FlxG.camera, {zoom: 1.1}, 0.85, {
				ease: FlxEase.quartOut
			});

			menuItems.forEach(function(spr:FlxSprite)
			{
				if (curSelected != spr.ID)
				{
					FlxTween.tween(spr, {alpha: 0}, 0.4, {
						ease: FlxEase.quadOut,
						onComplete: function(twn:FlxTween)
						{
							spr.kill();
						}
					});
				}
				else
				{
					if(OptionUtils.options.menuFlash){
						FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
						{
							var daChoice:String = optionShit[curSelected];

							switch (daChoice)
							{
								case 'story mode':
									FlxG.switchState(new StoryMenuState());
								case 'freeplay':
									FlxG.switchState(new SidemenuState());
								case 'options':
									FlxG.switchState(new OptionsState());
							}
						});
					}else{
						new FlxTimer().start(1, function(tmr:FlxTimer){
							var daChoice:String = optionShit[curSelected];

							switch (daChoice)
							{
								case 'story mode':
									FlxG.switchState(new StoryMenuState());
								case 'freeplay':
									FlxG.switchState(new SidemenuState());
								case 'options':
									FlxG.switchState(new OptionsState());
							}
						});
					}
				}
			});
		}
	}

	override function create()
	{
		super.create();
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		currentOptions = OptionUtils.options;


		if (FlxG.sound.music==null || !FlxG.sound.music.playing)
			FlxG.sound.playMusic(Paths.music('freakyMenu'));


		persistentUpdate = persistentDraw = true;

		/*var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.13;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);*/

		var bg:FlxSprite = new FlxSprite(-80).loadGraphic(Paths.image('mainmenu/background'));
		bg.scrollFactor.set();
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);
		backdrops = new FlxBackdrop(Paths.image('mainmenu/grid'), 0.2, 0.2, true, true);
		backdrops.color = 0xFF467aeb;
		backdrops.alpha = 0.25;
		backdrops.x -= 35;
		add(backdrops);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxBackdrop(Paths.image('mainmenu/grid'), 0.2, 0.2, true, true);
		magenta.visible = false;
		magenta.color = 0xFFFF0000;
		magenta.alpha = 0.25;
		magenta.x -= 35;
		add(magenta);


		menuItems = new FlxTypedGroup<FNFSprite>();
		sideMenuItems = new FlxTypedGroup<FNFSprite>();
		artBoxes = new FlxTypedGroup<FNFSprite>();

		var sideMenuBG = new FlxSprite(0,0);
		sideMenuBG.loadGraphic(Paths.image('mainmenu/sidebg'));
		sideMenuBG.x = FlxG.width - sideMenuBG.width;
		sideMenuBG.scrollFactor.set();
		sideMenuBG.antialiasing=true;
		add(sideMenuBG);

		layering = new FlxTypedGroup<FNFSprite>();
		add(layering);

		for (i in 0...sideOptions.length){
			var menuItem = new FNFSprite(0, 10 + (i * 90));
			menuItem.loadGraphic(Paths.image('mainmenu/${sideOptions[i]}'));
			menuItem.x = sideMenuBG.x + menuItem.width/2;
			menuItem.scrollFactor.set();
			menuItem.antialiasing=true;
			menuItem.ID = i;

			FlxMouseEventManager.add(menuItem,onMouseDown,onMouseUp,onMouseOver,onMouseOut);

			sideMenuItems.add(menuItem);

			layering.add(menuItem);
		}

		for (i in 0...optionShit.length)
		{
			var menuItem = new FNFSprite(0, 60 + (i * 160));
			menuItem.loadGraphic(Paths.image('mainmenu/${optionShit[i]}'));
			menuItem.scrollFactor.set();
			menuItem.antialiasing=true;
			menuItem.ID = i;
			menuItem.setGraphicSize(Std.int(menuItem.width*.8));
			menuItems.add(menuItem);

			var artBox = new FNFSprite(menuItem.x,menuItem.y);
			artBox.loadGraphic(Paths.image('mainmenu/artblocks/${optionShit[i]}'));
			artBox.scrollFactor.set();
			artBox.antialiasing=true;
			artBox.ID = i;
			artBox.setGraphicSize(Std.int(menuItem.width*.8));
			artBoxes.add(artBox);

			layering.add(menuItem);
			layering.add(artBox);
		}

		FlxG.camera.follow(camFollow, null, Main.adjustFPS(0.06));

		changeItem();

		FlxG.stage.addEventListener(MouseEvent.MOUSE_WHEEL,scroll);

	}

	function sortByOrder(wat:Int, Obj1:FNFSprite, Obj2:FNFSprite):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.zIndex, Obj2.zIndex);
	}

	var selectedSomethin:Bool = false;
	override function beatHit(){
		super.beatHit();
	}

	function getButton(id:Int):Null<FNFSprite>{
		for(child in menuItems.members){
			if(child.ID==id){
				return child;
			}
		}
		return null;
	}

	var radiusX = 450;
	var radiusY = 350;

	var originX = FlxG.width/2;
	var originY = FlxG.height/2 + 300;
	var lerpSpeed = .125;
	override function update(elapsed:Float)
	{
		artBoxes.forEachAlive( function(obj: FNFSprite) {

			var idx = obj.ID;
			var but = getButton(idx);

			obj.z = (idx-curSelected);//FlxMath.lerp(obj.z,(idx-curSelected),Main.adjustFPS(lerpSpeed));
			obj.zIndex = -obj.y;

			var input = (idx - curSelected) * FlxAngle.asRadians(360 / menuItems.length);
			var desiredX = FlxMath.fastSin(input)*radiusX;
			var desiredY = -(FlxMath.fastCos(input)*radiusY);

			var shit = FlxMath.fastSin(input);


			var scaleX = FlxMath.lerp(obj.scale.x,1 - (.3 * Math.abs(shit)),Main.adjustFPS(lerpSpeed));
			var scaleY = FlxMath.lerp(obj.scale.y,1 - (.3 * Math.abs(shit)),Main.adjustFPS(lerpSpeed));

			obj.scale.set(scaleX,scaleY);
			obj.updateHitbox();
			obj.x = FlxMath.lerp(obj.x,originX - obj.width/2 + desiredX,Main.adjustFPS(lerpSpeed));
			obj.y = FlxMath.lerp(obj.y,originY - obj.height/2 + desiredY,Main.adjustFPS(lerpSpeed));

			if(but!=null){
				but.z = obj.z;
				but.zIndex = obj.zIndex+1;
				var scaleX = FlxMath.lerp(but.scale.x,1 - (.3 * Math.abs(shit)),Main.adjustFPS(lerpSpeed));
				var scaleY = FlxMath.lerp(but.scale.y,1 - (.3 * Math.abs(shit)),Main.adjustFPS(lerpSpeed));

				but.scale.set(scaleX,scaleY);
				but.updateHitbox();
				but.x = (obj.x - (but.width-obj.width)/2);
				but.y = (obj.y + (415 * scaleX));
			}

		});

		layering.sort(sortByOrder);
		if (FlxG.sound.music.volume < 1.5)
			FlxG.sound.music.volume += 0.25 * (elapsed/(1/120));

		if(FlxG.sound.music.volume > 1.5)FlxG.sound.music.volume = 1.5;

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		FlxG.mouse.visible=true;

		if (!selectedSomethin)
		{
			if (controls.LEFT_P)
			{
				changeItem(-1);
			}

			if (controls.RIGHT_P)
			{
				changeItem(1);
			}

			if (controls.ACCEPT)
			{
				accept();
			}
		}

		backdrops.x += .5*(elapsed/(1/120));
		backdrops.y += .5*(elapsed/(1/120));
		magenta.x = backdrops.x;
		magenta.y = backdrops.y;
		super.update(elapsed);

	}

	function changeItem(huh:Int = 0,force:Bool=false)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		if(force){
			curSelected=huh;
		}else{
			curSelected += huh;

			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
		}

		menuItems.forEach(function(spr:FlxSprite)
		{
			if (spr.ID == curSelected)
			{
				//camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
			}

			//spr.updateHitbox();
		});
	}

	override function switchTo(next:FlxState){
		// Do all cleanup of stuff here! This makes it so you dont need to copy+paste shit to every switchState
		FlxG.stage.removeEventListener(MouseEvent.MOUSE_WHEEL,scroll);

		return super.switchTo(next);
	}
}
