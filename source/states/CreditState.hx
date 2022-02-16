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
import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;
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

typedef CreditInfo = {
  var displayName: String;
  var iconName: String;
  var roles: String;
  var note: String;
  var textName:String;
  @:optional var link:String;
}

class CreditState extends MusicBeatState  {
  var backdrops:FlxBackdrop;
  var icons:FlxTypedGroup<FlxSprite>;
  var texts:FlxTypedGroup<Alphabet>;
  var selected:Int = 0;
  var nameTxt:FlxText;
  var roleTxt:FlxText;
  var noteTxt:FlxText;
  var bangbangFormat:FlxTextFormat = new FlxTextFormat(0xFFFF0000, false, false, 0xFFFF0000);

  // TO ANYONE READING THIS:
  // It was me, nebula, who had written these credits
  // If any of these are wrong, make a PR or an issue on the github and I'll try my best to rectify it and expand on it a bit more.
  var credits:Array<CreditInfo> = [
    {link: 'https://twitter.com/CH_echolocated', textName: "Echo", displayName: "Echolocated", iconName: "echo", roles: "Main Director, Artist, Musician", note: "Made a single High Shovel cutscene frame.\n(Oh and almost all the icons I guess..)\n((EDIT: Allegedly also Swag Sonic and Scourge))\n(((Sometimes made No Villains)))" },
    {link: 'https://twitter.com/bepixel_owo', textName: "Bepixel", displayName: "Bepixel", iconName: "jellie", roles: "Art Director, Artist", note: "Made the Tails and Sonic sprites and backgrounds. Animated Shadow's shot animation. Helped with Chapter 3 Boyfriend death anim. Made Talentless Fox, No Villains, Die Batsards, Taste For Blood and partly High Shovel\n\ncutscenes."},
    {link: 'https://twitter.com/mylimit666', textName: "Hooda", displayName: "Hooda The Antagonist", iconName: "hooda", roles: "Music Director, Musician", note: "Made No Villains and, according to the fanbase, literally nothing else...\nMost of the time." },
    {link: 'https://twitter.com/Nebula_Zorua', textName: "Nebula", displayName: "Nebula The Zorua", iconName: "neb", roles: "Code Director, Programmer", note: "BLAMMED LIGHTS<r>‼️<r>" },
    {link: 'https://twitter.com/0WildeRaze', textName: "Wilde", displayName: "Wilde", iconName: "wilde", roles: "Chart Director, Charter", note: "Charted No Villains, Die Batsards, Taste For Blood and No Heroes. Recharted Talentless Fox. Touched on most charts.\nAnd looked damn good while doing it <3" },
    // TODO: create seperators for roles
    // artists
    {link: 'https://twitter.com/staticlysm', textName: "Static", displayName: "Staticlysm", iconName: "sketch", roles: "Sprite Artist, Background Artist", note: "Created Swag Tails and Shadow sprites. Also created Die Batsards and Taste For Blood backgrounds.\nBullied into namechange by Hooda" },
    {textName: "Wieder", displayName: "Wieder the Rabbit", iconName: "wiener", roles: "Sprite Artist, Background Artist", note: "Literally all the High Shovel art.\nWiener." },
    {link: 'https://twitter.com/potopollo_po', textName: "Polli", displayName: "Potopollo", iconName: "polli", roles: "Sprite Artist", note: "Creating the Chapter 3+ boyfriend sprites and animations.\nDTIYS but somehow MORE in your style" },
    {link: 'https://twitter.com/xooplord', textName: "Xooplord", displayName: "Xooplord", iconName: "xoop", roles: "Cutscene Artist", note: "Sketched and storyboarded the High Shovel cutscene, and animated part of it." },
    {link: 'https://twitter.com/fl0pd00dle/', textName: "flopdoodle", displayName: "Flopdoodle", iconName: "flop", roles: "Sprite Artist", note: "Jukebox art" },
    {link: 'https://twitter.com/Comgamingnz', textName: "Comgaming", displayName: "Comgaming", iconName: "com", roles: "Sprite Artist", note: "Scrapped background characters for Die Batsards.\nBest of luck to you and your living situation, I hope it all gets resolved!" },
    // programmers
    {link: 'https://twitter.com/Shadowfi1385', textName: "Shadowfi", displayName: "Shadowfi", iconName: "shadowfi", roles: "Programmer", note: "Put in the Side-stories menu and Die Batsards stage.\nFucking kity."},
    // charters
    {link: 'https://twitter.com/Cerbera_fnf', textName: "Cerbera", displayName: "Cerbera", iconName: "cerbera", roles: "Charter", note: "Charted High Shovel (incorrectly >:() and No Bitches M.\nThe second best femboy charter.\nUses FPS+ lmao." },
    {link: 'https://twitter.com/gibz679', textName: "gibz", displayName: "gibz", iconName: "gibz", roles: "Charter", note: "Charted Groovy Fox.\nBut charted the grace notes as jumps???" },
    // musicians
    {link: 'https://twitter.com/longestsoloever', textName: "LSE", displayName: "LongestSoloEver", iconName: "lse", roles: "Musician", note: "Created Taste For Blood, Pause, and Game Over.\nStole TFB from Hooda (wouldn't have it any other way lmao).\nHelped with menu music.\nDebatable on if it is ACTUALLY the longest." },
    {link: 'https://twitter.com/Philiplolz', textName: "philiplol", displayName: "Philiplol", iconName: "philiplol", roles: "Musician, Voice Actor", note: "Created High Shovel. Voice acted Knuckles.\nHigh shovel, bro." },
    {link: 'https://twitter.com/pex_ton', textName: "penkaru", displayName: "Penkaru", iconName: "penkaru", roles: "Musician", note: "Created No Bitches P.\nWas supposed to help with Taste for Blood but scores didn't get used." },
    {link: 'https://twitter.com/Matasaki_Dude', textName: "matasaki", displayName: "Matasaki", iconName: "matasaki", roles: "Musician", note: "Created No Bitches M.\nBiggest fan. Thanks for stickin' by us!" },
    {link: 'https://twitter.com/HugeNate_', textName: "hugenate", displayName: "HugeNate", iconName: "hugenate", roles: "Musician", note: "Created Groovy Fox.\nNathaniel of the large variety." },
    {link: 'https://twitter.com/ayybeff', textName: "ayybeff", displayName: "Ayybeff", iconName: "ayybeff", roles: "Musician", note: "Created No Heroes / No Villains B-Side.\nGot their good cover in the game." },
    // because i know people are gonna go "WAA YOU'RE SAYING THEY'RE THE ONLY GOOD COVER!!" and go off at hooda
    // it was me, neb, lmao
    // flame me not hooda

    // VAs
    {link: 'https://twitter.com/mc83ch5', textName: "Mike", displayName: "mc83ch5", iconName: "mikechrysler", roles: "Voice Actor", note: "Voice acted Tails.\nNo talent whatsoever." },
    {link: 'https://twitter.com/phropii', textName: "distorcore", displayName: "Distorcore", iconName: "jippy", roles: "Voice Actor", note: "Voice acted Sonic.\nStill the best Sonic voice in FNF." },
    {link: 'https://twitter.com/StickyBM', textName: "sticky", displayName: "Sticky", iconName: "sticky", roles: "Voice Actor", note: "Voice acted Shadow.\nDanish Shadow lmao." },

  ];

