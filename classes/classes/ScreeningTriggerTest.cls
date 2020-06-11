@isTest
public class ScreeningTriggerTest {

    @testSetup static void loadDatas() {
        Profile pf= [Select Id from profile where Name = 'System Administrator']; 
       	UserRole uRole = new UserRole(Name = 'Screener');
        insert uRole;
        List<User> userToInsert = new List<User>();
        User usr;
        try {
            usr = [SELECT Id, Email FROM User WHERE Email = 'abc@screeningtriggettestbytekclan.com'];
        } catch(Exception ex) {
            usr = new User(
                firstname = 'ABC', 
                lastName = 'XYZ', 
                email = 'abc@screeningtriggettestbytekclan.com', 
                Username = 'abc@screeningtriggettestbytekclan.com', 
                EmailEncodingKey = 'ISO-8859-1', 
                Alias = 'abc', 
                TimeZoneSidKey = 'America/Los_Angeles', 
                LocaleSidKey = 'en_US', 
                LanguageLocaleKey = 'en_US', 
                ProfileId = pf.Id,
                isActive = true,
                UserRoleId = uRole.Id,
                Hirevue_Position_Id__c = '2355255'
            );
        	userToInsert.add(usr);
        }
        try {
            usr = [SELECT Id, Email FROM User WHERE Email = 'abc.evaluator@usertriggettestbytekclan.com'];
        } catch(Exception ex) {
            usr = new User(
                firstname = 'ABCEvaluator', 
                lastName = 'XYZ', 
                email = 'abc.evaluator@usertriggettestbytekclan.com', 
                Username = 'abc.evaluator@usertriggettestbytekclan.com', 
                EmailEncodingKey = 'ISO-8859-1', 
                Alias = 'abc', 
                TimeZoneSidKey = 'America/Los_Angeles', 
                LocaleSidKey = 'en_US', 
                LanguageLocaleKey = 'en_US', 
                ProfileId = pf.Id,
                isActive = true,
                UserRoleId = uRole.Id,
                Hirevue_Position_Id__c = '2355256'
            );
            userToInsert.add(usr);
        }
        insert userToInsert;    
        Test.startTest();
        HireVueTestData.loadPreRequisiteDatas('abc@screeningtriggettestbytekclan.com');
        Test.stopTest();        
    }
    
