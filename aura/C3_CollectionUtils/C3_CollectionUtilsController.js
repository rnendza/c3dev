({
    /**
     *
     * @param cmp
     * @param evt
     * @param helper
     * @deprecated
     */
    getMapValue: function (cmp,evt,helper) {
        helper.getMapValue(cmp,evt);
    },
    /**
     * Sync version of the above.
     *
     * @param cmp
     * @param evt
     * @param helper
     */
    getData: function (cmp,evt,helper) {
        return helper.getData(cmp,evt);
    }
});