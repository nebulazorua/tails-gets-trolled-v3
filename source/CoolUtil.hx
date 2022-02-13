package;

import lime.utils.Assets;
import sys.thread.Thread;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import openfl.media.Sound;
import openfl.Assets;
import openfl.utils.AssetType;
import states.*;
import ui.*;
import flixel.math.FlxPoint;
import math.Vector3;
using StringTools;
import Options;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ['EASY', "NORMAL", "HARD"];

	public static function cacheSound(key:String,sound:Sound){
		trace(key);
		if(!Cache.soundCache.exists(key)){
			Cache.soundCache.set(key,sound);
		}
	}

	public static function rotate(x:Float, y:Float, angle:Float, ?point:FlxPoint):FlxPoint{
		var p = point==null?FlxPoint.get():point;
		p.set(
			(x*Math.cos(angle))-(y*Math.sin(angle)),
			(x*Math.sin(angle))+(y*Math.cos(angle))
		);
		return p;
	}

	public static function getSound(path:String):Sound{
		trace(path);
		if(Cache.soundCache.get(path)!=null)
			return Cache.soundCache.get(path);

		if(Assets.exists(path, AssetType.SOUND) || Assets.exists(path, AssetType.MUSIC))
			return Assets.getSound(path);

		var sound = Sound.fromFile(path);
		cacheSound(path,sound);
		return sound;
	}

	inline public static function clamp(n:Float, l:Float, h:Float){
		if(n>h)n=h;
		if(n<l)n=l;

		return n;
	}

	inline public static function quantize(f:Float, interval:Float){
		return Std.int((f+interval/2)/interval)*interval;
	}

	inline public static function scale(x:Float,l1:Float,h1:Float,l2:Float,h2:Float):Float
		return ((x - l1) * (h2 - l2) / (h1 - l1) + l2);

	public static function getDominantColour(sprite:FlxSprite):FlxColor{
		var counter:Map<Int,Int>=[];
		for(x in 0...sprite.frameWidth){
			for(y in 0...sprite.frameHeight){
				var colour = sprite.pixels.getPixel32(x,y);
				if(colour!=0){
					if(counter.exists(colour)){
						counter.set(colour,counter.get(colour)+1);
					}else{
						counter.set(colour,1);
					}
				}
			}
		}

		counter.set(FlxColor.BLACK,0);
		var highest:Int = 0;
		var domColour:Int=0;
		for(colour in counter.keys()){
			var amount = counter.get(colour);
			if(amount>=highest){
				highest=amount;
				domColour=colour;
			}
		}

		return domColour;
	}

	public static function playMenuMusic(){
		var selection = OptionUtils.options.jukeboxSong;

		Conductor.changeBPM(JukeboxState.songData[selection].bpm);
		var path = JukeboxState.songData[selection].path;
		if(OptionUtils.options.isInst)
			path = JukeboxState.songData[selection].inst;
		FlxG.sound.playMusic(CoolUtil.getSound(path));

	}
	public static function truncateFloat( number : Float, precision : Int): Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
	}

	public static function difficultyString(?difficulty:Int):String
	{
		if(difficulty==null)
			difficulty=PlayState.storyDifficulty;

		return difficultyArray[difficulty];
	}

	public static function coolTextFile(path:String):Array<String>
	{
		return coolTextFile2(Assets.getText(path));
	}

	public static function coolTextFile2(data:String):Array<String>
	{
		var daList:Array<String> = data.trim().split('\n');

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
		}

		return daList;
	}

	public static function numberArray(max:Int, ?min = 0, ?reverse=false):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			if(reverse){
				dumbArray.push(max-i);
			}else{
				dumbArray.push(i);
			}

		}
		return dumbArray;
	}
}
