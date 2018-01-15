abstract Maybe<T>(Null<T>) from Null<T> {
	public inline function mapDefault<S>(f:T->S, def:S):S {
		return if (this != null) f(this) else def;
	}
}
