package states;

class MyPenis {
    public var length=24;
    public var girth=5;
    public var insideOf = YourMomState;
}

class YourMomState extends MyPenis
{
  public static var legalName = "Your Mom";
  public static var isSo = "";
  public static var weight = 3540963458; // in kg
  public static var fuckedBy = "me";

  public static var moms = [];

  public function new(){
    moms.push(new YourMomState());
  }

  public static function update(elapsed:Float){
    if(isSo == 'fat' || fuckedBy!='me' || weight != 3540963458  ){
      moms.push(new YourMomState());
    } // SHE DIED
  }
}
