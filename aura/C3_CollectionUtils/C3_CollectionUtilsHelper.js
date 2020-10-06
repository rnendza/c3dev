({
    /**
     * Since sfdc does not return true map from apex. we have to process them like an array.
     * Async version. We should probably deprecate this in favor of getData !.
     *
     * @param mKey
     * @param values
     * @returns callback with value
     * @deprecated
     */
    getMapValue: function(cmp,evt) {
        var params = evt.getParam('arguments');
        if (!params) {
            console.error('-- utilmethods getMapValue.. no arguments found!');
            return;
        }
        var mKey = params.mKey;
        var values = params.values;
        var retValue;
        for (var key in values) {
            if (key === mKey) {
                retValue = values[key];
                break;
            }
        }
        var callback = params.callback;
        callback(retValue);
    },
    /**
     * Since sfdc does not return true map from apex. we have to process them like an array.
     *
     * @param mKey
     * @param values
     * @returns {*}
     */
    getData: function(cmp,evt) {
        let params = evt.getParam('arguments');
        if (!params) {
            console.error('-- Accel_CollectionUtils getMapData.. no arguments found!');
            return;
        }
        let mKey = params.mKey;
        let values = params.values;
        let retValue;
        for (let key in values) {
            if (key === mKey) {
                retValue = values[key];
                break;
            }
        }
        return retValue;
    }
});