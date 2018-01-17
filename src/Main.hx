#if macro
import haxe.macro.Context;

class Main {
	static function main() {
		new nativetypes.Generator("slapi").generate(Context.getType("rambo.GameData"), Context.currentPos(), null);
	}
}
#end
