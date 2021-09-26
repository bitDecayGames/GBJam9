package metrics;

class Trackers {
	public static var attemptTimer = 0.0;
	public static var points(default, set) = 0;

	static function set_points(newP) {
		return newP < 0 ? 0 : newP;
	}
}