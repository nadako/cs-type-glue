package nativetypes;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.Tools;

class BasicTypeHelper implements TypeHelper {
	public var targetCT:ComplexType;
	public var nullable:Bool;

	public function new(type:Type, nullable:Bool) {
		targetCT = type.toComplexType();
		this.nullable = nullable;
	}

	public function generateConvertExpr(sourceExpr:Expr):Expr {
		return sourceExpr;
	}

	public function generateConvertBackExpr(sourceExpr:Expr):Expr {
		return sourceExpr;
	}

	public function generateDispatchPassThroughExpr(valueExpr:Expr):Expr {
		return macro throw new cs.system.Exception("Invalid passthrough path");
	}

	public function generateNativeCtorAssign(sourceExpr:Expr):{type:ComplexType, expr:Expr} {
		return {type: targetCT, expr: sourceExpr};
	}
}
#end