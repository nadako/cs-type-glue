package rambo;

typedef GameData = {
	var string:String;
	var int:Int;
	var float:Float;
	var bool:Bool;
	var abstr:Abstr;
	var array:Array<Int>;
	var intmap:DynamicObject<IntKey,{inner:String}>;
	var abstrmap:DynamicObject<UserId,User>;
	var optint:Maybe<Int>;
	var optstr:Maybe<String>;
	var enumabstr:StateId;
	var choice:State;
	var player:Player;
}

abstract Abstr(Int) {}

abstract UserId(String) to String {}

typedef User = Player;

typedef Player = {
	var name:String;
	var friend:Player;
	var choice:State;
	var state:StateId;
}

@:enum abstract StateId(String) {
	var Idle = "idle";
	var Upgrading = "upgrading";
}

typedef State = Choice<{
	?onMap:UserId,
	?inSquad:Int,
	?inNpcChain:{chainId:Int, mapId:UserId}
}>;
