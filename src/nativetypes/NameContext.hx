package nativetypes;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.Tools;

class NameContext {
	public var pack:Array<String>;
	public var name:String;
	public var module:String;
	public var originalType:Type;

	public function new(pack, name, module, originalType) {
		this.pack = pack;
		this.name = name;
		this.module = module;
		this.originalType = originalType;
	}

	public inline function field(fieldName:String, fieldType:Type) {
		return new NameContext(pack, name + "_" + fieldName, module, fieldType);
	}

	public inline function element(elemType:Type) {
		return new NameContext(pack, name + "_element", module, elemType);
	}
}
#end
