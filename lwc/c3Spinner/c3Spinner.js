import {LightningElement,api,track} from 'lwc';

export default class C3Spinner extends LightningElement {

    @track _showSpinner = false;

    @api
    get showSpinner() {
        return this._showSpinner;
    }
    set showSpinner(val) {
        this._showSpinner = false;
    }

    renderedCallback() {
        if(!this._hasRendered) {
            this.showSpinner = true;
            this._hasRendered = true;
        }
    }
}