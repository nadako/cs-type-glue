package nativetypes;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.Tools;

class MaybeHelper implements TypeHelper {
	public var targetCT:ComplexType;
	public var nullable = false;

	var helper:TypeHelper;

	public function new(gen:Generator, pos:Position, nameContext:NameContext, realType:Type) {
		helper = gen.generate(realType, pos, nameContext);
		if (helper.nullable) {
			targetCT = helper.targetCT;
		} else {
			var ct = helper.targetCT;
			targetCT = macro : cs.system.Nullable_1<$ct>;
		}
	}

	public function generateConvertExpr(sourceExpr:Expr):Expr {
		var convertExpr = helper.generateConvertExpr(macro @:pos(sourceExpr.pos) v);
		if (!helper.nullable)
			convertExpr = macro @:pos(sourceExpr.pos) new cs.system.Nullable_1($convertExpr);
		return macro @:pos(sourceExpr.pos) $sourceExpr.mapDefault(v -> $convertExpr, null);
	}

	public function generateConvertBackExpr(sourceExpr:Expr):Expr {
		if (helper.nullable)
			return helper.generateConvertBackExpr(sourceExpr);

		var convertBackExpr = helper.generateConvertBackExpr(macro v.Value);
		return macro {var v = $sourceExpr; if (v.HasValue) $convertBackExpr else null; }
	}

	public function generateDispatchPassThroughExpr(valueExpr:Expr):Expr {
		return helper.generateDispatchPassThroughExpr(if (helper.nullable) valueExpr else macro $valueExpr.Value);
	}
}
#end
