abstract DynamicObject<K:String,V>(Dynamic<V>) {
	public inline function new() this = {};
	public inline function keys():Array<K> return cast Reflect.fields(this);
	@:op([]) inline function get(key:K):Null<V> return Reflect.field(this, key);
	@:op([]) inline function set(key:K, value:V) Reflect.setField(this, key, value);
}
