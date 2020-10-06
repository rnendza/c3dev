({
    /**
     * Generic wrapper on e.force.showToast
     *
     * @param cmp
     * @param evt - accepts an evt to pass logging criteria.
     */
    displayUiMsg: function (cmp, evt) {
        var params = evt.getParam('arguments');
        if (!params) {
            console.error('-- C3UiMessagingUtilsHelper log.. no arguments found!');
            return;
        }
        var type = params.type;
        var msg = params.msg;
        var mode = params.mode;
        var duration = params.duration;

        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type": type,
            "message": msg,
            "duration": duration,
            "key": 'info_alt',
            "mode": mode
        });
        toastEvent.fire();
    }
})