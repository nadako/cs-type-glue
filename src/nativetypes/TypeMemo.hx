package nativetypes;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;

abstract TypeMemo(Map<String,Bool>) {
	public inline function new() this = new Map();

	public function define(tp:TypePath):Bool {
		var dotPath = haxe.macro.MacroStringTools.toDotPath(tp.pack, tp.name);
		if (this.exists(dotPath))
			return true;

		var wasDefined = try { Context.getType(dotPath); true; } catch (e:Any) false;
		this.set(dotPath, true);
		return wasDefined;
	}
}
#end
