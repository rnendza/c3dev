const _internalLog = Symbol('internalLog'); // private method

Object.assign(String.prototype, {
    hardWrap(n, hyphen, br) {
        var str1, tem, ax, diff, lim, S = [];
        var A = this.split(/\\s*/);
        n = n || 50;
        hyphen = hyphen || n * 2;
        hyphen = Math.floor(hyphen / 2);
        while (A.length) {
            str1 = A.shift();
            while (str1 && str1.length > n) {
                if (ax === 0 && /^\\S/.test(str1)) S[S.length - 1] += '-';
                tem = str1.substring(0, n);
                ax = tem.lastIndexOf(' ') + 1;
                if (ax === 0) {
                    S.push(str1.substring(0, n - 1));
                    str1 = str1.substring(n - 1);
                } else {
                    tem = str1.substring(0, ax);
                    diff = n - ax;
                    if (diff > hyphen) {
                        lim = ax + hyphen;
                        while (ax < lim && /\\w/.test(str1.charAt(ax))) ++ax;
                        tem = str1.substring(0, ax) + '-';
                    }
                    str1 = str1.substring(ax);
                    S.push(tem);
                }
            }
            if (str1) S.push(str1);
        }
        //br = br ? '<br>' : '';
        return S.join(br);

    }
});

export default class C3Utils {

    _debugConsole = false;
    _mobile = 767;
    _desktop = 768;


    DESKTOP_CHART_WIDTH = this._desktop;
    DESKTOP_DATATABLE_WIDTH = this._desktop;
    DESKTOP_FORM_WIDTH = this._desktop;

    MOBILE_CHART_WIDTH = this._mobile;
    MOBILE_DATATABLE_WIDTH = this._mobile;
    MOBILE_FORM_WIDTH = this._mobile;

    /**
     *
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
    logDebug(msg, obj) {
        this[_internalLog](msg, 'debug', obj);
    }

    /**
     *
     * @param msg
     * @param obj
     */
    logInfo(msg, obj) {
        this[_internalLog](msg, 'info', obj);
    }

    /**
     *
     * @param msg
     * @param obj
     */
    logWarn(msg, obj) {
        this[_internalLog](msg, 'warn', obj);
    }

    /**
     *
     * @param msg
     * @param obj
     */
    logError(msg, obj) {
        this[_internalLog](msg, 'error', obj);
    }

    /**
     *
     * @param msg
     * @param obj
     */
    log(msg, obj) {
        this[_internalLog](msg, '', obj);
    }

    /**
     *
     * @param mKey
     * @param values
     * @returns {*}
     */
    getMapValue(mKey, values) {
        let retValue;
        for (let key in values) {
            if (key === mKey) {
                retValue = values[key];
                break;
            }
        }
        return retValue;
    }

    /**
     *
     * @param arr
     * @returns {any}
     */
    findArrayMedian(arr) {
        const mid = Math.floor(arr.length / 2), nums = [...arr].sort((a, b) => a - b);
        return arr.length % 2 !== 0 ? nums[mid] : (nums[mid - 1] + nums[mid]) / 2;
    }

    /**
     * PRIVATE
     * @param msg
     * @param type
     * @param obj
     */
    [_internalLog](msg, type, obj) {
        let fullMsg = 'C3 - ' + msg + ': ';
        let output = '';

        if (obj) {
            output = JSON.parse(JSON.stringify(obj));
        }
        switch (type) {
            case 'debug':
                if (this._debugConsole) {
                    console.debug(fullMsg, output);
                }
                break;
            case 'warn':
                if (this._debugConsole) {
                    console.warn(fullMsg, output);
                }
                break;
            case 'info':
                if (this._debugConsole) {
                    console.info(fullMsg, output);
                }
                break;
            case 'error':
                if (this._debugConsole) {
                    console.error(fullMsg, output);
                }
                break;
            default:
                if (this._debugConsole) {
                    console.log(fullMsg, output);
                }
        }
    }

    /**
     *
     * @returns string style overrides.
     */
    overrideTooltipClass() {
        let style = '.slds-popover__tooltip, .slds-popover--tooltip { color:white; }';
        return style;
    }

