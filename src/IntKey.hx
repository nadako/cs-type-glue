abstract IntKey(String) to String {
	@:from inline static function fromInt(i:Int):IntKey return cast "" + i;
	@:to inline function toInt():Int return Std.parseInt(this);
}
