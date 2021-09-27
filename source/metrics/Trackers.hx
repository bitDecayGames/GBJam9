package metrics;

import com.bitdecay.analytics.Bitlytics;

class Trackers {
	public static var maxLevelCompleted(default, set) = 0;

	static function set_maxLevelCompleted(newM) {
		if (newM > longestDrop) {
			Bitlytics.Instance().Queue(Metrics.MAX_LEVEL_COMPLETED, newM);
			maxLevelCompleted = newM;
		}

		return maxLevelCompleted;
	}

	public static var attemptTimer = 0.0;
	public static var points(default, set) = 0;

	static function set_points(newP) {
		return points = newP < 0 ? 0 : newP;
	}

	// TODO: Use this to record hangtime
	public static var longestDrop(default, set) = 0;

	static function set_longestDrop(newD) {
		if (newD > longestDrop) {
			Bitlytics.Instance().Queue(Metrics.LONGEST_DROP, newD);
			longestDrop = newD;
		}

		return longestDrop;
	}

	public static var landingBonus:Int = 0;
	public static var drops:Array<DropScore> = [];
	public static var houseMax:Int = 0;

	public static var levelScores:Array<String> = [];
}
