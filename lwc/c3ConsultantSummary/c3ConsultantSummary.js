import {LightningElement, api, track, wire} from 'lwc';
import retrieveFullContactInfo from '@salesforce/apex/C3ContactSvc.retrieveFullContactInfo';
import { NavigationMixin } from 'lightning/navigation';
import {fireEvent} from "c/pubSub";
import { CurrentPageReference } from 'lightning/navigation';

const cFooterClass = 'slds-card__footer';
const cCardBodyClass = 'slds-p-horizontal_small slds-p-vertical_small';

export default class C3ConsultantSummary extends NavigationMixin(LightningElement)  {

    @api recordId;
    @api wiredFullContactInfo;
    @api fullContactInfo;
    @api cmpCollapsed = false;
    @api cardBodyClass= cCardBodyClass;
    @api cardFooterClass = cFooterClass;

    @wire(CurrentPageReference) pageRef;

    @wire(retrieveFullContactInfo, {contactId: '$recordId'})
    wiredFullContactInfoResults(wiredData) {
        this.wiredFullContactInfo = wiredData;
        const { data, error } = this.wiredFullContactInfo;
        if(data) {
          this.fullContactInfo = data;
            fireEvent(this.pageRef, 'contactSelected', this.fullContactInfo);
        } else if (error) {
            console.error(JSON.stringify(error));
            this.error = 'Unknown error';
            if (Array.isArray(error.body)) {
                this.error = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                this.error = error.body.message;
            }
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
        this.cardFooterClass = cFooterClass;
    }

    handleFilePreview(event){
        this[NavigationMixin.Navigate]({
            type: 'standard__namedPage',
            attributes: {
                pageName: 'filePreview',
                recordId: event.currentTarget.dataset.id,
                objectApiName: 'ContentVersion',
                actionName: 'view',
            },
            state: {
                selectedRecordId: event.currentTarget.dataset.id,
            },
        });
    }
}