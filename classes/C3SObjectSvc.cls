/**
 * Created by rnend on 3/24/2020.
 */

public with sharing class C3SObjectSvc {
    /**
     * Gets a set of all the field api names for an sObject.
     *
     * @param sObjectApiName
     * @return a Set of field api names for the given sObject.
     */
    public static Set<String> retrieveAllSObjectFieldApiNames(String sObjectApiName) {
        Set<String> apiNames = new Set<String>();
        Set<Schema.SObjectField> sObjectFields = retrieveAllSObjectFields(sObjectApiName);
        for(Schema.SObjectField sObjectField : sObjectFields) {
            apiNames.add(sObjectField.getDescribe().name);
        }
        return apiNames;
    }
    /**
     * Gets a set of all the sObjectFields for an sObject.
     *
     * @param sObjectApiName
     * @return a Set of sObjectFields for the given sObject.
     */
    public static Set<Schema.SObjectField> retrieveAllSObjectFields(String sObjectApiName) {
        SObjectType sObjectType = getSObjectType(sObjectApiName);
        Warnings.checkSObjectType(sObjectType,sObjectApiName);
        Schema.DescribeSObjectResult describeResult = sObjectType.getDescribe();
        Map<String, Schema.SObjectField> fields = describeResult.fields.getMap();
        List<Schema.SObjectField> lSObjectFields = fields.values();
        Set<Schema.SObjectField> sObjectFields = new Set<Schema.SObjectField>(lSObjectFields);
        return sObjectFields;
    }
    /**
 * Gets an SObjectType for the given sObject API Name.
 *
 * @param sObjectName  The api of the sObject ie. 'Foo_Custom__c'
 * @return  The SObject Type for the passed api name.
 */
    public static SObjectType getSObjectType( String sObjectName)  {

        SObjectType sObjType;
        try {
            sObjType = ((SObject) Type.forName(sObjectName).newInstance()).getSObjectType();
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR,ex);
        }
        return sObjType;
    }
}