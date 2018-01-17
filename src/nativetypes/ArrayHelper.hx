package nativetypes;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.Tools;

class ArrayHelper implements TypeHelper {
	public var targetCT:ComplexType;
	public var nullable = true;

	var elemHelper:TypeHelper;
	var elemOriginalCT:ComplexType;
	var elemTargetCT:ComplexType;

	public function new(gen:Generator, pos:Position, nameContext:NameContext, elemType:Type) {
		elemOriginalCT = elemType.toComplexType();
		elemHelper = gen.generate(elemType, pos, nameContext.element(elemType));
		elemTargetCT = elemHelper.targetCT;
		targetCT = macro : cs.NativeArray<$elemTargetCT>;
	}

	public function generateConvertExpr(sourceExpr:Expr):Expr {
		var elemConvertExpr = elemHelper.generateConvertExpr(macro @:pos(sourceExpr.pos) array[i]);
		return macro @:pos(sourceExpr.pos) {
			var array = $sourceExpr;
			var dst = new cs.NativeArray<$elemTargetCT>(array.length);
			for (i in 0...array.length)
				dst[i] = $elemConvertExpr;
			dst;
		}
	}

	public function generateConvertBackExpr(sourceExpr:Expr):Expr {
		var elemConvertBackExpr = elemHelper.generateConvertBackExpr(macro @:pos(sourceExpr.pos) array[len]);
		return macro @:pos(sourceExpr.pos) {
			var array = $sourceExpr;
			var dst = new Array<$elemOriginalCT>();
			var len = array.Length;
			while (len-- > 0)
				dst[len] = $elemConvertBackExpr;
			dst;
		}
	}

	public function generateDispatchPassThroughExpr(valueExpr:Expr):Expr {
		return macro throw new cs.system.Exception("Invalid passthrough path");
	}
}
#end
