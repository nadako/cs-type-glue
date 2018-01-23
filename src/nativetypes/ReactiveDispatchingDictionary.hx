package nativetypes;

import cs.system.collections.generic.Stack_1 as Stack;
import cs.system.collections.generic.Dictionary_2 as Dictionary;
import cs.system.Func_2 as Func;

@:keep
@:nativeGen
class ReactiveDispatchingDictionary<K,V> extends unirx.ReactiveDictionary_2<K,V> implements IDispatcher {
	@:protected var convertKey:Func<String,K>;
	@:protected var convertValue:Func<Any,V>;

	@:overload
	public function new(convertKey:Func<String,K>, convertValue:Func<Any,V>) {
		super();
		this.convertKey = convertKey;
		this.convertValue = convertValue;
	}

	@:overload
	public function new(convertKey:Func<String,K>, convertValue:Func<Any,V>, inner:Dictionary<K,V>) {
		super(inner);
		this.convertKey = convertKey;
		this.convertValue = convertValue;
	}

	@:final
	public function Dispatch(path:Stack<String>, value:Any) {
		var key = convertKey.Invoke(path.Pop());
		var passThrough = path.Count > 0;
		if (passThrough) {
			cast(get_Item(key), IDispatcher).Dispatch(path, value);
		} else if (value == null) {
			Remove(key);
		} else {
			var value = convertValue.Invoke(value);
			set_Item(key, value);
		}
	}
}
