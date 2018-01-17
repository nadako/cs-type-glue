package nativetypes;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.Tools;

class EnumAbstractHelper implements TypeHelper {
	public var targetCT:ComplexType;
	public var nullable = false;

	var cases:Array<Case>;
	var backCases:Array<Case>;

	public function new(gen:Generator, ab:AbstractType) {
		var typePath = gen.makeTypePath(ab.pack, ab.name);
		targetCT = TPath(typePath);

		var targetTPExpr = macro @:pos(ab.pos) $p{typePath.pack.concat([typePath.name])};
		var sourceTPExpr = macro @:pos(ab.pos) $p{ab.module.split(".").concat([ab.name])};

		var fields = new Array<Field>();

		// TODO: стоит генерить хелпер-класс для конвертации
		cases = new Array<Case>();
		backCases = new Array<Case>();

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

		if (gen.memo.define(typePath))
			return;

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
		return {
			pos: sourceExpr.pos,
			expr: ESwitch(sourceExpr, cases, macro @:pos(sourceExpr.pos) throw "Invalid value")
		};
	}

	public function generateConvertBackExpr(sourceExpr:Expr):Expr {
		return {
			pos: sourceExpr.pos,
			expr: ESwitch(sourceExpr, backCases, macro @:pos(sourceExpr.pos) throw "Invalid value")
		};
	}
}
#end
