using Toybox.ActivityMonitor as Act;
using Toybox.SensorHistory as SensorHistory;
using Toybox.Weather as Weather;
using Toybox.Lang as Lang;

// Reads the secondary, motivating metrics shown beneath the bars. Every read
// is guarded: a missing sensor, a disconnected phone, or an empty history
// returns null, and the view simply omits that readout. None of these cost
// battery — they read values the system has already collected or cached.
module Metrics {

    // Hours of recovery remaining, or null until a recent activity sets it.
    function recoveryHours() as Lang.Number? {
        var info = Act.getInfo();
        if (info != null && info has :timeToRecovery && info.timeToRecovery != null) {
            return info.timeToRecovery;
        }
        return null;
    }

    // Latest Body Battery (0-100), or null if unsupported / no data.
    function bodyBattery() as Lang.Number? {
        if (!(Toybox has :SensorHistory) || !(SensorHistory has :getBodyBatteryHistory)) {
            return null;
        }
        var iter = SensorHistory.getBodyBatteryHistory({ :period => 1, :order => SensorHistory.ORDER_NEWEST_FIRST });
        var sample = (iter != null) ? iter.next() : null;
        if (sample != null && sample.data != null) {
            return sample.data.toNumber();
        }
        return null;
    }

    // Current temperature in Celsius, or null if no cached weather.
    function temperature() as Lang.Number? {
        if (!(Toybox has :Weather)) {
            return null;
        }
        var conditions = Weather.getCurrentConditions();
        if (conditions != null && conditions.temperature != null) {
            return conditions.temperature.toNumber();
        }
        return null;
    }
}
