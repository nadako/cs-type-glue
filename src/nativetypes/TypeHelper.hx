package nativetypes;

#if macro
import haxe.macro.Expr;

interface TypeHelper {
	var targetCT(default,never):ComplexType;
	var nullable(default,never):Bool;
	function generateConvertExpr(sourceExpr:Expr):Expr;
	function generateConvertBackExpr(sourceExpr:Expr):Expr;
	function generateDispatchPassThroughExpr(valueExpr:Expr):Expr;
	function generateNativeCtorAssign(sourceExpr:Expr):{type:ComplexType, expr:Expr};
}
#end
