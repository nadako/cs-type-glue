package nativetypes;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.Tools;

class AbstractHelper implements TypeHelper {
	public var targetCT:ComplexType;
	public var nullable = false;

	var typePath:TypePath;
	var underlyingHelper:TypeHelper;
	var originalCT:ComplexType;

	public function new(gen:Generator, ab:AbstractType, type:Type) {
		typePath = gen.makeTypePath(ab.pack, ab.name);
		targetCT = TPath(typePath);

		originalCT = type.toComplexType();

		var underlyingType = ab.type;
		var underlyingCT = underlyingType.toComplexType();
		underlyingHelper = gen.generate(underlyingType, ab.pos, new NameContext(ab.pack, ab.name + "_underlying", ab.module, underlyingType));

		if (gen.memo.define(typePath))
			return;

		var convertExpr = underlyingHelper.generateConvertExpr(macro (cast value : $underlyingCT));

		var fields = new Array<Field>();

		fields.push({
			pos: ab.pos,
			name: "Value",
			meta: [{name: ":readOnly", pos: ab.pos}],
			access: [APublic],
			kind: FProp("default", "never", underlyingHelper.targetCT, null)
		});

		fields.push({
			pos: ab.pos,
			name: "new",
			access: [APublic],
			kind: FFun({
				args: [{name: "value", type: originalCT}],
				ret: null,
				expr: macro @:pos(ab.pos) untyped this.Value = $convertExpr,
			})
		});

		var definition:TypeDefinition = {
			pos: ab.pos,
			pack: typePath.pack,
			name: typePath.name,
			meta: [
				{name: ":struct", pos: ab.pos},
				{name: ":keep", pos: ab.pos},
			],
			kind: TDClass(),
			fields: fields,
		};

		Context.defineType(definition, ab.module);
	}

	public function generateConvertExpr(sourceExpr:Expr):Expr {
		return macro @:pos(sourceExpr.pos) new $typePath($sourceExpr);
	}

	public function generateConvertBackExpr(sourceExpr:Expr):Expr {
		var convertBackExpr = underlyingHelper.generateConvertBackExpr(macro $sourceExpr.Value);
		return macro (cast $convertBackExpr : $originalCT);
	}
}
#end
