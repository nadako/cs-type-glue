package nativetypes;

import cs.system.collections.generic.Stack_1 as Stack;

@:nativeGen
interface IDispatcher {
	function Dispatch(path:Stack<String>, value:Any):Void;
}
