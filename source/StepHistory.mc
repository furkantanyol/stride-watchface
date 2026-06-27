using Toybox.Application.Storage as Storage;
using Toybox.Lang as Lang;

// Self-logged rolling history of the last seven days' step totals. Connect IQ
// does not reliably hand a watch face previous-day totals, so Stride records
// its own: each render writes today's live count into the newest slot. Older
// slots keep the last value written while they were "today" — their end-of-day
// total. Deterministic, and survives a reinstall by simply starting fresh.
module StepHistory {

    const DAYS = 7;

    // ponytail: TEMP demo week so the bars are visible in the simulator (which
    // can't backfill history). Set false for real use — the line below is the
    // only thing to remove.
    const DEMO = false;

    // Returns an array of DAYS step totals, oldest first, newest (today) last.
    // `dayNumber` is a local day index (whole days since the epoch).
    function lastSevenDays(todaySteps as Lang.Number, dayNumber as Lang.Number) as Lang.Array<Lang.Number> {
        if (DEMO) {
            return [7300, 11200, 9100, 12400, 6800, 10300, todaySteps > 0 ? todaySteps : 8600];
        }
        var data = Storage.getValue("history") as Lang.Dictionary?;
        var values = newWindow();
        var lastDay = null;
        if (data != null) {
            values = data["values"] as Lang.Array<Lang.Number>;
            lastDay = data["lastDay"] as Lang.Number;
        }

        if (lastDay != null) {
            shiftForward(values, dayNumber - lastDay);
        }
        values[DAYS - 1] = todaySteps;

        Storage.setValue("history", { "lastDay" => dayNumber, "values" => values });
        return values;
    }

    function newWindow() as Lang.Array<Lang.Number> {
        return [0, 0, 0, 0, 0, 0, 0];
    }

    // Slide the window left by `gap` days, dropping old days and zero-filling
    // the new ones. A gap of 0 leaves it unchanged; a gap >= DAYS clears it.
    function shiftForward(values as Lang.Array<Lang.Number>, gap as Lang.Number) as Void {
        if (gap <= 0) { return; }
        for (var i = 0; i < DAYS; i += 1) {
            var source = i + gap;
            values[i] = (source < DAYS) ? values[source] : 0;
        }
    }
}
