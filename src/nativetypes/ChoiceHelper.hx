package nativetypes;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.Tools;

class ChoiceHelper implements TypeHelper {
	public var targetCT:ComplexType;
	public var nullable = true;

	var typePath:TypePath;

	public function new(gen:Generator, type:Type, anonType:Type, pos:Position, nameContext:NameContext) {
		typePath = gen.makeTypePath(nameContext.pack, nameContext.name);
		targetCT = TPath(typePath);

		if (gen.memo.define(typePath))
			return;

		var fields = new Array<Field>();
		var matchFields = new Array<ObjectField>();

		var matchMethodArgs = new Array<FunctionArg>();
		var matchMethodTArgs = new Array<FunctionArg>();
		var matchMethodCases = new Array<Case>();

		var toStructureCases = new Array<Case>();

		var anon = switch anonType {
			case TAnonymous(_.get() => anon): anon;
			case _: throw new Error("Choice over a non-anonymous-struct type", pos);
		};

		var index = 0;
		for (field in anon.fields) {
			var fieldIndex = index++;
			var fieldName = field.name;
			var storageName = "_" + fieldName;

			if (!field.meta.has(":optional"))
				throw new Error("Choice fields must be @:optional", field.pos);

			var fieldType = switch field.type {
				case TAbstract(_.toString() => "Null", [realType]): realType;
				case type: type;
			}

			var fieldHelper = gen.generate(fieldType, field.pos, nameContext.field(fieldName, fieldType));
			var fieldTargetCT = fieldHelper.targetCT;

			fields.push({
				pos: field.pos,
				name: storageName,
				kind: FVar(fieldTargetCT),
				meta: [{name: ":protected", pos: field.pos}]
			});

			fields.push({
				pos: field.pos,
				name: fieldName,
				access: [APublic, AStatic],
				kind: FFun({
					args: [{name: "value", type: fieldTargetCT}],
					ret: targetCT,
					expr: macro {
						var instance = new $typePath();
						instance.__index = $v{fieldIndex};
						instance.$storageName = value;
						return instance;
					}
				})
			});

			var fieldConvertExpr = fieldHelper.generateConvertExpr(macro value);

			matchFields.push({
				field: fieldName,
				expr: macro {
					this.__index = $v{fieldIndex};
					this.$storageName = $fieldConvertExpr;
				}
			});

			matchMethodArgs.push({
				name: fieldName,
				type: macro : cs.system.Action_1<$fieldTargetCT>
			});
			matchMethodCases.push({
				values: [macro $v{fieldIndex}],
				expr: macro $i{fieldName}.Invoke(this.$storageName)
			});

			matchMethodTArgs.push({
				name: fieldName,
				type: macro : cs.system.Func_2<$fieldTargetCT,TResult>
			});

			var fieldConvertBackExpr = fieldHelper.generateConvertBackExpr(macro this.$storageName);

			toStructureCases.push({
				values: [macro $v{fieldIndex}],
				expr: macro {$fieldName: $fieldConvertBackExpr}
			});
		}

		fields.push({
			pos: pos,
			name: "__index",
			kind: FVar(macro : Int),
			meta: [{name: ":protected", pos: pos}]
		});


		var matchMethodExpr = {
			pos: pos,
			expr: ESwitch(macro this.__index, matchMethodCases, macro throw new cs.system.Exception("Invalid variant"))
		};

		fields.push({
			pos: pos,
			name: "Match",
			meta: [
				{name: ":final", pos: pos},
				{name: ":overload", pos: pos}
			],
			kind: FFun({
				args: matchMethodArgs,
				ret: macro : Void,
				expr: matchMethodExpr
			}),
		});

		var matchMethodTExpr = {
			pos: pos,
			expr: ESwitch(macro this.__index, matchMethodCases, macro throw new cs.system.Exception("Invalid variant"))
		};

		fields.push({
			pos: pos,
			name: "Match",
			meta: [
				{name: ":final", pos: pos},
				{name: ":overload", pos: pos}
			],
			kind: FFun({
				args: matchMethodTArgs,
				ret: macro : TResult,
				expr: macro return $matchMethodTExpr,
				params: [{name: "TResult"}],
			}),
		});

		var originalCT = type.toComplexType();
		var matchExpr = {
			pos: pos,
			expr: EObjectDecl(matchFields)
		};

		fields.push({
			pos: pos,
			name: "new",
			access: [APublic],
			meta: [{name: ":overload", pos: pos}],
			kind: FFun({
				args: [{name: "value", type: originalCT}],
				ret: null,
				expr: macro value.match($matchExpr),
			})
		});

		fields.push({
			pos: pos,
			name: "new",
			access: [APublic],
			meta: [
				{name: ":overload", pos: pos},
				{name: ":protected", pos: pos},
			],
			kind: FFun({
				args: [],
				ret: null,
				expr: macro {},
			})
		});

		var toStructureSwitchExpr = {
			pos: pos,
			expr: ESwitch(macro this.__index, toStructureCases, macro throw new cs.system.Exception("Invalid variant"))
		};

		fields.push({
			pos: pos,
			name: "toStructure",
			access: [APublic],
			meta: [{name: ":final", pos: pos}],
			kind: FFun({
				args: [],
				ret: originalCT,
				expr: macro return $toStructureSwitchExpr,
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
			kind: TDClass(),
			fields: fields,
		};

		Context.defineType(definition, nameContext.module);
	}

	public function generateConvertExpr(sourceExpr:Expr):Expr {
		return macro new $typePath($sourceExpr);
	}

	public function generateConvertBackExpr(sourceExpr:Expr):Expr {
		return macro $sourceExpr.toStructure();
	}
}
#end
