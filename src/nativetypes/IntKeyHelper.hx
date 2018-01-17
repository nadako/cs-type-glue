package nativetypes;

#if macro
import haxe.macro.Expr;

class IntKeyHelper implements TypeHelper {
	public static var instance = new IntKeyHelper();

	public var targetCT:ComplexType;
	public var nullable = false;

	public function new() {
		targetCT = macro : Int;
	}

	public function generateConvertExpr(sourceExpr:Expr):Expr {
		return macro @:pos(sourceExpr.pos) ($sourceExpr : Int);
	}

	public function generateConvertBackExpr(sourceExpr:Expr):Expr {
		return macro ($sourceExpr : IntKey);
	}

	public function generateDispatchPassThroughExpr(valueExpr:Expr):Expr {
		return macro throw new cs.system.Exception("Invalid passthrough path");
	}
}
#end
