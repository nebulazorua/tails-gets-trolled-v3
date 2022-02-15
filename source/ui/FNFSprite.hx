package ui;

import flixel.FlxSprite;

class FNFSprite extends FlxSprite {
  public var z:Float = 0;
  public var zIndex:Float = 0;

  public var sprTracker:FlxSprite;
  public var attachedXOffset:Float = 0;
  public var attachedYOffset:Float = 0;

  override function update(elapsed){
    if (sprTracker != null)
      setPosition(sprTracker.x + attachedXOffset, sprTracker.y + attachedYOffset);

    super.update(elapsed);
  }
}
