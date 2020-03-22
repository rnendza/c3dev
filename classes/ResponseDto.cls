/**
 *  A general Data Transfer Object to return data from an remote method to the client.
 *  This allows us to pass back many values as well as server side messaging information easily!
 */
public class ResponseDto {

    @AuraEnabled public Boolean isSuccess { get; set; }
    @AuraEnabled public String message { get; set; }
    @AuraEnabled public String statusCode { get; set; }
    @AuraEnabled public String severity { get; set; }
    @AuraEnabled public String title { get; set; }
    @AuraEnabled public String technicalMsg { get; set; }

    //== A general wrapper for returning a map of general objects.
    @AuraEnabled public Map<Object, Object> values { get; set; }
    //== A single sObject
    @AuraEnabled public SObject sObj {get;set;}
    //== Generally meant store many results for an SObject (Generally keys by sObject Name. ie. Account or Custom_Object__c)
    //== Note the value property can be used in place of the below if preferred as well.
    @AuraEnabled public Map<Object, List<SObject>> valuesSobjList { get; set; }

    public ResponseDto() {
        initObj();
    }
    public ResponseDto(Boolean isSuccess, String msg) {
        this.isSuccess = isSuccess;
        this.message = msg;
        this.values = new Map<Object, Object>();
        this.valuesSobjList = new Map<Object, List<SObject>>();
        this.severity = '';
        this.title = '';
        this.statusCode = '';
        this.technicalMsg = '';
    }
    private void initObj() {
        this.isSuccess = false;
        this.message = '';
        this.values = new Map<Object, Object>();
        this.valuesSobjList = new Map<Object, List<SObject>>();
        this.severity = '';
        this.title = '';
        this.statusCode = '';
        this.technicalMsg = '';
    }
}