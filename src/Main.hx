#if macro
import haxe.macro.Context;
using haxe.macro.ExprTools;

class Main {
	static function main() {
		var helper = new nativetypes.Generator("slapi").generate(Context.getType("rambo.GameData"), Context.currentPos(), null);
		trace(helper.generateConvertBackExpr(macro null).toString());
	}
}
#end
