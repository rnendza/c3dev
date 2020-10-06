public with sharing class C3ContactSvc {

    @AuraEnabled(Cacheable=true)
    public static Contact retrieveFullContactInfo(Id contactId) {
        return [
                SELECT Id, Name, Email,Phone,MobilePhone, Career_Summary__c,Candidate_Status__c,
                        Account.Id, Account.Name, Client__r.Name
                FROM Contact
                WHERE Id = :contactId
        ];
    }
    /**
     *
     *
     * @param devName
     *
     * @return
     */
    public static List<Contact_Progress_Indicator__mdt> retrieveContactProgressIndicators (String devName) {
        List<Contact_Progress_Indicator__mdt> settings;
        String sObjectApiName = 'Contact_Progress_Indicator__mdt';
        Set<String> apiNames = C3SObjectSvc.retrieveAllSObjectFieldApiNames('Contact_Progress_Indicator__mdt');
        if(apiNames != null) {
            List<String> apiNamesList = new List<String>(apiNames);
            String selectFields = String.join(apiNamesList,',');
            String soql = '';
            soql += ' SELECT '+selectFields;
            soql += ' FROM   '+sObjectApiName;
            if (devName != null) {
                soql += ' WHERE DeveloperName = :devName ';
            }
            soql += ' ORDER BY Order__c ASC ';
            settings = (List<Contact_Progress_Indicator__mdt>) Database.query(soql);
        }
        return settings;
    }
}