    @isTest static void success_CandidateCreation() {
        Map<String, String> mp_HireVueConfigs = HireVueTestData.getHireVueConfigs();
        Map<String, HttpCalloutMock> mp_fakeResponses = HireVueTestData.getMockReponsesForScreeningTrigger(mp_HireVueConfigs);
        HttpCalloutMock multiCalloutMock = new HireVueMultiRequestMock(mp_fakeResponses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
         
        Screening__c screen = [SELECT Id FROM Screening__c];
        screen.ScreenStatus__c = HireVueConstants.STATUS_SCREENED;
        Test.startTest();
        update screen;
        Test.stopTest();
        screen = [SELECT Id, Interviewer_Interview_Link__c, HireVue_Interview_Id__c, Hirevue_Position_Id__c, Candidate_Interview_Link__c FROM Screening__c];
        System.assert(screen.Interviewer_Interview_Link__c != null, 'Interviewer interview link should be populated');
        System.assert(screen.HireVue_Interview_Id__c != null, 'Interview Id should be populated');
        System.assert(screen.Hirevue_Position_Id__c != null, 'Position Id should be populated');
        System.assert(screen.Candidate_Interview_Link__c != null, 'Candidate interview should be populated');
    }
   
    @isTest static void success_AddEvaluators() {
        user usr = [SELECT Id, Email, Hirevue_Position_Id__c FROM User WHERE Username = 'abc.evaluator@usertriggettestbytekclan.com'];
        
        Map<String, String> mp_HireVueConfigs = HireVueTestData.getHireVueConfigs();
        Map<String, HttpCalloutMock> mp_fakeResponses = HireVueTestData.getMockReponsesForScreeningTrigger(mp_HireVueConfigs);
        
        Map<String, String> mp_responsHeader = new Map<String, String>();
        String baseUrl = mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL);
        HireVueSingleRequestMock singleReqMock; 
        // fake mock - User found for user fetch
        String usrResBody = '{"username":"abc.evaluator@usertriggettestbytekclan.com","phone":"9952991642","language":"en","id":3607527,"firstName":"ABC","fullName":"ABC XYZ","lastName":"XYZ"}';
        singleReqMock = new HireVueSingleRequestMock(200, 'Complete', usrResBody, null);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_USER + usr.Email +'/', singleReqMock);
        // fake mock - Assign Evaluators to a candidate
        singleReqMock = new HireVueSingleRequestMock(204,'Complete', '', null);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_POSITION +'2355255/evaluators/'+usr.Email+'/assignments/', singleReqMock);

        HttpCalloutMock multiCalloutMock = new HireVueMultiRequestMock(mp_fakeResponses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
                
        Screening__c screen = [SELECT Id FROM Screening__c];
        screen.ScreenStatus__c = HireVueConstants.STATUS_SCREENED;
        screen.HireVue_Interview_Id__c = '43148575';
        screen.Hirevue_Position_Id__c = '2355255';
        screen.Screener__c = usr.Id;
        Test.startTest();
        update screen;
        Test.stopTest();
        List<ErrorLog__c> errLogList = [SELECT Message__c FROM ErrorLog__c];
        System.assert(errLogList.isEmpty(), 'No Error Log should be created for Successfull Evaluator assignment');
    }
	
    @isTest static void success_deleteCandidateRecordInHireVue() {
        user usr = [SELECT Id, Email, Hirevue_Position_Id__c FROM User WHERE Username = 'abc@screeningtriggettestbytekclan.com'];
        
        Map<String, String> mp_HireVueConfigs = HireVueTestData.getHireVueConfigs();
        Map<String, HttpCalloutMock> mp_fakeResponses = HireVueTestData.getMockReponsesForScreeningTrigger(mp_HireVueConfigs);
        
        String baseUrl = mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL);
        HireVueSingleRequestMock singleReqMock; 
        // fake mock - delete candidate
        singleReqMock = new HireVueSingleRequestMock(204,'Complete', '', null);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_POSITION +'2355255/interviews/43148575/', singleReqMock);

        HttpCalloutMock multiCalloutMock = new HireVueMultiRequestMock(mp_fakeResponses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
                
        Screening__c screen = [SELECT Id FROM Screening__c];
        screen.ScreenStatus__c = HireVueConstants.STATUS_CANCELLED;
        screen.HireVue_Interview_Id__c = '43148575';
        screen.Hirevue_Position_Id__c = '2355255';
        screen.Screener__c = usr.Id;
        Test.startTest();
        update screen;
        Test.stopTest();
        List<ErrorLog__c> errLogList = [SELECT Message__c FROM ErrorLog__c];
        System.assert(errLogList.isEmpty(), 'No Error Log should be created for Successfull candidate deletion in HireVues');
    }
    
    @isTest static void Failure_loginFailedWhileCreatingCandidate() { 		
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
        Screening__c screen = [SELECT Id FROM Screening__c];
        screen.ScreenStatus__c = HireVueConstants.STATUS_SCREENED;
        Test.startTest();
        update screen;
        Test.stopTest();
        ErrorLog__c errLog = [SELECT Message__c FROM ErrorLog__c];
        System.assert(errLog.Message__c.contains('LOGINFAILED'), 'HireVue Login Failed');
    }
    @isTest static void Failure_loginFailedWhileDeletingCandidate() { 		
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
        Screening__c screen = [SELECT Id FROM Screening__c];
        screen.ScreenStatus__c = HireVueConstants.STATUS_CANCELLED;
        screen.HireVue_Interview_Id__c = '43148575';
        screen.Hirevue_Position_Id__c = '2355255';
        Test.startTest();
        update screen;
        Test.stopTest();
        ErrorLog__c errLog = [SELECT Message__c FROM ErrorLog__c];
        System.assert(errLog.Message__c.contains('LOGINFAILED'), 'HireVue Login Failed');
    }
    @isTest static void Failure_FailedWhileCreatingCandidate() {
        user usr = [SELECT Id, Email, Hirevue_Position_Id__c FROM User WHERE Username = 'abc@screeningtriggettestbytekclan.com'];
        Map<String, String> mp_HireVueConfigs = HireVueTestData.getHireVueConfigs();
        Map<String, HttpCalloutMock> mp_fakeResponses = HireVueTestData.getMockReponsesForScreeningTrigger(mp_HireVueConfigs);
        Map<String, String> mp_responsHeader = new Map<String, String>();
        String baseUrl = mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL);
        HireVueSingleRequestMock singleReqMock; 
        mp_responsHeader = new Map<String, String>();
        mp_responsHeader.put(HireVueConstants.HDR_KEY_API_ERROR, 'VALIDATIONERROR');
        singleReqMock = new HireVueSingleRequestMock(400,'Bad Request', 'TimeZone is required', mp_responsHeader);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_POSITION + usr.Hirevue_Position_Id__c +'/interviews/', singleReqMock);
        HttpCalloutMock multiCalloutMock = new HireVueMultiRequestMock(mp_fakeResponses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
         
        Screening__c screen = [SELECT Id FROM Screening__c];
        screen.ScreenStatus__c = HireVueConstants.STATUS_SCREENED;
        Test.startTest();
        update screen;
        Test.stopTest();
        ErrorLog__c errLog = [SELECT Message__c FROM ErrorLog__c];
        System.assert(errLog.Message__c.contains('VALIDATIONERROR'), 'HireVue Candidate Creation Failed');
    }
    
    @isTest static void Failure_FailedWhileFetchingCandidate() {
        user usr = [SELECT Id, Email, Hirevue_Position_Id__c FROM User WHERE Username = 'abc@screeningtriggettestbytekclan.com'];
        Map<String, String> mp_HireVueConfigs = HireVueTestData.getHireVueConfigs();
        Map<String, HttpCalloutMock> mp_fakeResponses = HireVueTestData.getMockReponsesForScreeningTrigger(mp_HireVueConfigs);
        Map<String, String> mp_responsHeader = new Map<String, String>();
        String baseUrl = mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL);
        HireVueSingleRequestMock singleReqMock; 
        mp_responsHeader.put(HireVueConstants.HDR_KEY_API_ERROR, 'UNAUTHORIZED');
        singleReqMock = new HireVueSingleRequestMock(401, 'UNAUTHORIZED', '', mp_responsHeader);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_POSITION + usr.Hirevue_Position_Id__c + '/interviews/43148575/', singleReqMock);
        HttpCalloutMock multiCalloutMock = new HireVueMultiRequestMock(mp_fakeResponses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
         
        Screening__c screen = [SELECT Id FROM Screening__c];
        screen.ScreenStatus__c = HireVueConstants.STATUS_SCREENED;
        Test.startTest();
        update screen;
        Test.stopTest();
        ErrorLog__c errLog = [SELECT Message__c FROM ErrorLog__c];
        System.assert(errLog.Message__c.contains('UNAUTHORIZED'), 'HireVue Candidate Fetch Failed');
    }
    @isTest static void failure_FailedWhileCreatingEvaluators() {
        user usr = [SELECT Id, Email, Hirevue_Position_Id__c FROM User WHERE Username = 'abc.evaluator@usertriggettestbytekclan.com'];
        
        Map<String, String> mp_HireVueConfigs = HireVueTestData.getHireVueConfigs();
        Map<String, HttpCalloutMock> mp_fakeResponses = HireVueTestData.getMockReponsesForScreeningTrigger(mp_HireVueConfigs);
        
        Map<String, String> mp_responsHeader = new Map<String, String>();
        String baseUrl = mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL);
        HireVueSingleRequestMock singleReqMock; 
        // fake mock - User found for user fetch
        String usrResBody = '{"username":"abc.evaluator@usertriggettestbytekclan.com","phone":"9952991642","language":"en","id":3607527,"firstName":"ABC","fullName":"ABC XYZ","lastName":"XYZ"}';
        singleReqMock = new HireVueSingleRequestMock(200, 'Complete', usrResBody, null);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_USER + usr.Email +'/', singleReqMock);
		// fake mock - Evaluation creation failed
        mp_responsHeader = new Map<String, String>();
        mp_responsHeader.put(HireVueConstants.HDR_KEY_API_ERROR, 'VALIDATIONERROR');
        singleReqMock = new HireVueSingleRequestMock(400,'Bad Request', '', mp_responsHeader);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_POSITION + '2355255/evaluators/', singleReqMock);
        // fake mock - Assign Evaluators to a candidate
       /* singleReqMock = new HireVueSingleRequestMock(204,'Complete', '', null);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_POSITION +'2355255/evaluators/'+usr.Email+'/assignments/', singleReqMock);*/

        HttpCalloutMock multiCalloutMock = new HireVueMultiRequestMock(mp_fakeResponses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
                
        Screening__c screen = [SELECT Id FROM Screening__c];
        screen.ScreenStatus__c = HireVueConstants.STATUS_SCREENED;
        screen.HireVue_Interview_Id__c = '43148575';
        screen.Hirevue_Position_Id__c = '2355255';
        screen.Screener__c = usr.Id;
        Test.startTest();
        update screen;
        Test.stopTest();
        ErrorLog__c errLog = [SELECT Message__c FROM ErrorLog__c];
        System.assert(errLog.Message__c.contains('VALIDATIONERROR'), 'HireVue Evaluator Creation Failed');
    }
    @isTest static void failure_FailedWhileAssigningEvaluators() {
        user usr = [SELECT Id, Email, Hirevue_Position_Id__c FROM User WHERE Username = 'abc.evaluator@usertriggettestbytekclan.com'];
        
        Map<String, String> mp_HireVueConfigs = HireVueTestData.getHireVueConfigs();
        Map<String, HttpCalloutMock> mp_fakeResponses = HireVueTestData.getMockReponsesForScreeningTrigger(mp_HireVueConfigs);
        
        Map<String, String> mp_responsHeader = new Map<String, String>();
        String baseUrl = mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL);
        HireVueSingleRequestMock singleReqMock; 
        // fake mock - User found for user fetch
        String usrResBody = '{"username":"abc.evaluator@usertriggettestbytekclan.com","phone":"9952991642","language":"en","id":3607527,"firstName":"ABC","fullName":"ABC XYZ","lastName":"XYZ"}';
        singleReqMock = new HireVueSingleRequestMock(200, 'Complete', usrResBody, null);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_USER + usr.Email +'/', singleReqMock);
        // fake mock - Assign Evaluators to a candidate
       	mp_responsHeader.put(HireVueConstants.HDR_KEY_API_ERROR, 'VALIDATIONERROR');
        singleReqMock = new HireVueSingleRequestMock(400,'Bad Request', '', mp_responsHeader);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_POSITION +'2355255/evaluators/'+usr.Email+'/assignments/', singleReqMock);

        HttpCalloutMock multiCalloutMock = new HireVueMultiRequestMock(mp_fakeResponses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
                
        Screening__c screen = [SELECT Id FROM Screening__c];
        screen.ScreenStatus__c = HireVueConstants.STATUS_SCREENED;
        screen.HireVue_Interview_Id__c = '43148575';
        screen.Hirevue_Position_Id__c = '2355255';
        screen.Screener__c = usr.Id;
        Test.startTest();
        update screen;
        Test.stopTest();
        ErrorLog__c errLog = [SELECT Message__c FROM ErrorLog__c];
        System.assert(errLog.Message__c.contains('VALIDATIONERROR'), 'HireVue Evaluator Assignment Failed');
    }
}