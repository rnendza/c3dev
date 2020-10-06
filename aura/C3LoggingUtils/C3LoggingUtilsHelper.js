({
    /**
     * Generic console logger.
     *
     * @param cmp
     * @param evt - accepts an evt to pass logging criteria.
     */
    log: function (cmp, evt) {
        var params = evt.getParam('arguments');
        if (!params) {
            console.error('-- utilmethods log.. no arguments found!');
            return;
        }
        var cmpName = params.cmpName;
        var level = params.level;
        var msg = cmpName + ' ' + params.msg;
        var obj = params.obj;
        let rtId = params.errorRecordTypeId;
        if (obj === null) {
            obj = [];
        }

        switch (level) {
            case 'debug':
                console.debug(msg, obj);
                break;
            case 'info':
                console.info(msg, obj);
                break;
            case 'warn' :
                console.warn(msg, obj);
                break;
            case 'error' :
                console.error(msg, obj);
                if(cmp.get('v.sendErrorToServer')) {
                    this.sendLogToServer(cmp,msg,obj,rtId);
                }
                break;
            default:
                console.log(msg, obj);
        }
    },
    /**
     * @param cmp
     * @param msg
     * @param obj
     * @param rtId
     */
    sendLogToServer: function (cmp, msg, obj,rtId) {
        let objString = '';
        try {
            objString = JSON.stringify(obj);
        } catch (e) {
            console.error(e);
        }
        let fullMsg = msg + objString;

        // const params = {msg: fullMsg,recordTypeId: rtId};
        // cmp.lax.enqueue('c.logErrorMessage', params)
        //     .then(response => {
        //         let dto = response;
        //         console.log(JSON.stringify(dto));
        //     })
        //     .catch(errors => {
        //         console.error(errors);
        //     });
    },

});