@isTest
public class UserTriggerTest {
    @testSetup static void loadDatas() {
        Profile pf= [Select Id from profile where Name = 'System Administrator']; 
        User usr;
        try {
            usr = [SELECT id from User WHERE Username = :HireVueConstants.TEST_DATA_USER_EMAIL_ADDRESS_2];
        } catch(Exception ex) {
        	usr = new User(
                firstname = 'ABC', 
                lastName = 'XYZ', 
                email = HireVueConstants.TEST_DATA_USER_EMAIL_ADDRESS_2, 
                Username = HireVueConstants.TEST_DATA_USER_EMAIL_ADDRESS_2, 
                EmailEncodingKey = 'ISO-8859-1', 
                Alias = 'abc', 
                TimeZoneSidKey = 'America/Los_Angeles', 
                LocaleSidKey = 'en_US', 
                LanguageLocaleKey = 'en_US', 
                ProfileId = pf.Id,
                isActive = true
            );
            insert usr;    
        }
        
    }
    @isTest static void success_createUserInHireVue() {
        user usr = [SELECT Id, Email FROM User WHERE Username = :HireVueConstants.TEST_DATA_USER_EMAIL_ADDRESS_2];
        Map<String, String> mp_HireVueConfigs = HireVueTestData.getHireVueConfigs();
        Map<String, HttpCalloutMock> mp_fakeResponses = HireVueTestData.getMockReponsesForUserTrigger(mp_HireVueConfigs);
        HttpCalloutMock multiCalloutMock = new HireVueMultiRequestMock(mp_fakeResponses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.startTest();
        UserRole uRole = new UserRole(Name = 'Screener');
        insert uRole;      
        usr.UserRoleId = uRole.Id;
        update usr;
        Test.stopTest();
        usr = [SELECT Hirevue_Position_Id__c FROM User WHERE Id = :usr.Id];
        System.assert(usr.Hirevue_Position_Id__c != null, 'Hire Position Id should be populated');
    }
    
    @isTest static void success_createPositionIfUserAlreadyExist() {
        user usr = [SELECT Id, Email FROM User WHERE Username = :HireVueConstants.TEST_DATA_USER_EMAIL_ADDRESS_2];
        
        Map<String, String> mp_HireVueConfigs = HireVueTestData.getHireVueConfigs();
        Map<String, HttpCalloutMock> mp_fakeResponses = HireVueTestData.getMockReponsesForUserTrigger(mp_HireVueConfigs); 
        String baseUrl = mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL);
        // fake mock - User found for user fetch
        String usrResBody = '{"username":"abc@usertriggettestbytekclan.com","phone":"9952991642","language":"en","id":3607527,"firstName":"ABC","fullName":"ABC XYZ","lastName":"XYZ"}';
        HireVueSingleRequestMock singleReqMock = new HireVueSingleRequestMock(200, 'Complete', usrResBody, null);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_USER + usr.Email +'/', singleReqMock);
        HttpCalloutMock multiCalloutMock = new HireVueMultiRequestMock(mp_fakeResponses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.startTest();
        UserRole uRole = new UserRole(Name = 'Screener');
        insert uRole;      
        usr.UserRoleId = uRole.Id;
        update usr;
        Test.stopTest();
        usr = [SELECT Hirevue_Position_Id__c FROM User WHERE Id = :usr.Id];
        System.assert(usr.Hirevue_Position_Id__c != null, 'Hire Position Id should be populated');
    }
    