  function onMouseDown(object:FlxObject){
    for(idx in 0...texts.members.length){
      var obj = texts.members[idx];
      if(obj==object){
        if(idx!=selected)
          changeSelection(idx);
        else
          accept();
      }
    }
  }

  function onMouseUp(object:FlxObject){

  }

  function onMouseOver(object:FlxObject){

  }

  function onMouseOut(object:FlxObject){

  }

  function scroll(event:MouseEvent){
    changeSelection(selected-event.delta);
  }

  function accept(){
    for (item in texts.members)
    {
      if(item.ID==selected && credits[selected].link!=null){
        #if linux
        Sys.command('/usr/bin/xdg-open', [credits[selected].link, "&"]);
        #else
        FlxG.openURL(credits[selected].link);
        #end
      }
    }
  }

  override function create()
  {
    #if desktop
    DiscordClient.changePresence("Looking at the credits", null);
    #end
    super.create();
    var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('credits/gradient'));
    bg.scrollFactor.set();
    bg.setGraphicSize(Std.int(bg.width * 1.1));
    bg.updateHitbox();
    bg.screenCenter();
    bg.antialiasing = true;
    add(bg);

    backdrops = new FlxBackdrop(Paths.image('credits/grid'), 0.2, 0.2, true, true);
    backdrops.alpha = 0.15;
    backdrops.x -= 10;
    add(backdrops);

