package rambo;

typedef GameData = {
	var name:String;
	var level:Int;
	var ready:Bool;
	var heroId:HeroId;
	// var someKey:SomeKey;

	var state:Maybe<StateId>;
	// var state:{id:StateId, endTime:Float};
	var items:Array<{name:String}>;
	// var some:Some;
	var someItems:DynamicObject<SomeKey,Some>;
	// @:optional var a:Maybe<SomeKey>;
}

@:enum abstract StateId(String) {
	var Idle = "idle";
	var Building = "building";
}

abstract HeroId(Int) {}

abstract SomeKey(IntKey) to String {}

abstract Some(Array<{a:Int}>) {}