    @isTest static void success_getPositionFromHireVueAndUpdateTheUser() {
        user usr = [SELECT Id, Email FROM User WHERE Username = :HireVueConstants.TEST_DATA_USER_EMAIL_ADDRESS_2];
 		
        Map<String, String> mp_HireVueConfigs = HireVueTestData.getHireVueConfigs();
        Map<String, HttpCalloutMock> mp_fakeResponses = HireVueTestData.getMockReponsesForUserTrigger(mp_HireVueConfigs); 
        
        Map<String, String> mp_responsHeader = new Map<String, String>();
        String baseUrl = mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL);
        HireVueSingleRequestMock singleReqMock; 
        // fake mock - User found for user fetch
        String usrResBody = '{"username":"abc@usertriggettestbytekclan.com","phone":"9952991642","language":"en","id":3607527,"firstName":"ABC","fullName":"ABC XYZ","lastName":"XYZ"}';
        singleReqMock = new HireVueSingleRequestMock(200, 'Complete', usrResBody, null);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_USER + usr.Email +'/', singleReqMock);
        // fake mock - position Fetch
        String posResBody = '[{"isArchived":false,"id":2355255,"interviewType":"live-recorded","isDraft":false}]';
        singleReqMock = new HireVueSingleRequestMock(200,'Complete', posResBody, null);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_POSITION + '?qf=[creator.username:exact:abc@usertriggettestbytekclan.com][!isArchived][!isDraft]&qo=-createDate', singleReqMock);
        HttpCalloutMock multiCalloutMock = new HireVueMultiRequestMock(mp_fakeResponses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.startTest();
        UserRole uRole = new UserRole(Name = 'Screener');
        insert uRole;      
        usr.UserRoleId = uRole.Id;
        update usr;
        Test.stopTest();
        usr = [SELECT Hirevue_Position_Id__c FROM User WHERE Id = :usr.Id];
        System.assert(usr.Hirevue_Position_Id__c != null, 'Hire Position Id should be populated');
    }
    
    @isTest static void success_userDeactivation() {
        user usr = [SELECT Id, Email FROM User WHERE Username = :HireVueConstants.TEST_DATA_USER_EMAIL_ADDRESS_2];
 		
        Map<String, String> mp_HireVueConfigs = HireVueTestData.getHireVueConfigs();    
        Map<String, HttpCalloutMock> mp_fakeResponses = new Map<String,HttpCalloutMock>();
        
        Map<String, String> mp_responsHeader = new Map<String, String>();
        String baseUrl = mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL);
        HireVueSingleRequestMock singleReqMock; 
        // fake mock - login
        mp_responsHeader.put(HireVueConstants.HDR_KEY_SET_COOKIE, HireVueConstants.TEST_DATA_COOKIE_VALUE);
        mp_responsHeader.put(HireVueConstants.HDR_KEY_CSRFTOKEN, HireVueConstants.TEST_DATA_CSRFTOKEN_VALUE);
        singleReqMock = new HireVueSingleRequestMock(200,'Complete', '', mp_responsHeader);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_LOGIN, singleReqMock);
        // fake mock - User Update
        singleReqMock = new HireVueSingleRequestMock(204,'No Content', '', null);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_USER + usr.Email + '/', singleReqMock);
        HttpCalloutMock multiCalloutMock = new HireVueMultiRequestMock(mp_fakeResponses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.startTest();
        UserRole uRole = new UserRole(Name = 'Screener');
        insert uRole;  
        usr.Hirevue_Position_Id__c = '2355255';
        usr.UserRoleId = uRole.Id;
        usr.isActive = false;
        update usr;
        Test.stopTest();
        usr = [SELECT Hirevue_Position_Id__c FROM User WHERE Id = :usr.Id];
        System.assert(usr.Hirevue_Position_Id__c != null, 'Hire Position Id should be populated');
    }
    
    @isTest static void failure_userDeactivationFailed() {
        user usr = [SELECT Id, Email FROM User WHERE Username = :HireVueConstants.TEST_DATA_USER_EMAIL_ADDRESS_2];
 		
        Map<String, String> mp_HireVueConfigs = HireVueTestData.getHireVueConfigs();    
        Map<String, HttpCalloutMock> mp_fakeResponses = new Map<String,HttpCalloutMock>();
        
        Map<String, String> mp_responsHeader = new Map<String, String>();
        String baseUrl = mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL);
        HireVueSingleRequestMock singleReqMock; 
        // fake mock - login
        mp_responsHeader.put(HireVueConstants.HDR_KEY_SET_COOKIE, HireVueConstants.TEST_DATA_COOKIE_VALUE);
        mp_responsHeader.put(HireVueConstants.HDR_KEY_CSRFTOKEN, HireVueConstants.TEST_DATA_CSRFTOKEN_VALUE);
        singleReqMock = new HireVueSingleRequestMock(200,'Complete', '', mp_responsHeader);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_LOGIN, singleReqMock);
        // fake mock - User Update failed
        mp_responsHeader.put(HireVueConstants.HDR_KEY_API_ERROR, 'VALIDATIONERROR');
        singleReqMock = new HireVueSingleRequestMock(400,'Bad Request', '', mp_responsHeader);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_USER + usr.Email + '/', singleReqMock);
        HttpCalloutMock multiCalloutMock = new HireVueMultiRequestMock(mp_fakeResponses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.startTest();
        UserRole uRole = new UserRole(Name = 'Screener');
        insert uRole;  
        usr.Hirevue_Position_Id__c = '2355255';
        usr.UserRoleId = uRole.Id;
        usr.isActive = false;
        update usr;
        Test.stopTest();
        ErrorLog__c errLog = [SELECT Message__c FROM ErrorLog__c];
        System.assert(errLog.Message__c.contains('VALIDATIONERROR'), 'HireVue User deactivation Failed');
    }
    @isTest static void Failure_loginFailed() {
        user usr = [SELECT Id, Email FROM User WHERE Username = :HireVueConstants.TEST_DATA_USER_EMAIL_ADDRESS_2];
 		
        Map<String, String> mp_HireVueConfigs = HireVueTestData.getHireVueConfigs();    
        Map<String, HttpCalloutMock> mp_fakeResponses = new Map<String,HttpCalloutMock>();
        
        Map<String, String> mp_responsHeader = new Map<String, String>();
        String baseUrl = mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL);
        HireVueSingleRequestMock singleReqMock; 
        mp_responsHeader = new Map<String, String>();
        mp_responsHeader.put(HireVueConstants.HDR_KEY_API_ERROR, 'LOGINFAILED');
        singleReqMock = new HireVueSingleRequestMock(400,'Bad Request', 'Invalid Crendentials', mp_responsHeader);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_LOGIN, singleReqMock);
        HttpCalloutMock multiCalloutMock = new HireVueMultiRequestMock(mp_fakeResponses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.startTest();
        UserRole uRole = new UserRole(Name = 'Screener');
        insert uRole;      
        usr.UserRoleId = uRole.Id;
        update usr;
        Test.stopTest();
        ErrorLog__c errLog = [SELECT Message__c FROM ErrorLog__c];
        System.assert(errLog.Message__c.contains('LOGINFAILED'), 'HireVue Login Failed');
    }
    @isTest static void Failure_userCreationFailed() {
        user usr = [SELECT Id, Email FROM User WHERE Username = :HireVueConstants.TEST_DATA_USER_EMAIL_ADDRESS_2];
 		
        Map<String, String> mp_HireVueConfigs = HireVueTestData.getHireVueConfigs();
        Map<String, HttpCalloutMock> mp_fakeResponses = HireVueTestData.getMockReponsesForUserTrigger(mp_HireVueConfigs);
        
        Map<String, String> mp_responsHeader = new Map<String, String>();
        String baseUrl = mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL);
        HireVueSingleRequestMock singleReqMock; 
        // fake mock - User creation Failed
        mp_responsHeader.put(HireVueConstants.HDR_KEY_API_ERROR, 'VALIDATIONERROR');
        singleReqMock = new HireVueSingleRequestMock(400,'Bad Request', '', mp_responsHeader);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_USER, singleReqMock);
        HttpCalloutMock multiCalloutMock = new HireVueMultiRequestMock(mp_fakeResponses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.startTest();
        UserRole uRole = new UserRole(Name = 'Screener');
        insert uRole;      
        usr.UserRoleId = uRole.Id;
        update usr;
        Test.stopTest();
        ErrorLog__c errLog = [SELECT Message__c FROM ErrorLog__c];
        System.assert(errLog.Message__c.contains('VALIDATIONERROR'), 'HireVue User Creation Failed');
    }
    
    @isTest static void Failure_positionCreationFailed() {
        user usr = [SELECT Id, Email FROM User WHERE Username = :HireVueConstants.TEST_DATA_USER_EMAIL_ADDRESS_2];
        
        Map<String, String> mp_HireVueConfigs = HireVueTestData.getHireVueConfigs();
        Map<String, HttpCalloutMock> mp_fakeResponses = HireVueTestData.getMockReponsesForUserTrigger(mp_HireVueConfigs);
        
        Map<String, String> mp_responsHeader = new Map<String, String>();
        String baseUrl = mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL);
        HireVueSingleRequestMock singleReqMock; 
        // fake mock - position creation failed
        mp_responsHeader.put(HireVueConstants.HDR_KEY_API_ERROR, 'VALIDATIONERROR');
        singleReqMock = new HireVueSingleRequestMock(400, 'Bad Request', '', mp_responsHeader);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_POSITION, singleReqMock);
        HttpCalloutMock multiCalloutMock = new HireVueMultiRequestMock(mp_fakeResponses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.startTest();
        UserRole uRole = new UserRole(Name = 'Screener');
        insert uRole;      
        usr.UserRoleId = uRole.Id;
        update usr;
        Test.stopTest();
        ErrorLog__c errLog = [SELECT Message__c FROM ErrorLog__c];
        System.assert(errLog.Message__c.contains('VALIDATIONERROR'), 'HireVue position Creation Failed');
    }
    
    @isTest static void Failure_SesssionFetchFailed() {
        user usr = [SELECT Id, Email FROM User WHERE Username = :HireVueConstants.TEST_DATA_USER_EMAIL_ADDRESS_2];
        
        Map<String, String> mp_HireVueConfigs = HireVueTestData.getHireVueConfigs();
        Map<String, HttpCalloutMock> mp_fakeResponses = HireVueTestData.getMockReponsesForUserTrigger(mp_HireVueConfigs);
        
        Map<String, String> mp_responsHeader = new Map<String, String>();
        String baseUrl = mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL);
        HireVueSingleRequestMock singleReqMock; 
        // fake mock - Session Fetch Failed attached to position
        mp_responsHeader.put(HireVueConstants.HDR_KEY_API_ERROR, 'VALIDATIONERROR');
        singleReqMock = new HireVueSingleRequestMock(400, 'Bad Request', '', mp_responsHeader);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_POSITION + '2355255/interview-template/sessions/', singleReqMock);
        HttpCalloutMock multiCalloutMock = new HireVueMultiRequestMock(mp_fakeResponses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.startTest();
        UserRole uRole = new UserRole(Name = 'Screener');
        insert uRole;      
        usr.UserRoleId = uRole.Id;
        update usr;
        Test.stopTest();
        ErrorLog__c errLog = [SELECT Message__c FROM ErrorLog__c];
        System.assert(errLog.Message__c.contains('VALIDATIONERROR'), 'HireVue Session Fetch Failed');
    }
    
    @isTest static void Failure_positionUpdateFailed() {
        user usr = [SELECT Id, Email FROM User WHERE Username = :HireVueConstants.TEST_DATA_USER_EMAIL_ADDRESS_2];
        
        Map<String, String> mp_HireVueConfigs = HireVueTestData.getHireVueConfigs();
        Map<String, HttpCalloutMock> mp_fakeResponses = HireVueTestData.getMockReponsesForUserTrigger(mp_HireVueConfigs);
        
        Map<String, String> mp_responsHeader = new Map<String, String>();
        String baseUrl = mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL);
        HireVueSingleRequestMock singleReqMock; 
        // fake mock - position update failed
        mp_responsHeader.put(HireVueConstants.HDR_KEY_API_ERROR, 'VALIDATIONERROR');
        singleReqMock = new HireVueSingleRequestMock(400, 'Bad Request', '', mp_responsHeader);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_POSITION +'2355255/', singleReqMock);
        HttpCalloutMock multiCalloutMock = new HireVueMultiRequestMock(mp_fakeResponses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        Test.startTest();
        UserRole uRole = new UserRole(Name = 'Screener');
        insert uRole;      
        usr.UserRoleId = uRole.Id;
        update usr;
        Test.stopTest();
        ErrorLog__c errLog = [SELECT Message__c FROM ErrorLog__c];
        System.assert(errLog.Message__c.contains('VALIDATIONERROR'), 'HireVue position update Failed');
    }
    
}