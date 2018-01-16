#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.Tools;
#end

abstract Choice<T:{}>(T) from T {
	public macro function match(self, body:ExprOf<{}>) {
		var tself = Context.typeExpr(self);
		var fields = switch (tself.t.follow()) {
			case TAbstract(_, [_.follow() => TAnonymous(_.get() => anon)]):
				anon.fields;
			case t:
				throw new Error("Choice can only be used on JSON structures, got " + t.toString(), self.pos);
		}
		var types = [for (f in fields) f.name => f.type];
		var unused = [for (f in fields) f.name];

		var bodyExpr = switch (body.expr) {
			case EDisplay(e, _): e.expr;
			case other: other;
		}

		var cases = [];
		var def = null;
		switch (bodyExpr) {
			case EBlock([]):
			case EObjectDecl(fields):
				for (f in fields) {
					var fieldName = f.field;
					if (fieldName == "_")
						def = f.expr;
					else {
						var type = types[fieldName];
						if (type == null)
							throw new Error("Invalid match type: " + fieldName, f.expr.pos);

						var ct = (switch (type) {
							case TAbstract(_.toString() => "Null", [realType]): realType;
							default: type;
						}).toComplexType();

						cases.push({
							values: [macro $v{fieldName}],
							expr: macro {
								var value:$ct = (@:privateAccess choice.toT()).$fieldName;
								${f.expr};
							},
						});
						unused.remove(fieldName);
					}
				}
			default:
				throw new Error("Invalid match body " + body.toString(), body.pos);
		}

		if (def == null) {
			if (unused.length > 0)
				throw new Error("Unmatched choices: " + unused.join(", "), body.pos);
			else
				def = macro @:pos(body.pos) throw "invalid choice";
		}

		return macro {
			var choice = ${Context.storeTypedExpr(tself)}; // tempvar the choice (will be fused back if possible)
			${{expr: ESwitch(macro @:privateAccess choice.firstFieldName(), cases, def), pos: body.pos}};
		};
	}

	#if js
	function firstFieldName():String untyped {
		__js__("for (var k in {0}) return k", this);
		return null;
	}
	#else
	inline function firstFieldName():String {
		return Reflect.fields(this)[0];
	}
	#end

	@:extern inline function toT():T {
		return this;
	}
}
