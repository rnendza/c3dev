import {api, track, LightningElement} from 'lwc';

const cCardBodyClass = '';
const cCardFooterClass = 'c3-video-footer slds-card__footer';

export default class VideoEmbed extends LightningElement {

    @api cmpCollapsed = false;
    @api cardBodyClass= cCardBodyClass;
    @api cardFooterClass = cCardFooterClass;

    @track showSpinner;
    @track spinnerToggleActiveText = 'Spinner Active';
    @track spinnerToggleInactiveText = 'Spinner InActive';
    @track spinnerToggleName = 'SpinnerToggleName';

    renderedCallback() {
        if(!this._hasRendered) {
            this.showSpinner = true;
            this.buildVideoThemeOverrides();
            this._hasRendered = true;
        }
    }

    handleCollapseCmp(event) {
        this.cmpCollapsed = true;
        this.cardBodyClass = 'slds-hide';
        this.cardFooterClass = 'slds-hide';
    }
    handleExpandCmp(event) {
        this.cmpCollapsed = false;
        this.cardBodyClass = cCardBodyClass;
        this.cardFooterClass = cCardFooterClass;
    }
    handleCheckboxChange(event) {
        event.preventDefault();
        alert(event.target.checked);
    }

    /**
     * override the lightning app Header and anything e`lse here.
     */
    buildVideoThemeOverrides() {
        let css = '.slds-card__footer { margin-top:0px!important}';
        const style = document.createElement('style');
        style.innerText = css;
        try {
            let target = this.template.querySelector('.fake-video-page-theme-overrides-class');
            target.appendChild(style);
        } catch (e) {
            console.error(e);
        }
    }
}