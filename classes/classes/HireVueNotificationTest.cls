@isTest
public class HireVueNotificationTest {

    @testSetup static void loadDatas() {
        Profile pf= [Select Id from profile where Name = 'System Administrator']; 
       	UserRole uRole = new UserRole(Name = 'Screener');
        insert uRole;
        User usr;
        try {
            usr = [SELECT Id, Email FROM User WHERE Email = :HireVueConstants.TEST_DATA_USER_EMAIL_ADDRESS_1];
        } catch(Exception ex) {
        	usr = new User(
                firstname = 'ABC', 
                lastName = 'XYZ', 
                email = HireVueConstants.TEST_DATA_USER_EMAIL_ADDRESS_1, 
                Username = HireVueConstants.TEST_DATA_USER_EMAIL_ADDRESS_1, 
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
            insert usr;     
        }
        Test.startTest();
        HireVueTestData.loadPreRequisiteDatas(HireVueConstants.TEST_DATA_USER_EMAIL_ADDRESS_1);
        Test.stopTest();        
    }
    
    @isTest static void success_InterviewFinished() {
        Map<String, String> mp_HireVueConfigs = HireVueTestData.getHireVueConfigs();
        Map<String, HttpCalloutMock> mp_fakeResponses = HireVueTestData.getMockReponsesForEventNotification(mp_HireVueConfigs);
        HttpCalloutMock multiCalloutMock = new HireVueMultiRequestMock(mp_fakeResponses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        RestRequest request = new RestRequest();
        request.requestUri = Url.getSalesforceBaseUrl()+'/services/apexrest/hirevuenotification/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"details": {"code": "Suwc96b-4xt5id", "type": "live-video", "interview_id": 43148575, "isOpenvue": false}, "eventType": "'+HireVueConstants.EVENT_TYPE_INTERVIEW_FINISHED+'"}');
        RestContext.request = request;
        
        Screening__c screen = [SELECT Id FROM Screening__c];
        screen.ScreenStatus__c = HireVueConstants.STATUS_SCREENED;
        screen.HireVue_Interview_Id__c = '43148575';
        screen.Hirevue_Position_Id__c = '2355255';
        Test.startTest();
        update screen;
        HireVueNotification.handlePost();
        Test.stopTest();
        screen = [SELECT Average_Rating__c, Decision__c, Evaluator_Comments__c FROM Screening__c];
       	System.assert(screen.Average_Rating__c != null, 'Average Rating should be populated');
        System.assert(screen.Decision__c != null, 'Decision should be populated');
        System.assert(screen.Decision__c != null, 'Evaluator_Comments__c should be populated');
    }
    
    @isTest static void success_EvaluationSubmitted() {
        Map<String, String> mp_HireVueConfigs = HireVueTestData.getHireVueConfigs();
        Map<String, HttpCalloutMock> mp_fakeResponses = HireVueTestData.getMockReponsesForEventNotification(mp_HireVueConfigs);
        HttpCalloutMock multiCalloutMock = new HireVueMultiRequestMock(mp_fakeResponses);
        Test.setMock(HttpCalloutMock.class, multiCalloutMock);
        RestRequest request = new RestRequest();
        request.requestUri = Url.getSalesforceBaseUrl()+'/services/apexrest/hirevuenotification/';
        request.httpMethod = 'POST';
        request.addHeader('Content-Type', 'application/json');
        request.requestBody = Blob.valueOf('{"details": {"code": "Suwc96b-4xt5id", "type": "live-video", "interview_id": 43148575, "isOpenvue": false}, "eventType": "'+HireVueConstants.EVENT_TYPE_RATING_SUBMITTED+'"}');
        RestContext.request = request;
        
        Screening__c screen = [SELECT Id FROM Screening__c];
        screen.ScreenStatus__c = HireVueConstants.STATUS_SCREENED;
        screen.HireVue_Interview_Id__c = '43148575';
        screen.Hirevue_Position_Id__c = '2355255';
        screen.Evaluation_Link__c = 'https://revature.stghv.com/evaluate/interview/43191476/';
        Test.startTest();
        update screen;
        HireVueNotification.handlePost();
        Test.stopTest();
        screen = [SELECT Average_Rating__c, Decision__c, Evaluator_Comments__c FROM Screening__c];
       	System.assert(screen.Average_Rating__c != null, 'Average Rating should be populated');
        System.assert(screen.Decision__c != null, 'Decision should be populated');
        System.assert(screen.Decision__c != null, 'Evaluator_Comments__c should be populated');
    }
    
}