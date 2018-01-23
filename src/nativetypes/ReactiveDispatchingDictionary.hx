package nativetypes;

import cs.system.collections.generic.Stack_1 as Stack;
import cs.system.collections.generic.Dictionary_2 as Dictionary;

@:keep
@:nativeGen
class ReactiveDispatchingDictionary<K,V> extends unirx.ReactiveDictionary_2<K,V> implements IDispatcher {
	@:protected var helper:DictionaryHelper<K,V>;

	@:overload
	public function new(helper:DictionaryHelper<K,V>, source:Any) {
		super();
		this.helper = helper;
		for (field in Reflect.fields(source)) {
			set_Item(helper.convertKey(field), helper.convertValue(Reflect.field(source, field)));
		}
	}

	@:overload
	public function new(helper:DictionaryHelper<K,V>, inner:Dictionary<K,V>) {
		super(inner);
		this.helper = helper;
	}

	@:final
	public function Dispatch(path:Stack<String>, value:Any) {
		var key = helper.convertKey(path.Pop());
		var passThrough = path.Count > 0;
		if (passThrough) {
			cast(get_Item(key), IDispatcher).Dispatch(path, value);
		} else if (value == null) {
			Remove(key);
		} else {
			var value = helper.convertValue(value);
			set_Item(key, value);
		}
	}

	@:final
	public function toDynamicObject():Any {
		var result = {};
		var enumerator:cs.system.collections.generic.Dictionary_2.Dictionary_2_Enumerator<K,V> = GetEnumerator();
		while (enumerator.MoveNext())
			Reflect.setField(result, helper.convertKeyBack(enumerator.Current.Key), helper.convertValueBack(enumerator.Current.Value));
		return result;
	}
}

@:nativeGen
interface DictionaryHelper<K,V> {
	function convertKey(key:String):K;
	function convertKeyBack(key:K):String;
	function convertValue(value:Any):V;
	function convertValueBack(value:V):Any;
}
