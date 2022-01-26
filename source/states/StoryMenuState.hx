package states;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;
import flash.events.MouseEvent;
import flixel.FlxState;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.FlxObject;
import flixel.tweens.FlxEase;
import flixel.input.mouse.FlxMouseEventManager;
import Options;
import flixel.effects.FlxFlicker;
import flash.system.System;
import flixel.system.FlxSound;

using StringTools;


class StoryIcon extends FlxSprite
{
	public var cutscene:String;
	public var weekData:EngineData.WeekData;
	public function new(x:Float, y:Float, cutscene:String, weekData:EngineData.WeekData, image:String){
		super(x,y);
		this.cutscene=cutscene;
		this.weekData=weekData;
		antialiasing=true;
		loadGraphic(Paths.image('newstorymenu/${image}'));
		updateHitbox();
	}
}


class StoryMenuState extends MusicBeatState
{
	var scoreText:FlxText;

	var curDifficulty:Int = 1;

	public static var weekUnlocked:Array<Bool> = [true, true, true, true, true, true, true];

	var curWeek:Int = 0;

	var txtTracklist:FlxText;
	var movedBack:Bool=false;
	var selectedWeek:Bool=false;
	var isCutscene:Bool=false;

	var locks:FlxTypedGroup<FlxSprite>;
	var sprites:FlxTypedGroup<StoryIcon>;
	var tweens:Map<FlxObject,FlxTween> = [];
	var clickedObject:Dynamic;

	var sound:FlxSound;
	var pissOff:Int = 0;
	var clickTimer:Float = 0;
	/*var unlockedSpaces:Array<SpaceData> = [
		{cutscene: "tailsGetsTrolled", song: "talentless-fox", image: "ch_1" },
		{cutscene: "sonicGetsTrolled", song: "no-villains", image: "ch_2" }
	];*/
	var unlockedSpaces:Array<EngineData.WeekData> = [];

	function onMouseDown(object:FlxObject){
		if(!selectedWeek){
			clickedObject=object;
		}
	}

	function isChapter(object:Dynamic){
		for(obj in sprites.members){
			if(obj==object){
				return true;
			}
		}
		return false;
	}

	function isLock(object:Dynamic){
		for(obj in locks.members){
			if(obj==object){
				return true;
			}
		}
		return false;
	}

	function startShit(icon:StoryIcon){
		PlayState.setStoryWeek(icon.weekData,1);
		if(icon.cutscene!=''){
			var video:MP4Handler = new MP4Handler();
			if (!isCutscene) // Checks if the current week is Tutorial.
			{
				video.playMP4(Paths.video(icon.cutscene));
				video.stateCallback = new PlayState();
				isCutscene = true;
			}
		}else{
			LoadingState.loadAndSwitchState(new PlayState());
		}

	}

	function onMouseUp(object:FlxObject){
		if(!selectedWeek){
			if(isChapter(object) && clickedObject==object){
				selectedWeek = true;
				FlxG.sound.play(Paths.sound('confirmMenu'));
				var weekData:StoryIcon = cast object;
				if(OptionUtils.options.menuFlash){
					FlxFlicker.flicker(object, 1.25, 0.1, false, false, function(flick:FlxFlicker){
						startShit(weekData);
					});
				}else{
					new FlxTimer().start(1.25, function(tmr:FlxTimer){
						startShit(weekData);
					});
				}
			}else if(clickedObject==object && isLock(object)){
				FlxG.sound.play(Paths.sound('lockSelected'));
				if(tweens[object]!=null)tweens[object].cancel();
				var object:FlxSprite = cast object;
				object.scale.x = 1.1;
				object.scale.y = .9;
				clickTimer = 0;
				pissOff++;
				if(pissOff>=10){
					pissOff=0;
					if(sound!=null && sound.playing==true){
						FlxG.sound.play(Paths.sound("ANGRY_TEXT_BOX"),2);
						new FlxTimer().start(.5, function(tmr:FlxTimer){
							System.exit(0);
						});
					}else{
						sound = FlxG.sound.play(Paths.sound("notfinished"),2);
						sound.onComplete = function(){
								sound.stop();
								sound.destroy();
								sound=null;
						}
						FlxG.camera.shake(0.005,0.25,null,true,X);
					}
				}
				tweens[object] = FlxTween.tween(object, {"scale.x": 1,"scale.y": 1}, 1.85, {
					ease: FlxEase.elasticOut
				});
			}
		}
	}

	function onMouseOver(object:FlxObject){
		if(!selectedWeek){
			var isChap = isChapter(object);
			if(isChap){
				if(tweens[object]!=null)tweens[object].cancel();

				tweens[object] = FlxTween.tween(object, {"scale.x": 1.05,"scale.y": 1.05}, .25, {
					ease: FlxEase.quadInOut
				});
			}
		}
	}

	function onMouseOut(object:FlxObject){
		var isChap = isChapter(object);
		if(isChap){
			if(tweens[object]!=null)tweens[object].cancel();
			tweens[object] = FlxTween.tween(object, {"scale.x": 1,"scale.y": 1}, .25, {
				ease: FlxEase.quadInOut
			});
		}
	}

	override function create()
	{
		super.create();
		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		locks = new FlxTypedGroup<FlxSprite>();
		sprites = new FlxTypedGroup<StoryIcon>();
		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		persistentUpdate = persistentDraw = true;
		var unlockedSpaces:Array<EngineData.WeekData> = EngineData.weekData;
		var unlockedNum:Int = unlockedSpaces.length;
		add(sprites);
		add(locks);

		var bg = new FlxSprite().loadGraphic(Paths.image('newstorymenu/bg'));
		bg.screenCenter(XY);
		add(bg);
		for(index in 0...10){
			var x = 53+245*(index%5);
			var y = 179+268*Math.floor(index/5);
			if(index<unlockedNum){
				var data = unlockedSpaces[index];
				var icon:StoryIcon = new StoryIcon(x,y,data.cutscene,data,data.character);
				sprites.add(icon);
				FlxMouseEventManager.add(icon,onMouseDown,onMouseUp,onMouseOver,onMouseOut);
			}else{
				var lock:FlxSprite = new FlxSprite(x,y);
				lock.loadGraphic(Paths.image("newstorymenu/lock"));
				lock.x += lock.width/4;
				lock.y += lock.height/4;
				lock.antialiasing=true;
				locks.add(lock);
				FlxMouseEventManager.add(lock,onMouseDown,onMouseUp,onMouseOver,onMouseOut);
			}
		}

		FlxG.mouse.visible=true;



	}

	override function update(elapsed:Float)
	{
		clickTimer += elapsed;
		if(clickTimer>=1){
			pissOff=0;
		}
		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}


	function selectWeek()
	{

	}

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;
	}

	function updateText()
	{

	}

	override function switchTo(next:FlxState){
		// Do all cleanup of stuff here! This makes it so you dont need to copy+paste shit to every switchState
		//FlxG.stage.removeEventListener(MouseEvent.MOUSE_WHEEL,scroll);

		return super.switchTo(next);
	}

}
