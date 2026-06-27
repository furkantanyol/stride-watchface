using Toybox.Application as App;
using Toybox.WatchUi as Ui;

class StrideApp extends App.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state) {
    }

    function onStop(state) {
    }

    function getInitialView() {
        return [ new StrideView() ];
    }

    // The phone pushed new settings. Repaint so the change is visible.
    function onSettingsChanged() {
        Ui.requestUpdate();
    }
}
