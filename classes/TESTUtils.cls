/**
 * Quick hit Test Factory.
 * @TODO create a real factory / unit testing arch.
 */
public with sharing class TESTUtils {


    /**
     * Originally meant to generate a globally unique User.CommunityNickName value but can, I guess, be used
     * for other fields assuming that field is large enough to hold the results.
     *
     * @param prefix A prefex. .if desired / otherwise replaces null with empty space ie ''.
     * @return a string with prefix  + org Id + timestamp + random value.
     * @see https://help.salesforce.com/articleView?id=000330466&language=en_US&type=1&mode=1
     */
    public static String  generateUniqueString( String prefix ) {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        prefix = prefix == null ? '' : prefix;
        String uniqueName = prefix + orgId + dateString + randomInt;
        return uniqueName;
    }

    /**
     *
     *
     * @param dateToSearch  The date to start the leap year search with.
     * @return              The closest leap year to the date passed.
     */
    public static Integer findNextLeapYear( Date dateToSearch ) {
        Integer leapYear;
        if(dateToSearch == null) {
            return null;
        }
        Integer currentYear = dateToSearch.year();
        Boolean foundIt     = false;

        for( Integer i=0; !foundIt; i++ ) {
            if(Date.isLeapYear(currentYear)) {
                foundIt     = true;
                leapYear    = currentYear;
                break;
            } else {
                currentYear += 1;
            }
        }
        return leapYear;
    }


    /**
     * Inserts a Role and and User and
     *
     * @param uName
     * @param roleName
     *
     * @return User record.
     */
    public static User createAdminUserWithRole(String uName, String roleName) {
        UserRole adminRole = new UserRole(DeveloperName = roleName, Name = roleName);
        insert adminRole;
        User adminUser = getUserForTest(uName);
        adminUser = [select id, userroleid,accountId,contactId from user where id = :adminUser.id];
        adminUser.userroleid = adminRole.id;
        update adminUser;
        return adminUser;
    }
    public static Contact buildContact(Id accountId, String lastName) {
        Contact contact  = new Contact();
        contact.LastName = lastName;
        contact.accountid = accountId;
        return contact;
    }
    /**
     * Creates a PermissonSet and PermissonSetAssignment sObject and guards against dups already existing in the target org.
     *
     * @param psLabel
     * @param psApiName
     * @param userId
     */
    public static PermissionSetAssignment createPermissionSetAndAssignment(String psLabel, String psApiName, Id userId) {
        PermissionSet ps = buildPermissionSet(psLabel,psApiName);
        try {
            insert ps;
        } catch (DmlException dmlEx) {
            if(dmlEx.getMessage().contains('DUPLICATE_DEVELOPER_NAME')) {
                ps = [SELECT Id,Name FROM PermissionSet WHERE Name = :psApiName];
            }
        }
        PermissionSetAssignment psa = buildPermissionSetAssignment(psApiName,userId);
        try {
            insert psa;
        }  catch (DmlException dmlEx) {
            if(dmlEx.getMessage().contains('DUPLICATE_VALUE')) {
                psa = [
                        SELECT  Id,AssigneeId,PermissionSetId
                        FROM    PermissionSetAssignment
                        WHERE   AssigneeId = :userId
                        AND     PermissionSetId  = :ps.Id
                ];
            }
        }
        return psa;
    }

    public static PermissionSet buildPermissionSet( String label, String apiName) {
        PermissionSet ps = new PermissionSet(Label=label,Name=apiName);
        return ps;
    }
    /**
     *
     * @param permissionSetApiName
     * @param userId
     *
     * @return
     */
    public static PermissionSetAssignment buildPermissionSetAssignment( String permissionSetApiName, Id userId) {
        PermissionSetAssignment psa;
        List<PermissionSet> pss = [SELECT Id FROM PermissionSet WHERE Name = :permissionSetApiName];
        if(!pss.isEmpty()) {
            PermissionSet ps = pss[0];
            psa = new PermissionSetAssignment(AssigneeId = userId, PermissionSetId = ps.Id);
        }
        return psa;
    }
    /**
     *
     *
     * @param cpProfileName
     * @param accountName
     * @param userName
     *
     * @return
     */
    public static User getPortalUserForTest(String cpProfileName, String accountName, String userName) {

        List<User> existingUsers = [select id, name, lastname,accountId,contactId from User where isactive = true and username = :userName];
        if(!existingUsers.isEmpty()) {
            return existingUsers[0];
        }

        Account account = new Account();
        account.name = accountName +generateRandomString(10);
        insert account;
        system.assertNotEquals(null, account.Id);
        system.debug('account created');

        // create test contact
        String userEmail = generateRandomString(5) + '@accelentertainment.com';
        system.debug('creating test contact...');
        Contact contact = new Contact();
        contact.firstName = generateRandomString(10);
        contact.lastName = generateRandomString(10);
        contact.email = userEmail;
        contact.accountid = account.id;
        insert contact;

        User user = new User();
        // populate the record
        user.emailencodingkey='UTF-8';
        user.languagelocalekey='en_US';
        user.localesidkey='en_US';
        user.timezonesidkey='America/Chicago';
        user.Alias = generateRandomString(5);
        user.email = userEmail;
        user.lastname = generateRandomString(10);
        user.username = userName;
        user.ContactId = contact.id;
        user.ProfileId = [select id from Profile where Name = :cpProfileName].Id;
        //-----------------------------------user.UserRoleId = [select id from UserRole where name = :roleName ].id;

        // insert the record
        insert user;
        System.assertNotEquals(null, user.Id);
        return user;
    }

    /**
     *
     *
     * @param cpProfileName
     * @param accountName
     * @param userName
     * @param iNumUsers
     *
     * @return
     */
    public static List<User> createPortalUsersForTest(String cpProfileName, String accountName, String userName,Integer iNumUsers) {
        Account account = buildAccount(accountName,'type');
        insert account;

        List<Contact> contacts = new List<Contact>();


        // create test contact
        for(Integer i=0; i<iNumUsers; i++) {
            String userEmail = generateRandomString(5) + '@accelentertainment.com';
            Contact contact = new Contact();
            contact.firstName = generateRandomString(10);
            contact.lastName = generateRandomString(10);
            contact.email = userEmail;
            contact.accountid = account.id;
            contacts.add(contact);
        }
        insert contacts;

        Map<Id,Profile> mProfilesByIds = new Map<Id,Profile> ([
                SELECT Id, Name
                FROM   Profile
        ]);
        Map<String,Id> mProfileIdByName = new Map<String,Id>();
        for(Id profileId : mProfilesByIds.keySet()) {
            Profile profile = mProfilesByIds.get(profileId);
            mProfileIdByName.put(profile.Name, profile.Id);
        }

        List<User> users = new List<User>();
        for(Contact contact : contacts) {
            User user = new User();
            user.emailencodingkey = 'UTF-8';
            user.languagelocalekey = 'en_US';
            user.localesidkey = 'en_US';
            user.timezonesidkey = 'America/Chicago';
            user.Alias = generateRandomString(5);
            user.email = contact.email;
            user.lastname = generateRandomString(10);
            user.username = generateRandomString(10) + userName;
            user.ContactId = contact.id;
            //user.ProfileId = [select id from Profile where Name = :cpProfileName].Id
            user.ProfileId = mProfileIdByName.get( cpProfileName );
            users.add(user);
        }
        insert users;
        return users;
    }
    /**
     * Ensures an actual insert of a user as opposed to trying to find an existing one
     * and returning that as opposed to insert.
     *
     * @param uname
     *
     * @return
     */
    public static User createUserForTest(String uname) {
        User user = new User();
        // populate the record
        user.emailencodingkey='UTF-8';
        user.languagelocalekey='en_US';
        user.localesidkey='en_US';
        user.timezonesidkey='America/Chicago';
        user.Alias = generateRandomString(5);
        user.email = uname;
        user.lastname = generateRandomString(10);
        user.username = uname;
        user.ProfileId = [select id from Profile where Name = 'System Administrator'].Id;
        //-----------------------------------user.UserRoleId = [select id from UserRole where name = :roleName ].id;

        // insert the record
        insert user;
        return user;
    }
    /**
     * Queries for the user for passed uName.
     *
     * @param uName the username.
     * @return A User Object if found, otherwise null.
     */
    public static User getUserForTest(String uName) {
        SecSettings sec = new SecSettings('',uName,'','','');
        return getUserForTest(sec,null);
    }
    /**
     * Defaults to an insert
     *
     * @param secSettings
     * @param dtTstStart
     * @param isActiveUser
     *
     * @return
     */
    public static User getUserForTest(SecSettings secSettings, Datetime dtTstStart, Boolean isActiveUser) {
        return getUserForTest(secSettings,dtTstStart,isActiveUser,true);
    }

    /**
     * Overload of legacy getUserForTest with addition of isActiveUser
     *
     * @param secSettings
     * @param dtTstStart
     * @param isActiveUser
     * @param doInsert       If true insert the user, if false merely return the sObject back for bulk insert later.
     *
     * @return
     */
    public static User getUserForTest(SecSettings secSettings, Datetime dtTstStart, Boolean isActiveUser, Boolean doInsert) {
        list<User> lstUsr = null;
        if (secSettings.us.length() == 0 && secSettings.uName.length() == 0 && secSettings.pr.length() == 0 && secSettings.rl.length() == 0 && secSettings.pm.length() == 0) {
            // for future use lstUsr = [select id, name, lastname from User where isactive = true and id = :UserInfo.getUserId()];
        } else if (secSettings.us.length() > 0) {
            // for future use lstUsr = [select id, name, lastname from User where isactive = true and id = :secSettings.us];
        } else if (secSettings.uName.length() > 0) {
            lstUsr = [select id, name, lastname from User where isactive = true and username = :secSettings.uName];
        }
        if (lstUsr != null && !lstUsr.isEmpty()) {
            return lstUsr[0];
        }
        Double x = Math.random() * 10000;
        String rd = String.valueOf(Integer.valueOf(x));
        User usr = new User();
        usr.FirstName = 'testfirstopmem';
        usr.LastName = 'testlastopmem';
        usr.EmailEncodingKey = 'ISO-8859-1';
        usr.Email = 'info@ext-it.com';
        usr.Alias = rd;
        usr.TimeZoneSidKey = 'America/Los_Angeles';
        if (secSettings.uName.length() > 0) {
            usr.username = secSettings.uName;
        } else {
            // for future use usr.Username = 'somenam' + rd + '@ext-it.com';
        }
        usr.LanguageLocaleKey = 'en_US';
        usr.LocaleSidKey = 'en_US';
        //  https://accel-entertainment.monday.com/boards/284140049/pulses/311330539
        usr.CommunityNickname = generateUniqueString('NN');
        // usr.CommunityNickname = 'NN' + rd;
        usr.IsActive = isActiveUser;
        if (secSettings.pr.length() > 0) {
            //for future use usr.ProfileId = secSettings.pr;
        } else {
            usr.ProfileId = UserSvc.getProfileByName('System Administrator').id;
        }
        if (secSettings.rl.length() > 0) {
            // for future use usr.UserRoleId = secSettings.rl;
        }
        if(doInsert) {
            insert usr;
        }
        if (secSettings.pm.length() > 0) {
            //for future use
//            PermissionSetAssignment psa = new PermissionSetAssignment();
//            psa.AssigneeId = usr.Id;
//            psa.PermissionSetId = secSettings.pm;
//            insert psa;
        }
        return usr;
    }
    /**
     * Retrieves user using SecSettings.uName
     *
     * @param secSettings - Nested class containing user information
     * @param dtTstStart
     *
     * @return A User object if found, otherwise null.
     */
    public static User getUserForTest(SecSettings secSettings, Datetime dtTstStart) {
        return getUserForTest(secSettings,dtTstStart,true);
    }

    public static EmailTemplate buildEmailTemplate(String name,String devName, String type, Id folderId,String subject) {
        EmailTemplate validEmailTemplate = new EmailTemplate();
        validEmailTemplate.isActive = true;
        validEmailTemplate.Name = name;
        validEmailTemplate.DeveloperName = devName;
        validEmailTemplate.TemplateType = type;
        validEmailTemplate.FolderId = folderId;
        validEmailTemplate.Subject = subject;
        return  validEmailTemplate;
    }
    public static Account buildAccount(String accountName, String accountType) {
        Account a = new Account(name = accountName);
        a.type = accountType;
        return a;
    }
    public static Opportunity buildOpportunity(Account account) {
        String oppName = 'Opp for acct ' + account.name;
        Id accountId = account.Id;
        String stageName = 'New';
        Date closeDate = System.today();
        return buildOpportunity(accountId,oppName,stageName,closeDate);
    }
    public static Opportunity buildOpportunity(Id accountId, String oppName, String stageName, Date closeDate) {
        Opportunity opp = new Opportunity();
        opp.Name = oppName;
        opp.Pricebook2Id = Test.getStandardPricebookId();
        opp.StageName = stageName;
        opp.CloseDate = closeDate;
        opp.AccountId = accountId;
        return opp;
    }
    public static Case createCase(String caseSubject, Id assetId) {
        Case cse = new Case(subject = caseSubject, AssetId = assetId);
        insert cse;
        return cse;
    }
    public static Case buildCase(String caseSubject, String recordTypeDevName, Id assetId,Id accountId) {
        Case cse = new Case(subject = caseSubject, AssetId = assetId, AccountId = accountId);
        return cse;
    }
    public static Asset buildAsset(String assetName, Id accountId, String rtName) {
        Asset asset = new Asset(name = assetName);
        if(accountId != null) {
            asset.accountId  = accountId;
        }
        return asset;
    }

    public static Asset createAsset(String assetName) {
        Asset asset = new Asset(name = assetName);
        insert asset;
        return asset;
    }
    /**
     *
     *
     * @param accountName  The Name of the account (will be suffixed by the increment inserted)
     * @param iNumAccts  The Number of accounts to create.
     * @param contactLastName The last name of the contact.
     */
    public static void createAccountsAndContacts(String accountName, Integer iNumAccts, String contactLastName) {
        // Create common test Resellers
        List<Account> testAccts = new List<Account>();
        for (Integer i = 0; i < iNumAccts; i++) {
            testAccts.add(new Account(Name = accountName + i));
        }
        insert testAccts;
        // Create common test Contacts
        List<Contact> testContacts = new List<Contact>();
        for (Account acct : testAccts) {
            Contact c = new Contact(lastname = contactLastName + acct.name, accountid = acct.id);
            testContacts.add(c);
        }
        insert testContacts;
    }

    /**
     *
     *
     * @param name
     * @param timeZone
     * @param iNumRecords
     *
     * @return
     */
    public static List<OperatingHours> buildOppHours(String name, String timeZone, Integer iNumRecords) {
        List<OperatingHours> ohs = new List<OperatingHours> ();
        for(Integer i=0; i < iNumRecords; i++) {
            ohs.add(new OperatingHours( name=name+i,TimeZone=timeZone )) ;
        }
        return ohs;
    }
    public static List<WorkType> buildWorkTypes(Set<String> workTypeNames,Decimal estimatedDuration, String durationType) {
        List<WorkType> workTypes = new List<WorkType> ();
        for(String workTypeName : workTypeNames) {
            workTypes.add(new WorkType(name=workTypeName,estimatedDuration = estimatedDuration, durationType = durationType));
        }
        return workTypes;
    }
    /**
     *
     *
     * @param name
     * @param timeZone
     * @param iNumRecords
     *
     * @return
     */
    public static TimeSlot buildTimeSlot(OperatingHours oh, String dayOfWeek, Time startTime, Time endTime, String type) {
        TimeSlot timeSlot = new TimeSlot(OperatingHoursId = oh.id, DayOfWeek = dayOfWeek, StartTime = startTime, EndTime = endTime, Type = type);
        return timeSlot;
    }
    public static ServiceResource buildSingleServiceResource(String name, Id uId) {
        return new ServiceResource( name=name,RelatedRecordId = uId, ResourceType = 'T',IsActive=true );
    }
    public static List<ServiceResource> buildServiceResource( String name, Id uId ) {
        List<ServiceResource> srs = new List<ServiceResource>();
        srs.add( buildSingleServiceResource(name,uId ));
        return srs;
    }
    public static List<ServiceTerritory> buildServiceTerritories(String name, Id oppHoursId, Integer iNumRecords) {
        List<ServiceTerritory> sts = new List<ServiceTerritory> ();
        for(Integer i=0; i < iNumRecords; i++) {
            sts.add(new ServiceTerritory(name = name + i, OperatingHoursId = oppHoursId, IsActive = true));
        }
        return sts;
    }
//    public static List<FSL__User_Territory__c> buildUserTerritories(Id userId, Set<Id> serviceTerritoryIds, String accelRole) {
//        List<FSL__User_Territory__c> userTerritories = new List<FSL__User_Territory__c>();
//        for(Id stId : serviceTerritoryIds) {
//            FSL__User_Territory__c ut = new FSL__User_Territory__c(FSL__User__c = userId, FSL__ServiceTerritory__c = stId, Accel_Role__c = accelRole);
//            userTerritories.add(ut);
//        }
//        return userTerritories;
//    }
    public static ServiceTerritoryMember buildServiceTerritoryMember(Id serviceResourceId, Id serviceTerritoryId, Id oppHoursId, String territoryType,
            DateTime startDatetime, DateTime endDatetime) {
        ServiceTerritoryMember stm = new ServiceTerritoryMember(ServiceResourceId=serviceResourceId, ServiceTerritoryId=serviceTerritoryId,
                OperatingHoursId=oppHoursId, TerritoryType=territoryType,
                EffectiveStartDate=startDatetime);
        //EffectiveEndDate = endDatetime
        return stm;
    }
    /**
     *  @TODO Lots of work to be done here. this is hacked up initially but really needs to be cleaned up.
     */
    public static void createMemberTimeSlots(String uName) {
        Datetime dtTstStart = Datetime.now();
        TestUtils.SecSettings sec = new TestUtils.SecSettings('', UNAME, '', '', '');
        User u = TestUtils.getUserForTest(sec, dtTstStart);
        List<OperatingHours> ohs = TestUtils.buildOppHours('Accel test opp hours', 'America/Chicago',2);
        insert ohs;
        List<ServiceResource> srs = TestUtils.buildServiceResource(u.firstname + ' ' + u.lastname, u.Id);
        insert srs;
        List<ServiceTerritory> sts = TestUtils.buildServiceTerritories('Accel Test Territory Name ',ohs[0].id,2);

        for(ServiceTerritory st : sts) {
            st.name = 'All Regions';
            break;
        }
        insert sts;
        set<id> stIds = new set<id>();
        for(ServiceTerritory st : sts) {
            stIds.add(st.id);
        }
        //List<FSL__User_Territory__c> userTerritories = TestUtils.buildUserTerritories(u.id,stIDs,'Supervisor');
        //insert userTerritories;

        List<ServiceTerritoryMember> serviceTerritoryMembers = new List<ServiceTerritoryMember>();
        Integer i = 0;
        // for(ServiceTerritory st : sts) {
        ServiceTerritory st = sts[0];
        DateTime startDatetime = System.now();
        DateTime endDateTime = startDatetime.addDays(1);
        serviceTerritoryMembers.add(TestUtils.buildServiceTerritoryMember(srs[0].id,st.id, ohs[0].id,'P',startDatetime,endDateTime));
        //   i++;
        //}
        insert serviceTerritoryMembers;
        List<TimeSlot> timeSlots = new List<TimeSlot>();
        TimeSlot ts = TestUtils.buildTimeSlot(ohs[0],'Monday',Time.newInstance(1, 2, 3, 0),Time.newInstance(6, 2, 3, 0),'Normal');
        insert ts;

    }

    /**
     *
     *
     * @param numChars
     *
     * @return
     */
    public static String generateRandomString(Integer numChars) {

        //declare local vars
        String randomNumString = '';
        String returnVal = '';
        List <String> charArray = new String [] {'A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T','U','V','W','X','Y','Z','a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','x','y','z','0','1','2','3','4','5','6','7','8','9','-','$','#','!','@','+','=','%'};


        // generate the requisite random number strings
        for (Integer x = 0; x < 100; x++) {
            // generate a random number
            String tempStr = String.valueOf(Math.random());
            // take all of the digits to the right of the decimal point
            randomNumString += tempStr.substring(2);

            // determine if we have enough characters
            if (randomNumString.length() >= numChars) {
                x = 101;
            }
        }
        // trim the string if we ran over
        if (randomNumString.length() > numChars) {
            randomNumString = randomNumString.substring(0,numChars);
        }

        // build the random character string
        for (Integer x = 0; x < randomNumString.length(); x++) {

            // declare local vars
            String currentNum = '';
            String newChar = '';
            String randomNum = String.valueOf(Math.random());
            Integer ndxMultiplier = 0;

            // get a handle on the current character
            currentNum = randomNumString.substring(x,x+1);

            // get the multiplier from the new random number string
            for (Integer y = 2; y < randomNum.length(); y++) {
                ndxMultiplier = Integer.valueOf(randomNum.substring(y,y+1));
                if (ndxMultiplier < 8) {
                    newChar = charArray[ndxMultiplier * Integer.valueOf(currentNum)];
                    y = randomNum.length();
                }
            }
            returnVal += newChar;
        }
        // return the random character string
        return returnVal;
    }
    public class SecSettings {
        public String us    {get; set;}	    //User Id
        public String uName {get; set;}	    //User Name
        public String pr    {get; set;}	    //Profile Id
        public String rl    {get; set;}	    //Role Id
        public String pm    {get; set;}	    //Permission Set Id

        public SecSettings(String sUser, String sUserName, String sProf, String sRole, String sPM) {
            this.us = sUser;
            this.uName = sUserName;
            this.pr = sProf;
            this.rl = sRole;
            this.pm = sPm;
        }
    }
//    /**s
////     *
////     *
////     * @param mFieldSetWrappersByApiName
////     */
////    public static void debugFieldSetWrappersAndFieldSetMembers(Map<String,FieldSetWrapper> mFieldSetWrappersByApiName ) {
////        System.debug('_____ number of field set wrappers found='+mFieldSetWrappersByApiName.size());
////        for(String fsApiName : mFieldSetWrappersByApiName.keySet()) {
////            System.debug('==========================================================');
////            System.debug('fsApiName ----> '+fsApiName);
////            FieldSetWrapper fsw = mFieldSetWrappersByApiName.get(fsApiName);
////            System.debug('FieldSetWrapper SobjectName -----> '+ fsw.fieldSetSObjectApiName);
////            System.debug('FieldSetWrapper SObjectRecordId--->' + fsw.fieldSetSObjectRecordId);
////            System.debug('FieldSetWrapper Label       -----> '+ fsw.fieldSetLabel);
////            List<FieldSetMemberWrapper> fsMemberWrappers = fsw.fieldSetMemberWrappers;
////            System.debug('->>>>>>>>>  Field Set Member Wrappers <<<<<<<<<<');
////            for(FieldSetMemberWrapper fsm : fsMemberWrappers) {
////                System.debug('fieldApiName-->'+fsm.fieldApiName);
////                System.debug('fieldValue-->'+fsm.fieldValue);
////            }
////            System.debug('==========================================================');
////        }
////    }
}