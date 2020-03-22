const _internalLog = Symbol('internalLog'); // private method

export default class Logger {

    _debugConsole = false;

    /**
     * Toggle console logging on and off..
     * @param debugIt
     */
    constructor(debugIt) {
        this._debugConsole = debugIt;
    }

    /**
     *
     * @param msg
     * @param obj
     */
    logDebug(msg,obj) {
        this[_internalLog](msg,'debug',obj);
    }
    /**
     * @param msg
     * @param obj
     */
    logInfo(msg,obj) {
        this[_internalLog](msg,'info',obj);
    }
    /**
     * @param msg
     * @param obj
     */
    logWarn(msg,obj) {
        this[_internalLog](msg,'warn',obj);
    }
    /**
     * @param msg
     * @param obj
     */
    logError(msg,obj) {
        this[_internalLog](msg,'error',obj);
    }
    /**
     * @param msg
     * @param obj
     */
    log(msg,obj) {
        this[_internalLog](msg,'',obj);
    }

    //------------------ private / internal methods

    /**
     * PRIVATE
     * @param msg
     * @param type
     * @param obj
     */
    [_internalLog](msg,type,obj) {
        let fullMsg = 'Accel Salesforce  - '+msg + ': ';
        let output = '';

        if(obj) {
            output = JSON.parse(JSON.stringify(obj));
        }
        switch (type) {
            case 'debug':
                if (this._debugConsole) {
                    console.debug(fullMsg,output);
                }
                break;
            case 'warn':
                if (this._debugConsole) {
                    console.warn(fullMsg,output);
                }
                break;
            case 'info':
                if (this._debugConsole) {
                    console.info(fullMsg,output);
                }
                break;
            case 'error':
                if (this._debugConsole) {
                    console.error(fullMsg,output);
                }
                break;
            default:
                if(this._debugConsole) {
                    console.log(fullMsg, output);
                }
        }
    }

}