package nativetypes;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.Tools;

class AnonClassHelper implements TypeHelper {
	public var targetCT:ComplexType;
	public var nullable = true;

	var typePath:TypePath;

	public function new(gen:Generator, anon:AnonType, pos:Position, nameContext:NameContext) {
		typePath = gen.makeTypePath(nameContext.pack, nameContext.name);
		targetCT = TPath(typePath);

		if (gen.memo.define(typePath))
			return;

		var fields = new Array<Field>();
		var ctorExprs = new Array<Expr>();
		var ctorAssignArgs = new Array<FunctionArg>();
		var ctorAssignExprs = new Array<Expr>();
		var convertBackInitFields = new Array<ObjectField>();
		var convertBackOptionalFieldExprs = new Array<Expr>();
		var dispatchCases = new Array<Case>();

		for (field in anon.fields) {
			var fieldName = field.name;
			var storageName = "_" + fieldName;
			var fieldType = field.type;
			var isOptional = field.meta.has(":optional");

			if (isOptional) {
				switch fieldType {
					case TAbstract(_.toString() => "Null", [realType]):
						fieldType = realType;
					case _:
						throw new Error("Optional field without Null<T> (haxe change?)", field.pos);
				}
			}

			var fieldHelper = gen.generate(fieldType, field.pos, nameContext.field(fieldName, fieldType));
			var fieldTargetCT = fieldHelper.targetCT;

			var convertBackExpr = fieldHelper.generateConvertBackExpr(getFieldValueExpr(storageName));
			if (!isOptional)
				convertBackInitFields.push({field: fieldName, expr: convertBackExpr});
			else
				convertBackOptionalFieldExprs.push(macro if (this.$storageName != null) instance.$fieldName = $convertBackExpr);

			ctorAssignArgs.push({name: fieldName, type: fieldTargetCT});
			ctorAssignExprs.push(getCtorAssignExpr(storageName, macro $i{fieldName}));

			fields.push({
				pos: field.pos,
				name: storageName,
				kind: FVar(getFieldStorageCT(fieldTargetCT)),
				meta: [{name: ":protected", pos: field.pos}]
			});

			var publicCT = getFieldPublicCT(fieldTargetCT);

			fields.push({
				pos: field.pos,
				name: fieldName,
				kind: FProp("get", "never", publicCT),
				meta: [{name: ":property", pos: field.pos}]
			});
			fields.push({
				pos: field.pos,
				name: "get_" + fieldName,
				kind: FFun({
					args: [],
					ret: publicCT,
					expr: macro @:pos(field.pos) return this.$storageName
				}),
				meta: [
					{name: ":protected", pos: field.pos},
					{name: ":final", pos: field.pos},
				]
			});

			var fieldOriginalCT = fieldType.toComplexType();
			var passThroughExpr = fieldHelper.generateDispatchPassThroughExpr(getFieldValueExpr(storageName));
			var passThroughValueExpr = fieldHelper.generateConvertExpr(macro (value : $fieldOriginalCT));
			dispatchCases.push({
				values: [macro $v{fieldName}],
				expr: macro {
					if (passThrough)
						$passThroughExpr;
					else
						${getFieldDispatchExpr(storageName, passThroughValueExpr)};
				},
			});

			var convertExpr = fieldHelper.generateConvertExpr(macro @:pos(field.pos) value.$fieldName);
			ctorExprs.push(getCtorAssignExpr(storageName, convertExpr));
		}

		var originalCT = nameContext.originalType.toComplexType();

		fields.push({
			pos: pos,
			name: "new",
			access: [APublic],
			meta: [{name: ":overload", pos: pos}],
			kind: FFun({
				args: [{name: "value", type: originalCT}],
				ret: null,
				expr: macro $b{ctorExprs},
			})
		});

		fields.push({
			pos: pos,
			name: "new",
			access: [APublic],
			meta: [{name: ":overload", pos: pos}],
			kind: FFun({
				args: ctorAssignArgs,
				ret: null,
				expr: macro $b{ctorAssignExprs},
			})
		});

		fields.push({
			pos: pos,
			name: "toStructure",
			access: [APublic],
			kind: FFun({
				args: [],
				ret: originalCT,
				expr: macro {
					var instance:$originalCT = ${{pos: pos, expr: EObjectDecl(convertBackInitFields)}};
					$b{convertBackOptionalFieldExprs};
					return instance;
				}
			})
		});

		fields.push({
			pos: pos,
			name: "Dispatch",
			access: [APublic],
			kind: FFun({
				args: [
					{name: "path", type: macro : cs.system.collections.generic.Stack_1<String>},
					{name: "value", type: macro : Any},
				],
				ret: macro : Void,
				expr: macro {
					var name = path.Pop();
					var passThrough = path.Count > 0;
					${{
						pos: pos,
						expr: ESwitch(macro name, dispatchCases, macro throw new cs.system.Exception("Invalid dispatching property"))
					}};
				}
			})
		});

		var definition:TypeDefinition = {
			pos: pos,
			pack: typePath.pack,
			name: typePath.name,
			meta: [
				{name: ":nativeGen", pos: pos},
				{name: ":keep", pos: pos},
			],
			kind: TDClass(null, [{pack: ["nativetypes"], name: "IDispatcher"}]),
			fields: fields,
		};

		Context.defineType(definition, nameContext.module);
	}

	function getFieldValueExpr(field:String):Expr {
		return macro this.$field.Value;
	}

	function getCtorAssignExpr(field:String, value:Expr):Expr {
		return macro this.$field = new unirx.ReactiveProperty_1($value);
	}

	function getFieldStorageCT(valueCT:ComplexType):ComplexType {
		return macro : unirx.ReactiveProperty_1<$valueCT>;
	}

	function getFieldPublicCT(valueCT:ComplexType):ComplexType {
		return macro : unirx.IReadOnlyReactiveProperty_1<$valueCT>;
	}

	function getFieldDispatchExpr(field:String, valueExpr:Expr):Expr {
		return macro this.$field.Value = $valueExpr;
	}

	public function generateConvertExpr(sourceExpr:Expr):Expr {
		return macro @:pos(sourceExpr.pos) new $typePath($sourceExpr);
	}

	public function generateConvertBackExpr(sourceExpr:Expr):Expr {
		return macro @:pos(sourceExpr.pos) $sourceExpr.toStructure();
	}

	public function generateDispatchPassThroughExpr(valueExpr:Expr):Expr {
		return macro $valueExpr.Dispatch(path, value);
	}
}
#end
