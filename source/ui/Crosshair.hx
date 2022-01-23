 package ui;

import flixel.FlxSprite;

class Crosshair extends FlxSprite {
  public var strumTime:Float = 0;
  public var hitbox:Float = 166;
  public var wasHit:Bool = false;
  public var canBeHit:Bool = false;
  public var tooLate:Bool = false;
  public var initialPos:Float = 0;
  public static var swagWidth:Float = 169 * .7;
  override function update(elapsed:Float){
    super.update(elapsed);
    var diff = strumTime-Conductor.songPosition;
    var absDiff = Math.abs(diff);

    if (absDiff<=hitbox)
      canBeHit = true;
    else
      canBeHit = false;

    if(diff<-hitbox){
      tooLate=true;
    }
  }

  public function new(time:Float=0){
    super();
    visible=false;
    strumTime = time;

    loadGraphic(Paths.image("crosshair"));
    setGraphicSize(Std.int(width*.7));
    updateHitbox();


  }
}
