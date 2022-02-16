package states;

#if desktop
import Discord.DiscordClient;
import sys.thread.Thread;
#end
import Options;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;
import openfl.Assets;
import math.Random;
import ui.*;
using StringTools;
import Shaders;
import openfl.filters.ShaderFilter;

class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;
	var songPos:Float = 0;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;
	var startedIntro:Bool = false;

	var shit:FlxSound;

	override public function create():Void
	{

		curWacky = FlxG.random.getObject(getIntroTextShit());

		// DEBUG BULLSHIT

		super.create();

		/*NGio.noLogin(APIStuff.API);

		#if ng
		var ng:NGio = new NGio(APIStuff.API, APIStuff.EncKey);
		trace('NEWGROUNDS LOL');
		#end*/

		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		#else
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var bg:Stage;
	var highShader:HighEffect;

	function startIntro()
	{
		FlxG.autoPause=true;
		if (!initialized)
		{
			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();
		}

		Conductor.changeBPM(90);
		persistentUpdate = true;


		bg = new Stage(Random.fromArray(Stage.stageNames),EngineData.options,false);// new FlxSprite(FlxG.width, FlxG.height).loadGraphic(Paths.image('titleBG'));
		add(bg);

		if(bg.curStage=='highzoneShadow'){
			highShader = new HighEffect();
			FlxG.camera.setFilters([new ShaderFilter(highShader.shader)]);
		}

		var titleNames = Paths.getDirs("titles");
		var titleShit = Random.fromArray(titleNames);
		logoBl = new FlxSprite(0);
		logoBl.frames = Paths.getSparrowAtlas('titles/${titleShit}/logoBumpin');
		logoBl.antialiasing = true;
		logoBl.animation.addByPrefix('bump', 'logo bumpin', 24);
		logoBl.animation.play('bump');
		logoBl.setGraphicSize(Std.int(logoBl.width * 0.72));
		logoBl.scrollFactor.set();
		logoBl.updateHitbox();
		logoBl.screenCenter(XY);

		//i know its wasteful but im a lazy ass

		titleText = new FlxSprite(FlxG.width * 0.099, FlxG.height * 0.825);

		add(logoBl);
		titleText.frames = Paths.getSparrowAtlas('titleEnter');
		titleText.animation.addByPrefix('idle', "Press Enter to Begin0", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED0", 24);
		titleText.antialiasing = true;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = true;
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "Nebula the Zorua\nBepixel\nEcholocated\nWilde", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = true;

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.mouse.visible = false;

		//CoolUtil.playMenuMusic();
		//FlxG.sound.music.pause();
		//shit = FlxG.sound.play(Paths.music('freakyIntro'));
		FlxG.sound.cache(Paths.music('freakyMenu'));
		FlxG.sound.playMusic(Paths.music('freakyIntro'));
		FlxG.sound.music.onComplete= function(){
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}
		//shit.fadeIn(4, 0, 0.7);
		startedIntro=true;

		if (initialized)
			skipIntro();
		else
			initialized = true;

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('introText'));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if(startedIntro){
			if (FlxG.sound.music != null && FlxG.sound.music.playing)
				Conductor.songPosition = songPos+FlxG.sound.music.time;
			else{
				Conductor.songPosition += elapsed*1000;
				songPos=Conductor.songPosition;
			}

			if(highShader!=null)
				highShader.update(elapsed);

			// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

			if (FlxG.keys.justPressed.F)
			{
				FlxG.fullscreen = !FlxG.fullscreen;
			}

			var pressedEnter:Bool = FlxG.keys.justPressed.ENTER;

			#if mobile
			for (touch in FlxG.touches.list)
			{
				if (touch.justPressed)
				{
					pressedEnter = true;
				}
			}
			#end

			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.START)
					pressedEnter = true;

				#if switch
				if (gamepad.justPressed.B)
					pressedEnter = true;
				#end
			}

			if (pressedEnter && !transitioning && skippedIntro)
			{

				titleText.animation.play('press',true);

				//bg.visible = false;


				FlxG.camera.flash(FlxColor.WHITE, 1, null, true);
				FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

				transitioning = true;
				// FlxG.sound.music.stop();

				new FlxTimer().start(2, function(tmr:FlxTimer)
				{
					// Check if version is outdated

					var version:String = "v" + Application.current.meta.get('version');

					/*if (version.trim() != NGio.GAME_VER_NUMS.trim() && !OutdatedSubState.leftState)
					{
						FlxG.switchState(new OutdatedSubState());
						trace('OLD VERSION!');
						trace('old ver');
						trace(version.trim());
						trace('cur ver');
						trace(NGio.GAME_VER_NUMS.trim());
					}
					else
					{
						FlxG.switchState(new MainMenuState());
					}*/
					var selection = OptionUtils.options.jukeboxSong;
					if(selection!=0){
						FlxG.sound.music.fadeOut(.5, 0, function(twn:FlxTween){
							Conductor.changeBPM(JukeboxState.songData[selection].bpm);
							var path = JukeboxState.songData[selection].path;
							if(OptionUtils.options.isInst)
								path = JukeboxState.songData[selection].inst;

							FlxG.switchState(new MainMenuState());
							FlxG.sound.playMusic(CoolUtil.getSound(path));
							FlxG.sound.music.fadeIn(.5,0,1, function(twn:FlxTween){
								FlxG.sound.music.fadeTween=null;
							});
						});
					}else{
						FlxG.switchState(new MainMenuState());
					}
				});
				// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
			}

			if (pressedEnter && !skippedIntro)
			{
				skipIntro();
			}
		}
		if(bg!=null)
			bg.update(elapsed);
		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();
		if(bg!=null)
			bg.beatHit(curBeat);

		logoBl.animation.play('bump',true);

		FlxG.log.add(curBeat);

		switch (curBeat)
		{
			case 1:
				createCoolText(['Nebula the Zorua', 'Bepixel', 'Wilde', 'Echolocated']);
			case 3:
				addMoreText('present');
			case 4:
				deleteCoolText();
			case 5:
				createCoolText(['In association', 'with']);
			case 7:
				addMoreText('tailsgetstrolled dot org');
				ngSpr.visible = true;
			case 8:
				deleteCoolText();
				ngSpr.visible = false;
			case 9:
				createCoolText([curWacky[0]]);
			case 11:
				addMoreText(curWacky[1]);
			case 12:
				deleteCoolText();
			case 13:
				addMoreText('Tails');
			case 14:
				addMoreText('Gets');
			case 15:
				addMoreText('Trolled');

			case 16:
				skipIntro();
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);

			FlxG.camera.flash(FlxColor.WHITE, 2);
			//shit.fadeOut(.2,0);
			//FlxG.sound.music.play();
			Conductor.changeBPM(180);

			remove(credGroup);
			skippedIntro = true;
		}
	}
}
