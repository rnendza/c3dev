/**
 */
public class C3ProgressIndicator {
    @AuraEnabled public String  value               { get;set; }
    @AuraEnabled public String  displayValue        { get;set; }
    @AuraEnabled public String  description         { get;set; }
    @AuraEnabled public Integer order               { get;set; }
    @AuraEnabled public Boolean current             { get;set; }
    @AuraEnabled public Boolean completed           { get;set; }
    @AuraEnabled public String  textClass           { get;set; } //  css class of the  display value and the desc.
    @AuraEnabled public String  valueContainerClass { get;set; } //  css class of value container ie. parent div.

    /**
     *  No arg constructor.. not setting empty string so the platform will return in the JSON.
     */
    public C3ProgressIndicator() {
        this.description = '';
        this.completed = false;
        this.current = false;
        this.textClass = '';
        this.displayValue = '';
        this.order = 0;
        this.valueContainerClass = '';
    }
}