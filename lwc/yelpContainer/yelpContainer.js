import {LightningElement, wire, track} from 'lwc';
import {fireEvent, registerListener, unregisterAllListeners} from 'c/pubSub';
import {ShowToastEvent} from 'lightning/platformShowToastEvent';
import { CurrentPageReference } from 'lightning/navigation';
import {loadScript, loadStyle} from "lightning/platformResourceLoader";
import FONT_AWESOME from  '@salesforce/resourceUrl/font_awesome_v5_free';

export default class YelpContainer extends LightningElement {

    _hasRendered = false;
    _showDevToast = false;

    @track yelpMapCssClass                  = '';
    @track yelpLocDisplayCssClass           = '';
    @track yelpLocDetailsDisplayCssClass    = 'slds-hide';
    @track yelpSearchMapOuterCssClass       = '';
    @wire(CurrentPageReference) pageRef;

    constructor() {
        super();
    }
    connectedCallback() {
        this.registerListeners();
        if(this._showDevToast) {
            let msg = 'This entire app is under active development. Beware there will be errors!';
            this.showToast('Developer Message', msg, 'warning');
        }
    }
    renderedCallback() {
        if(!this._hasRendered) {
            this._hasRendered = true;
            this.loadFontAwesome();
        }
    }
    handleLocationMoreDetailClicked(business) {
        this.yelpLocDetailsDisplayCssClass = '';
        this.yelpSearchMapOuterCssClass = 'slds-hide';
    }
    handleSearchAgain(doIt) {
        this.yelpSearchMapOuterCssClass = '';
        this.yelpLocDetailsDisplayCssClass = 'slds-hide';
    }
    registerListeners() {
        registerListener('locationMoreDetailClicked', this.handleLocationMoreDetailClicked, this);
        registerListener('searchAgain', this.handleSearchAgain, this);
    }
    /**
     * Loads font awesome js and css for fonts not available in SLDS.
     */
    loadFontAwesome() {
        Promise.all([
            loadScript(this, FONT_AWESOME + '/js/all.js'),
            loadStyle(this, FONT_AWESOME + '/css/all.css'),
        ])
            .then(() => {
                console.log('fa loaded');
            })
            .catch(error => {
                console.error(error);
                console.error(error.message);
            });
    }
    /**
     *
     * @param title
     * @param msg
     * @param variant
     */
    showToast(title, msg, variant) {
        const evt = new ShowToastEvent({
            title: title,
            message: msg,
            variant: variant
        });
        this.dispatchEvent(evt);
    }
}