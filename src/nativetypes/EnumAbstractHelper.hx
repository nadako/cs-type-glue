package nativetypes;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.Tools;

class EnumAbstractHelper implements TypeHelper {
	static inline var HELPER_POSTFIX = "__Helper";

	public var targetCT:ComplexType;
	public var nullable = false;

	var helperTypePathExpr:Expr;

	public function new(gen:Generator, ab:AbstractType, type:Type) {
		var typePath = gen.makeTypePath(ab.pack, ab.name);
		targetCT = TPath(typePath);

		var helperClassName = typePath.name + HELPER_POSTFIX;
		helperTypePathExpr = macro $p{typePath.pack.concat([helperClassName])};

		if (gen.memo.define(typePath))
			return;

		var originalCT = type.toComplexType();
		var targetTPExpr = macro @:pos(ab.pos) $p{typePath.pack.concat([typePath.name])};
		var sourceTPExpr = macro @:pos(ab.pos) $p{ab.module.split(".").concat([ab.name])};

		var fields = new Array<Field>();

		var cases = new Array<Case>();
		var backCases = new Array<Case>();

		for (field in ab.impl.get().statics.get()) {
			if (field.meta.has(":enum") && field.meta.has(":impl")) {
				var fieldName = field.name;

				fields.push({
					pos: field.pos,
					name: fieldName,
					kind: FVar(null, null)
				});

				var sourceQualifiedNameExpr = macro @:pos(field.pos) $sourceTPExpr.$fieldName;
				var targetQualifiedNameExpr = macro @:pos(field.pos) $targetTPExpr.$fieldName;

				cases.push({
					values: [sourceQualifiedNameExpr],
					expr: targetQualifiedNameExpr
				});

				backCases.push({
					values: [targetQualifiedNameExpr],
					expr: sourceQualifiedNameExpr
				});
			}
		}

		var definition = macro class $helperClassName {
			public static function toNative(value:$originalCT):$targetCT {
				return ${{
					pos: ab.pos,
					expr: ESwitch(macro value, cases, macro throw new cs.system.Exception("Invalid value"))
				}};
			}

			public static function fromNative(value:$targetCT):$originalCT {
				return ${{
					pos: ab.pos,
					expr: ESwitch(macro value, backCases, macro throw new cs.system.Exception("Invalid value"))
				}};
			}
		};
		definition.pack = typePath.pack;
		definition.meta = [
			{name: ":nativeGen", pos: ab.pos},
			{name: ":keep", pos: ab.pos},
		];
		Context.defineType(definition, ab.module);

		var definition:TypeDefinition = {
			pos: ab.pos,
			pack: typePath.pack,
			name: typePath.name,
			meta: [
				{name: ":nativeGen", pos: ab.pos},
				{name: ":keep", pos: ab.pos},
			],
			kind: TDEnum,
			fields: fields,
		};

		Context.defineType(definition, ab.module);
	}

	public function generateConvertExpr(sourceExpr:Expr):Expr {
		return macro $helperTypePathExpr.toNative($sourceExpr);
	}

	public function generateConvertBackExpr(sourceExpr:Expr):Expr {
		return macro $helperTypePathExpr.fromNative($sourceExpr);
	}
}
#end
