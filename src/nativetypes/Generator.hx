package nativetypes;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.Tools;

class Generator {
	var packPrefix:String;

	public var memo(default,null):TypeMemo;

	public function new(packPrefix) {
		this.packPrefix = packPrefix;
		memo = new TypeMemo();
	}

	public function generate(type:Type, pos:Position, nameContext:Null<NameContext>):TypeHelper {
		switch type {
			case TInst(_.get() => cl, params):
				switch [cl, params] {
					case [{pack: [], name: "String"}, _]:
						return new BasicTypeHelper(type, true);

					case [{pack: [], name: "Array"}, [elemType]]:
						return new ArrayHelper(this, pos, nameContext, elemType);

					case _:
				}

			case TAbstract(_.get() => ab, params):
				switch [ab, params] {
					case [{pack: [], name: "Null"}, _]:
						throw new Error("Null<T> is not supported for generating C# glue, use Maybe<T>", pos);

					case [{pack: [], name: "Maybe"}, [realType]]:
						return new MaybeHelper(this, pos, nameContext, realType);

					case [{pack: [], name: "DynamicObject"}, [keyType, valueType]]:
						return new DynamicObjectHelper(this, pos, nameContext, keyType, valueType, type);

					case [{pack: [], name: "IntKey"}, _]:
						return IntKeyHelper.instance;

					case [{pack: [], name: "Choice"}, [anonType]]:
						if (nameContext != null)
							return new ChoiceHelper(this, type, anonType, pos, nameContext);

					case _ if (ab.meta.has(":coreType")):
						return new BasicTypeHelper(type, false);

					case _ if (ab.meta.has(":enum")):
						return new EnumAbstractHelper(this, ab, type);

					case _:
						return new AbstractHelper(this, ab, type);
				}

			case TType(_.get() => dt, params):
				return generate(dt.type, dt.pos, new NameContext(dt.pack, dt.name, dt.module, dt.type));

			case TAnonymous(_.get() => anon) if (nameContext != null):
				return new AnonClassHelper(this, anon, pos, nameContext);

			case _:
		}
		throw new Error('Unsupported type for generating C# glue ${type.toString()}', pos);
	}

	public function makeTypePath(pack:Array<String>, name:String):TypePath {
		return {
			pack: [packPrefix].concat(pack),
			name: name,
		};
	}
}
#end
