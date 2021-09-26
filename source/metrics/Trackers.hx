package metrics;

import com.bitdecay.analytics.Bitlytics;

class Trackers {
	public static var attemptTimer = 0.0;
	public static var points(default, set) = 0;

	static function set_points(newP) {
		return points = newP < 0 ? 0 : newP;
	}

	public static var longestDrop(default, set) = 0;

	static function set_longestDrop(newD) {
		if (newD > longestDrop) {
			Bitlytics.Instance().Queue(Metrics.LONGEST_DROP, newD);
			longestDrop = newD;
		}

		return longestDrop;
	}

	public static var landingBonus:Int;
	public static var drops:Array<DropScore>;
}