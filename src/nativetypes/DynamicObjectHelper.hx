package nativetypes;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.Tools;

class DynamicObjectHelper implements TypeHelper {
	public var targetCT:ComplexType;
	public var nullable = true;

	var keyOriginalCT:ComplexType;
	var keyTargetCT:ComplexType;
	var keyHelper:TypeHelper;

	var valueOriginalCT:ComplexType;
	var valueTargetCT:ComplexType;
	var valueHelper:TypeHelper;

	public function new(gen:Generator, pos:Position, nameContext:NameContext, keyType:Type, valueType:Type, type:Type) {
		keyHelper = gen.generate(keyType, pos, null);
		valueHelper = gen.generate(valueType, pos, nameContext.element(valueType));
		keyOriginalCT = keyType.toComplexType();
		keyTargetCT = keyHelper.targetCT;
		valueOriginalCT = valueType.toComplexType();
		valueTargetCT = valueHelper.targetCT;
		targetCT = getTargetCT();
	}

	function getTargetCT():ComplexType {
		return macro : nativetypes.ReactiveDispatchingDictionary<$keyTargetCT, $valueTargetCT>;
	}

	function getStorageInitExpr():Expr {
		var keyConvertExpr = keyHelper.generateConvertExpr(macro (cast key : $keyOriginalCT));
		var valueConvertExpr = valueHelper.generateConvertExpr(macro (value : $valueOriginalCT));

		return macro new nativetypes.ReactiveDispatchingDictionary<$keyTargetCT, $valueTargetCT>(
			(key:String) -> $keyConvertExpr,
			(value:Any) -> $valueConvertExpr
		);
	}

	public function generateConvertExpr(sourceExpr:Expr):Expr {
		var keyConvertExpr = keyHelper.generateConvertExpr(macro @:pos(sourceExpr.pos) key);
		var valueConvertExpr = valueHelper.generateConvertExpr(macro @:pos(sourceExpr.pos) src[key]);
		return macro @:pos(sourceExpr.pos) {
			var src = $sourceExpr;
			var dst = ${getStorageInitExpr()};
			for (key in src.keys())
				dst.set_Item($keyConvertExpr, $valueConvertExpr);
			dst;
		}
	}

	public function generateConvertBackExpr(sourceExpr:Expr):Expr {
		var keyConvertBackExpr = keyHelper.generateConvertBackExpr(macro @:pos(sourceExpr.pos) srcEnum.Current.Key);
		var valueConvertBackExpr = valueHelper.generateConvertBackExpr(macro @:pos(sourceExpr.pos) srcEnum.Current.Value);
		return macro @:pos(sourceExpr.pos) {
			var src = $sourceExpr;
			var srcEnum = src.GetEnumerator();
			var dst = new DynamicObject<$keyOriginalCT, $valueOriginalCT>();
			while (srcEnum.MoveNext()) {
				dst[$keyConvertBackExpr] = $valueConvertBackExpr;
			}
			dst;
		}
	}

	public function generateDispatchPassThroughExpr(valueExpr:Expr):Expr {
		return macro throw new cs.system.Exception("TODO");
	}
}
#end
