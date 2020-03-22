import {api, LightningElement, track, wire} from 'lwc';
import { CurrentPageReference } from 'lightning/navigation';
import {fireEvent, registerListener, unregisterAllListeners} from 'c/pubSub';
import Logger from "c/logger";
import {loadScript, loadStyle} from "lightning/platformResourceLoader";
import FONT_AWESOME from  '@salesforce/resourceUrl/font_awesome_v5_free';
import C3Utils from "c/c3Utils";

const ERROR='error',INFO='info',DEBUG='debug',WARN='warn';

export default class YelpLocationDisplay extends LightningElement {

    _debugConsole = true;
    _className = 'YelpLocationDisplay';
    _logger = new Logger(this._debugConsole);
    _c3Utils = new C3Utils(this._debugConsole);

    @track businesses = [];
    @track selectedLocation = '';
    @track selectedTerm = '';
    @track selectedCategory = '';
    @track hasRendered = false;
    @track showBusinessDetail = false;
    @track cmpCollapsed = false;


    @wire(CurrentPageReference) pageRef;

    @track isSearching;
    @api
    get cardTitle() {
        let title = 'Yelp USA Business Search Results';
        if(this.businesses && Array.isArray(this.businesses)) {
            title += ' (<b>'+this.businesses.length+'</b>)';
        }
        return title;
    }
    @api get searchResultsContainerClass() {return this.cmpCollapsed ? 'slds-hide' : '';}
    @api get resultsFound() { return this.businesses && this.businesses.length > 0;}
    @api get displayNoResultsFound() { return !this.isSearching && !this.resultsFound;}

    constructor() {
        super();
        this.isSearching = true;
    }
    connectedCallback() {
        this.log(' === connected callback ===');
        this.isSearching = true;
        registerListener('locationListUpdate', this.handleLocationListUpdate, this);
        registerListener('locationSelected', this.handleLocationSelected, this);
        registerListener('categoriesSelected', this.handleCategoriesSelected, this);
        registerListener('termModified', this.handleTermModified, this);
        registerListener('isSearching', this.handleIsSearching, this);
        registerListener('searchAgain', this.handleSearchAgain, this);
    }
    renderedCallback() {
        if(!this.hasRendered) {
            this.hasRendered = true;
            // this.loadFontAwesome();
        }
    }
    disconnectedCallback() {
        unregisterAllListeners(this);
    }
    handleLocationListUpdate(businesses) {
        this.businesses = businesses;
        console.error('---------------  handleLocationListUpdate got businesses json --------------');
    }
    handleLocationSelected(locationSelected) {
        this.selectedLocation = locationSelected;
    }
    handleIsSearching(searching) {
        this.isSearching = searching;
    }
    handleBusinessMouseover(event) {

    }
    handleSearchAgain(payload) {
        this.cmpCollapsed = false;
        try {
            let target = this.template.querySelector('[data-id="search-results-top-of-container"]');
            let rect = target.getBoundingClientRect();
            scrollTo({top: rect.top, behavior: "smooth"});
        } catch (e) {
            alert(e);
        }
    }
    handleCategoriesSelected(categoriesSelected) {
        if(categoriesSelected && Array.isArray(categoriesSelected) && categoriesSelected.length > 0) {
            this.selectedCategory = categoriesSelected[0];
        }
    }
    handleTermModified(term) {
        this.selectedTerm = term;
    }
    handleViewBusinessDetail(event) {
        this.showBusinessDetail = true;
        let businessId = event.target.dataset.id;
        if(!businessId) {
            businessId = event.currentTarget.dataset.divbusinessid;
        }
        //alert(businessId);
        if(businessId) {
            let business = this.businesses.find(x => x.id === businessId);
            this.cmpCollapsed = true;
            fireEvent(this.pageRef, 'locationMoreDetailClicked', business);
        }
    }
    handleCollapseComponent(event) {
        this.cmpCollapsed = true;
    }
    handleExpandComponent(event) {
        this.cmpCollapsed = false;
    }
    registerListeners() {
        registerListener('locationListUpdate', this.handleLocationListUpdate, this);
        registerListener('locationSelected', this.handleLocationSelected, this);
        registerListener('categoriesSelected', this.handleCategoriesSelected, this);
        registerListener('termModified', this.handleTermModified, this);
        registerListener('isSearching', this.handleIsSearching, this);
        registerListener('searchAgain', this.handleSearchAgain, this);
    }
    /**
     * Loads font awesome js and css for fonts not available in SLDS.
     * @todo only load what is needed. we are probably loading too much here.
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
     * @param logType  The type of log (see the constants).
     * @param msg      The string msg to log.
     * @param obj      an optional obj (internally will attempt to deconstruct to avoid proxy issues)
     */
    log(logType, msg, obj) {
        if (this._logger) {
            switch (logType) {
                case DEBUG:
                    this._logger.logDebug(msg,obj);
                    break;
                case ERROR:
                    this._logger.logError(msg,obj);
                    break;
                case INFO:
                    this._logger.logInfo(msg,obj);
                    break;
                default:
                    this._logger.log(msg, obj);
            }
        }
    }
}