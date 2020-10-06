import {LightningElement} from 'lwc';

export default class C3LightningRecordPageOverrides extends LightningElement {
    _hasRendered = false;

    renderedCallback() {
        if(!this._hasRendered) {
            this._hasRendered = true;
            this.buildLightningRecordPageThemeOverrides();
        }
    }
    /**
     * override the lightning app Header and anything e`lse here.
     */
    buildLightningRecordPageThemeOverrides() {
        let css = ' .slds-gutters_x-small .slds-col { padding-left: 1px}';
        css += '.slds-card__header { border-bottom: 1px solid rgb(221,219,218);padding-bottom: .50rem;background-color: rgb(243,242,242)};';
        css +='.slds-progress_vertical .slds-progress__item_content { border-bottom: 1px solid rgb(243,242,242);}';
        css +='.c3-card-title {font-weight: bold}';
        css+= '.forceHighlightsStencilDesktop .slds-page-header__detail-row { ';
        css+= ' padding:0;}';
        css+= ' .slds-page-header .slds-page-header_record-home .s1FixedTop .forceHighlightsStencilDesktop .forceRecordLayout {height:inherit!important;}';
        css+= ' .forceHighlightsStencilDesktop forceRecordLayout {height:110px!important;}';
        css +='flexipageComponent:not(:last-child):not(:empty) {margin-bottom:0}';
        //css += '.slds-page-header_record-home {height:60px!important}';
        css += '.slds-form-element__label {display:none;}';
        css += '.slds-card__footer {  background-color: #F3F2F2; }';

        const style = document.createElement('style');
        style.innerText = css;
        try {
            let target = this.template.querySelector('.fake-app-page-theme-overrides-class');
            target.appendChild(style);
        } catch (e) {
            console.error(e);
        }
    }
}