    var box:FlxSprite = new FlxSprite().loadGraphic(Paths.image('credits/box'));
    box.screenCenter();
    box.x -= 175;
    box.scrollFactor.set();
    box.updateHitbox();
    box.antialiasing = true;
    add(box);

    nameTxt = new FlxText(600, 305, 500, "Name", 32);
    nameTxt.setFormat(Paths.font("arial.ttf"), 28, FlxColor.WHITE, CENTER);
    add(nameTxt);

    roleTxt = new FlxText(600, 340, 500, "Role", 32);
    roleTxt.setFormat(Paths.font("arial.ttf"), 28, FlxColor.WHITE, CENTER);
    add(roleTxt);

    noteTxt = new FlxText(600, 430, 500, "Note", 32);
    noteTxt.setFormat(Paths.font("arial.ttf"), 28, FlxColor.WHITE, CENTER);
    add(noteTxt);

    texts = new FlxTypedGroup<Alphabet>();
    add(texts);

    icons = new FlxTypedGroup<FlxSprite>();
    add(icons);

    for (i in 0...credits.length)
		{
      var data = credits[i];
      var iconName = data.iconName;
      var display = data.textName;

      var text:Alphabet = new Alphabet(0, (70 * i) + 30, display, true, false, .69696969696969696969696969696969); // haha 69
			text.isMenuItem = true;
			text.targetY = i;
			text.movementType = 'listManualX';
			text.wantedX = FlxG.width/2 - (text.width+150)/2 - 200/2;
			text.gotoTargetPosition();
      text.ID = i;

      var icon:FlxSprite = new FlxSprite(860,75).loadGraphic(Paths.image('credits/icons/$iconName'));
      icon.setGraphicSize(Std.int(icon.width*1.2));
      icon.scrollFactor.set();
      icon.updateHitbox();
      icon.antialiasing = true;
      icon.visible=false;
      icon.ID = i;

      FlxMouseEventManager.add(text,onMouseDown,onMouseUp,onMouseOver,onMouseOut);
      texts.add(text);
      icons.add(icon);
    }

    FlxG.stage.addEventListener(MouseEvent.MOUSE_WHEEL,scroll);

    updateSelection();
  }

  function changeSelection(newSelect:Int){
    FlxG.sound.play(Paths.sound('scrollMenu'));
    selected=newSelect;
    if(selected>credits.length-1){
      selected=0;
    }
    if(selected<0){
      selected=credits.length-1;
    }
    updateSelection();
  }

  function updateSelection(){
    for (item in texts.members)
		{
      var icon:FlxSprite = icons.members[item.ID];
			item.targetY = item.ID - selected;
      icon.visible = item.targetY==0;
    }

    var data = credits[selected];
    nameTxt.text = data.displayName;
    roleTxt.text = data.roles;
    noteTxt.applyMarkup(data.note, [new FlxTextFormatMarkerPair(bangbangFormat, '<r>')]);

    nameTxt.x = 700;
    roleTxt.x = 700;
    noteTxt.x = 700;

    // just so it wont shift around
  }

  override function update(elapsed:Float){
    backdrops.x += .5 * (elapsed/(1/120));
    backdrops.y -= .5 * (elapsed/(1/120));

    if (controls.BACK)
      FlxG.switchState(new MainMenuState());


    if(controls.DOWN_P)
      changeSelection(selected+1);

    if(controls.UP_P)
      changeSelection(selected-1);

    if(controls.ACCEPT)
      accept();

    super.update(elapsed);
  }

  override function switchTo(next:FlxState){
    // Do all cleanup of stuff here! This makes it so you dont need to copy+paste shit to every switchState
    FlxG.stage.removeEventListener(MouseEvent.MOUSE_WHEEL,scroll);

    return super.switchTo(next);
  }
}
