public without sharing class UserSvc {

    private static Integer AES_KEY_SIZE = 256;
    public static final String DEFAULT_COMMUNITY_NAME = 'Accel Location Community';
    public static final String DEFAULT_OWA_EMAIL_ADDRESS = 'portalsupport@accelentertainment.com';
    public static final String RM_EMAIL_SUBJECT_SUFFIX = 'was just created!';

    /**
     *
     * @param userIds
     * @param pwType
     * @param pwLength
     */
    @Future
    public static void setUsersPasswords( Set<Id> userIds, String pwType, Integer pwLength,Id templateId) {

        Map<User,String> mUserPws = new Map<User,String>();
        try {
            List<User> users = [
                    SELECT Id, Username, Email
                    FROM   User
                    WHERE  Id IN :userIds
            ];
            System.debug(LoggingLevel.INFO,'---future--- processing '+users.size() + ' users!');
            System.debug(LoggingLevel.INFO,'---future--- pwType:'+pwType);
            for(User user : users) {
                String pw = genUserPassword(pwType, pwLength);
                if(pw != null) {
                    if(!Test.isRunningTest()) {
                        System.setPassword(user.Id, pw);
                    }
                    mUserPws.put(user,pw);
                }
            }
            if(templateId != null) {
                sendPasswordEmails(mUserPws, templateId);
            } else {
                System.debug(LoggingLevel.WARN, 'no email template id');
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,e);
        }
    }
    /**
     *
     *
     * @param userId
     * @param pwType
     * @param pwLength
     *
     * @return
     * @todo better algo?
     */
    public static String genUserPassword(String pwType, Integer pwLength) {
        String pw;

        switch on pwType {
            when 'random' {
                if(pwLength != null) {
                    Blob blobKey = Crypto.generateAesKey(AES_KEY_SIZE);
                    String key = EncodingUtil.convertToHex(blobKey);
                    pw = key.substring(0, pwLength);
                } else {
                    System.debug(LoggingLevel.ERROR,'pw length may not be null');
                }
            }
            when else {
                System.debug(LoggingLevel.ERROR,'supported pw generation type : '+pwType);
            }
        }
        return pw;
    }
    public static List<Messaging.SingleEmailMessage> sendPasswordEmails(Map<User,String> mUserPasswords, Id templateId) {
        return sendPasswordEmails( mUserPasswords,templateId,DEFAULT_COMMUNITY_NAME );
    }


    @TestVisible
    private static List<User> retrieveUsersFullContactInfo( Set<Id> userIds ) {
        // Contact.Account.Relationship_Manager__r.Email
        return [
                SELECT  Id, Contact.Name, ContactId,
                        Contact.Account.Name
                FROM    User
                WHERE   Id IN :userIds
                AND     ContactId != NULL
        ];
    }
//    @TestVisible
//    private static Map<Id,AccountContactRelation> retrieveContactAcrs (Set<Id> contactIds ) {
//        return new Map<Id, AccountContactRelation>([
//                SELECT Id, ContactId, AccountId,Account.Name, Contact.Name
//                FROM AccountContactRelation
//                WHERE IsActive = TRUE
//                AND ContactId IN :contactIds
//                ORDER BY ContactId, Account.Name ASC
//        ]);
//    }
//    @TestVisible
//    private static Map<Id,List<AccountContactRelation>> buildContactAcrsMap(Map<Id,AccountContactRelation> accountContactRelationMap) {
//        Map<Id, List<AccountContactRelation> > mAccountContactRelationsByContactIds = new Map<Id,List<AccountContactRelation>>();
//        for(Id acrId : accountContactRelationMap.keySet()) {
//            AccountContactRelation acr = accountContactRelationMap.get(acrId);
//            if(acr != null) {
//                if(acr.ContactId != null) {
//                    if(!mAccountContactRelationsByContactIds.containsKey(acr.ContactId)) {
//                        mAccountContactRelationsByContactIds.put(acr.ContactId, new List<AccountContactRelation>{acr});
//                    } else {
//                        List<AccountContactRelation> acrs = mAccountContactRelationsByContactIds.get(acr.ContactId);
//                        acrs.add(acr);
//                    }
//                }
//            }
//        }
//        return mAccountContactRelationsByContactIds;
//    }


    /**
     * Retrieves org wide address and uses if found.  Retrieves additional community info via the ConnectApi.
     * Creates a map of custom merge variables to be set. Calls regex subject, body replacement logic for merge
     * variables that the OOTB SFDC UI Does not handle. Finally Sends The Emails in bulk.
     *
     * @param mUserPasswords  A map of User => password.
     * @param templateId      The Id of the email template.
     * @param communityName   The Community Name.
     */
    public static List<Messaging.SingleEmailMessage> sendPasswordEmails( Map<User,String> mUserPasswords, Id templateId, String communityName ) {

        OrgWideEmailAddress owa = retrieveOwa( DEFAULT_OWA_EMAIL_ADDRESS );
        Map<String,String> mMergeFieldReplacement = new Map<String,String>();
        List<Messaging.SingleEmailMessage> emailMessages = new List<Messaging.SingleEmailMessage>();

        //ConnectApi.Community community = retrieveCommunity( communityName );
        String communityLoginUrl;

//        if(community != null) {
//            communityName = community.name;
//            communityLoginUrl = community.loginUrl;
//        } else {
            communityName = '';
            communityLoginUrl ='';
  //      }

        for(User user : mUserPasswords.keySet()) {
            // Add new custom merge variables here!
            mMergeFieldReplacement.put('[{password}]',mUserPasswords.get(user));
            mMergeFieldReplacement.put('[{communityname}]',communityName);
            mMergeFieldReplacement.put('[{communityloginurl}]',communityLoginUrl);
            mMergeFieldReplacement.put('[{communityusername}]',user.username);

            Messaging.SingleEmailMessage  et = populateEmailTemplateCustomMergeFields(
                    templateId,user.Id, mMergeFieldReplacement);

            et.setSaveAsActivity(false); //  Dont record an activity!
            if(owa!=null) {
                et.setCcAddresses( new List<String>{owa.Address} ); //  cc portal support
                et.setOrgWideEmailAddressId(owa.Id);
            }
            System.debug(LoggingLevel.INFO,'--- future sendPasswordEmails sending email to: '+et.toAddresses);
            emailMessages.add(et);
        }
        if(!emailMessages.isEmpty()) {
            Messaging.sendEmail( emailMessages );
        }
        return emailMessages;
    }
//    /**
//     *
//     *
//     * @param communityName
//     *
//     * @return
//     */
//    public static ConnectApi.Community retrieveCommunity(String communityName) {
//        ConnectApi.Community community;
//        Network network;
//        List<Network> networks = [SELECT Id FROM Network WHERE Name = :communityName];
//        if(!networks.isEmpty()) {
//            network = networks[0];
//            if(!Test.isRunningTest()) { //  Lame but will blow chunks in UT as SFDC has not caught up.
//                community = ConnectApi.Communities.getCommunity(network.Id);
//            }
//        }
//        return community;
//    }
    /**
     *
     *
     * @param devName
     * @return
     * @todo move to EmailSvc when we can unschedule batch jobs.
     */
    public static EmailTemplate retrieveEmailTemplate(String devName) {
        EmailTemplate emailTemplate;
        List<EmailTemplate> emailTemplates = [
                SELECT Id, DeveloperName, Name, IsActive, TemplateType
                FROM   EmailTemplate
                WHERE  DeveloperName = :devName
        ];
        if(!emailTemplates.isEmpty()) {
            emailTemplate = emailTemplates[0];
        }
        return emailTemplate;
    }

    /**
     *
     *
     * @param emailTemplate
     * @param whoId
     * @param mMergeReplacement  String mergeField => String replacement value. ie [password] => newpass
     *
     * @return
     */
    public static Messaging.SingleEmailMessage populateEmailTemplateCustomMergeFields(  Id emailTemplateId,
            Id whoId,
            Map<String,String> mMergeReplacement) {

        Messaging.SingleEmailMessage emailMsg = getEmailTemplateSingleEmailMessage(emailTemplateId,whoId);
        String htmlBody = emailMsg.getHtmlBody();
        String subject = emailMsg.getSubject();

        //  @todo much to simplistic use regex!
        for(String customMergeField : mMergeReplacement.keySet()) {

            htmlBody = htmlBody.replace(customMergeField,mMergeReplacement.get(customMergeField));
            subject = subject.replace(customMergeField,mMergeReplacement.get(customMergeField));
        }
        emailMsg.htmlBody = htmlBody;
        emailMsg.subject = subject;
        return emailMsg;
    }
    /**
     *
     *
     * @param emailAddy
     *
     * @return
     * @todo merge into EmailSvc
     */
    public static OrgWideEmailAddress retrieveOwa( String emailAddy ) {
        OrgWideEmailAddress owa;
        List<OrgWideEmailAddress> orgWideEmailAddresses = [
                SELECT  Id, Address
                FROM    OrgWideEmailAddress
                WHERE   Address = :emailAddy
        ];
        if(!orgWideEmailAddresses.isEmpty()) {
            owa = orgWideEmailAddresses[0];
        }
        return owa;
    }
    public static Messaging.SingleEmailMessage getEmailTemplateSingleEmailMessage(Id emailTemplateId, Id whoId) {
        Messaging.SingleEmailMessage emailMsg =
                Messaging.renderStoredEmailTemplate(emailTemplateId, whoId, null);
        return emailMsg;
    }

    /**
     *
     *
     * @param userId    The Id of the user to search for.
     * @return          The Id of the contact if there is a User.ContactId value, otherwise null.
     */
    public static Id retrieveUserContactId( Id userId ) {
        Id contactId;
        User user = [SELECT Id, ContactId FROM User WHERE Id = :userId];
        contactId =  user.ContactId;
        return contactId;
    }
    /**
     *
     * @param profileId
     * @return
     */
    public static Profile retrieveUserProfileById(Id profileId) {
        Profile profile;
        List<Profile> profiles = [
                SELECT  Id, Name, UserLicenseId, UserType
                FROM    Profile
                WHERE   Id = :profileId
        ];
        if(!profiles.isEmpty()) {
            profile = profiles[0];
        }
        return profile;
    }
    /**
     *
     * @param name
     * @return
     */
    public static Profile getProfileByName(String name) {
        Profile p;
        List<Profile> profiles = [select id, name from Profile where name=:name];
        if(!profiles.isEmpty()) {
            p = profiles.get(0);
            System.debug( 'getProfileByName found id='+p.id + ' name='+ p.name);
        } else {
            System.debug( ' NO Profile FOUND!');
        }
        return p;
    }
    /**
     *
     * @param  pId
     * @return a Profile sObject.
     */
    public static Profile retrieveProfileById(Id pId) {
        Profile p;
        List<Profile> profiles = [select id, name from Profile where id=:pId];
        if(!profiles.isEmpty()) {
            p = profiles.get(0);
            System.debug( 'retrieveProfileById found id='+p.id + ' name='+ p.name);
        } else {
            System.debug( ' NO Profile FOUND!');
        }
        return p;
    }
    /**
     *
     * @param userId
     * @return
     */
    public static User retrieveUserLoginInfo(Id userId) {
        User user;
        List<User> users = [
                SELECT Id, Username, LastPasswordChangeDate
                FROM  User
                WHERE Id = :userId
        ];
        if(!users.isEmpty()) {
            user = users[0];
        }
        return user;
    }

    public static User retrieveUserDetails(Id userId) {
        User user;
        List<User> users = [
                SELECT Id, Username, Name, Email, IsActive
                FROM  User
                WHERE Id = :userId
        ];
        if(!users.isEmpty()) {
            user = users[0];
        }
        return user;
    }
    /**
     *
     *
     * @param newPassword
     * @param confirmPassword
     * @param currentPassword
     *
     * @return
     */
    public static PageReference changeCommunityUserPassword(String newPassword, String confirmPassword,String currentPassword) {
        PageReference pr = Site.changePassword(newPassword,confirmPassword,currentPassword); //will return null when succcess
        return pr;
    }

    public static String getCommunityPasswordPolicyStatement() {
        return Site.getPasswordPolicyStatement();
    }
    /**
     *
     * @param user
     * @param password
     * @param confirmPassword
     * @note the Sites class is notorious buggy when it comes to UT code.. we must hack this because of SFDC Lameness.
     */
    public static void validateCommunityUserPassword(User user, String password, String confirmPassword) {
        if(!Test.isRunningTest()) {
            Site.validatePassword(user, password, confirmPassword);
        }
    }
    /**
     *
     *
     * @param userId
     * @param pw
     * @param emailAddresses
     */
    @Future
    @TestVisible
    private static void setUserPassword( Id userId, String pw, List<String> emailAddresses) {
        try {
            System.setPassword(userId,pw);
            if(emailAddresses != null) {
                //@TODO fire email send via template or simple apex email
            }
        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR,e);
        }
    }
    /**
     * Checks Custom Permissions based on the custom permission api name.
     *
     * @param customPermissionApiName  the custom permission api name to check.
     * @return   TRUE if the user has permission, otherwise false.
     */
    @AuraEnabled(Cacheable=true)
    public static Boolean doesUserHavePermission( String customPermissionApiName ) {
        Boolean hasPermission = FeatureManagement.checkPermission(customPermissionApiName);
        return hasPermission;
    }
}