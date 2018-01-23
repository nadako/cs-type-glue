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

	var dictHelperTpExpr:Expr;

	public function new(gen:Generator, pos:Position, nameContext:NameContext, keyType:Type, valueType:Type, type:Type) {
		keyHelper = gen.generate(keyType, pos, null);
		valueHelper = gen.generate(valueType, pos, nameContext.element(valueType));
		keyOriginalCT = keyType.toComplexType();
		keyTargetCT = keyHelper.targetCT;
		valueOriginalCT = valueType.toComplexType();
		valueTargetCT = valueHelper.targetCT;
		targetCT = macro : nativetypes.ReactiveDispatchingDictionary<$keyTargetCT, $valueTargetCT>;

		var dictHelperTypePath = gen.makeTypePath(nameContext.pack, nameContext.name + "__DictionaryHelper");
		dictHelperTpExpr = macro $p{dictHelperTypePath.pack.concat([dictHelperTypePath.name])}.instance;
		if (gen.memo.define(dictHelperTypePath))
			return;

		var keyConvertExpr = keyHelper.generateConvertExpr(macro (cast key : $keyOriginalCT));
		var valueConvertExpr = valueHelper.generateConvertExpr(macro (value : $valueOriginalCT));
		var keyConvertBackExpr = keyHelper.generateConvertBackExpr(macro key);
		var valueConvertBackExpr = valueHelper.generateConvertBackExpr(macro value);

		var dictHelperName = dictHelperTypePath.name;
		var dictHelperDefinition = macro class $dictHelperName implements nativetypes.ReactiveDispatchingDictionary.DictionaryHelper<$keyTargetCT, $valueTargetCT> {
			public static var instance = new $dictHelperTypePath();
			@:protected function new() {}
			public function convertKey(key:String):$keyTargetCT return $keyConvertExpr;
			public function convertKeyBack(key:$keyTargetCT):String return $keyConvertBackExpr;
			public function convertValue(value:Any):$valueTargetCT return $valueConvertExpr;
			public function convertValueBack(value:$valueTargetCT):Any return $valueConvertBackExpr;
		};
		dictHelperDefinition.pack = dictHelperTypePath.pack;
		dictHelperDefinition.meta = [
			{pos: pos, name: ":nativeGen"},
			{pos: pos, name: ":final"},
		];
		Context.defineType(dictHelperDefinition, nameContext.module);
	}

	public function generateNativeCtorAssign(sourceExpr:Expr):{type:ComplexType, expr:Expr} {
		return {
			type: macro : cs.system.collections.generic.Dictionary_2<$keyTargetCT, $valueTargetCT>,
			expr: macro new nativetypes.ReactiveDispatchingDictionary<$keyTargetCT, $valueTargetCT>($dictHelperTpExpr, $sourceExpr)
		};
	}

	public function generateConvertExpr(sourceExpr:Expr):Expr {
		return macro new nativetypes.ReactiveDispatchingDictionary<$keyTargetCT, $valueTargetCT>($dictHelperTpExpr, $sourceExpr);
	}

	public function generateConvertBackExpr(sourceExpr:Expr):Expr {
		return macro $sourceExpr.toDynamicObject();
	}

	public function generateDispatchPassThroughExpr(valueExpr:Expr):Expr {
		return macro $valueExpr.Dispatch(path, value);
	}
}
#end
