package nativetypes;

#if macro
import haxe.macro.Expr;

interface TypeHelper {
	var targetCT(default,never):ComplexType;
	var nullable(default,never):Bool;
	function generateConvertExpr(sourceExpr:Expr):Expr;
	function generateConvertBackExpr(sourceExpr:Expr):Expr;
}
#end
