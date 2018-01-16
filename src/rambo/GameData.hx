package rambo;

typedef GameData = {
	var name:String;
	var level:Int;
	var ready:Bool;
	var heroId:HeroId;
	var state:Maybe<StateId>;
	var items:Array<{name:String}>;
	var someItems:DynamicObject<SomeKey,Some>;
	var state2:Choice<{?done:Int, ?inProgress:Float, ?c:String}>;
}

@:enum abstract StateId(String) {
	var Idle = "idle";
	var Building = "building";
}

abstract HeroId(Int) {}

abstract SomeKey(IntKey) to String {}

abstract Some(Array<{a:Int}>) {}
