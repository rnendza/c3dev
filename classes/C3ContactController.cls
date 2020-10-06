public with sharing class C3ContactController {

    public final static String MAP_KEY_PROGRESS_INDICATORS      = 'MAP_KEY_PROGRESS_INDICATORS';

    @AuraEnabled
    public static C3ResponseDto updateCandidateStatus(Id contactId, String status) {
        C3ResponseDto dto = new C3ResponseDto();
        Contact c= [SELECT Id,Candidate_Status__c FROM Contact where Id = :contactId];
        c.Candidate_STatus__c = status;
        update c;

        dto.isSuccess = true;
        return dto;
    }
    /**
     *
     * @param contactId
     * @return a ResponseDto object containing a list of ProgressIndicator keys by MAP_KEY_PROGRESS_INDICATORS
     * @see C3ProgressIndicator
     */
    @AuraEnabled
    public static C3ResponseDto retrieveContactProgressIndicators(Id contactId) {
        C3ResponseDto dto = new C3ResponseDto();
        List<C3ProgressIndicator> progressIndicators = new List<C3ProgressIndicator>();
        List <Contact_Progress_Indicator__mdt> settings =
                C3ContactSvc.retrieveContactProgressIndicators(null );
        if(settings != null) {
            for(Contact_Progress_Indicator__mdt setting : settings) {
                C3ProgressIndicator pi = new C3ProgressIndicator();
                pi.value = setting.Value__c;
                pi.displayValue = setting.Display_Value__c;
                if(setting.Description__c != null) {
                    pi.description = setting.Description__c;
                }
                pi.order = Integer.valueOf(setting.Order__c);
                pi.current = setting.Current__c;
                progressIndicators.add(pi);
            }
            dto.values.put( MAP_KEY_PROGRESS_INDICATORS,progressIndicators );
            dto.values.put( 'contact', C3ContactSvc.retrieveFullContactInfo(contactId));
            dto.isSuccess = true;
        }
        return dto;
    }
}