    /**
     * Reduces one or more LDS errors into a string[] of error messages.
     * @param {FetchResponse|FetchResponse[]} errors
     * @return {String[]} Error messages
     */
    reduceErrors(errors) {
        if (!Array.isArray(errors)) {
            errors = [errors];
        }

        return (
            errors
                // Remove null/undefined items
                .filter(error => !!error)
                // Extract an error message
                .map(error => {
                    // UI API read errors
                    if (Array.isArray(error.body)) {
                        return error.body.map(e => e.message);
                    }
                    // UI API DML, Apex and network errors
                    else if (error.body && typeof error.body.message === 'string') {
                        return error.body.message;
                    }
                    // JS errors
                    else if (typeof error.message === 'string') {
                        return error.message;
                    }
                    // Unknown error shape so try HTTP status text
                    return error.statusText;
                })
                // Flatten
                .reduce((prev, curr) => prev.concat(curr), [])
                // Remove empty strings
                .filter(message => !!message)
        );
    }

    /**
     * This will allow the use of tokens and in custom labels.
     *
     * Usage:
     * StringHelpers.format("{0}{1}", "a", "b")
     * or StringHelpers.format("{0}{1}", ["a", "b"])
     *
     * @type {{format: AccelUtilsSvc.StringHelpers.format}}
     */
    StringHelpers = {
        format: function (format, args) {
            let i;
            if (args instanceof Array) {
                for (i = 0; i < args.length; i++) {
                    format = format.replace(new RegExp('\\{' + i + '\\}', 'gm'), args[i]);
                }
                return format;
            }
            for (i = 0; i < arguments.length - 1; i++) {
                format = format.replace(new RegExp('\\{' + i + '\\}', 'gm'), arguments[i + 1]);
            }
            return format;
        },
        /**
         *
         * @param str
         * @returns {string}
         */
        titleCase: function (str) {
            return str.split(' ').map(item =>
                item.charAt(0).toUpperCase() + item.slice(1).toLowerCase()).join(' ');
        }
    };

    /**
     * If a columns array is passed only use those to populated the csv (and use the label property in the columns
     * array. if it is not passed, simply use the key object key field on the datatable object passed as the label.
     *
     * @param dataTable required
     * @param columns   optional an array containing simplified sfdc objects minimal should be [ {fieldNAme: '', label:''} ]
     * @return {string}
     */
    convertDataTableToCsvString(dataTable, columns) {
        /**
         *
         * @param key
         * @param columns
         * @return true if the row data has a column header, otherwise false.
         */
        function hasColumnHeader(key, columns) {
            return columns && Array.isArray(columns) && columns.find(x => x.fieldName === key) !== undefined;
        }

        /**
         * If a valid columns arg was passed, use it for the export column header label, also only use data that
         * was in the columns arg to export (allows us to differential export data from display data). If columns
         * not passed, just dump all dataTable data into export using js key props as column header.
         *
         * @param rowData
         * @param columns
         * @return a comma deliminated csv string
         */
        function getColumnHeaderCsvString(rowData, columns) {
            let csvString = '';
            if (rowData && columns) {
                let headerData = [];
                rowData.forEach((prop, idx) => {
                    const column = columns.find(x => x.fieldName === prop);
                    if (column && column.hasOwnProperty('label')) {
                        headerData.push(column.label);
                    }
                });
                if (headerData.length > 0) {
                    csvString += headerData.join(',');
                }
            } else {
                if (rowData) {
                    csvString += rowData.join(',');
                }
            }
            return csvString;
        }

        let rowEnd = '\n';
        let csvString = '';
        // this set elminates the duplicates if have any duplicate keys
        let rowData = new Set();

        // getting keys from data don't use keys that do not have labels if the columns array is passed.
        dataTable.forEach(function (record) {
            Object.keys(record).forEach(function (key) {
                if (columns && Array.isArray(columns)) {
                    if (hasColumnHeader(key, columns)) {
                        rowData.add(key);
                    }
                } else {
                    rowData.add(key);
                }
            });
        });
        // Array.from() method returns an Array object from any object with a length property or an iterable object.
        rowData = Array.from(rowData);
        // splitting using ','
        csvString += getColumnHeaderCsvString(rowData, columns);
        csvString += rowEnd;

        // main for loop to get the data based on key value
        for (let i = 0; i < dataTable.length; i++) {
            let colValue = 0;

            // validating keys in data
            for (let key in rowData) {
                if (rowData.hasOwnProperty(key)) {
                    // Key value
                    // Ex: Id, Name
                    let rowKey = rowData[key];
                    // add , after every value except the first.
                    if (colValue > 0) {
                        csvString += ',';
                    }
                    // If the column is undefined, it as blank in the CSV file.
                    let value = dataTable[i][rowKey] === undefined ? '' : dataTable[i][rowKey];
                    value = value.toString().replace('"', '""'); // escape double quotes
                    value = value.toString().replace('#', ''); // remove #
                    csvString += '"' + value + '"';
                    colValue++;
                }
            }
            csvString += rowEnd;
        }
        return csvString;
    }
}