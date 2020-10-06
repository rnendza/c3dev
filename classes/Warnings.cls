/**
 * A general class which throws 'Warning' Exceptions in order to keep core classes clean of conditional param checking.
 */
public class Warnings {

    public final static Integer MAX_QUERY_ROWS = 50000;

    public class QueryLimitException extends Exception {}
    public class InvalidUpdateParamsException extends Exception {}
    public class InvalidContactSettingsException extends Exception {}
    public class InvalidParamsException extends Exception {}
    public class InvalidCommunityUserException extends Exception{}
    public class InvalidSObjectApiNameException extends Exception{}


    public static void checkSObjectType(SObjectType sObjectType, String sObjectApiName) {
        if(sObjectType == null) {
            throw new InvalidSObjectApiNameException(sObjectApiName + ' not found in target org.');
        }
    }
    /**
     * @param iLimit The current number of rows processed
     */
    public static void checkQueryLimits(Integer iLimit) {
        if(iLimit > MAX_QUERY_ROWS) {
            throw new QueryLimitException();
        }
    }
    /**
     * @param sObj Any sObject Type.
     */
    public static void checkObjectUpdateValidity(SObject sObj) {
        if(sObj == null || sObj.Id == null) {
            throw new InvalidUpdateParamsException();
        }
    }
    /**
     * @param contactId  The Id of the contact sObject.
     * @param fieldNames A Set<String> of fieldApiNames for the sObject.
     */
    public static void checkContactSettingsParams(Id contactId, Set<String>fieldNames) {
        if(contactId == null) {
            throw new InvalidContactSettingsException('Contact Id passed is null');
        }
        if(fieldNames == null) {
            throw new InvalidContactSettingsException('Field names is null');
        }
        if(fieldNames.isEmpty()) {
            throw new InvalidContactSettingsException('Field names is empty.');
        }
    }
    /**
     * @param contactId The Id of the Contact sObject.
     * @param userId The Id of the User sObject.
     */
    public static void checkForValidCommunityUser(Id contactId, Id userId) {
        if(contactId == null || userId == null) {
            throw new InvalidCommunityUserException('You are not a valid community user');
        }
    }
    /**
     * @param contactId The Id of the Contact sObject.
     * @param userId The Id of the User sObject.
     * @param fieldNames A Set<String> of fieldApiNames for the sObject.
     */
    public static void checkCommunityUserSettingsParams(Id contactId, Id userId, Set<String>fieldNames) {
        if(contactId == null) {
            throw new InvalidParamsException('Contact Id passed is null');
        }
        if(userId == null) {
            throw new InvalidParamsException('User Id passed is null');
        }
        if(fieldNames == null) {
            throw new InvalidParamsException('Field names is null');
        }
        if(fieldNames.isEmpty()) {
            throw new InvalidParamsException('Field names is empty.');
        }
    }
}