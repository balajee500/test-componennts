@isTest
public class HireVueTestData {
    
    public static Map<String, HttpCalloutMock> getMockReponsesForUserTrigger(Map<String, String> mp_HireVueConfigs) {
        user usr = [SELECT Id, Email FROM User WHERE Username = :HireVueConstants.TEST_DATA_USER_EMAIL_ADDRESS_2];
        Map<String, HttpCalloutMock> mp_fakeResponses = new Map<String,HttpCalloutMock>();
        Map<String, String> mp_responsHeader = new Map<String, String>();
        String baseUrl = mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL);
        HireVueSingleRequestMock singleReqMock; 
        // fake mock - login
        mp_responsHeader.put(HireVueConstants.HDR_KEY_SET_COOKIE, HireVueConstants.TEST_DATA_COOKIE_VALUE);
        mp_responsHeader.put(HireVueConstants.HDR_KEY_CSRFTOKEN, HireVueConstants.TEST_DATA_CSRFTOKEN_VALUE);
        singleReqMock = new HireVueSingleRequestMock(200,'Complete', '', mp_responsHeader);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_LOGIN, singleReqMock);
        // fake mock - User not found for user fetch
        mp_responsHeader = new Map<String, String>();
        mp_responsHeader.put(HireVueConstants.HDR_KEY_API_ERROR, HireVueConstants.ERROR_USER_NOT_FOUND);
        singleReqMock = new HireVueSingleRequestMock(400,'Bad Request', '', mp_responsHeader);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_USER + usr.Email +'/', singleReqMock);
        // fake mock - User creation
        mp_responsHeader = new Map<String, String>();
        mp_responsHeader.put(HireVueConstants.HDR_KEY_HVAPI_ID, '117046');
        singleReqMock = new HireVueSingleRequestMock(200,'Complete', '', mp_responsHeader);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_USER, singleReqMock);
        // fake mock - position creation
        mp_responsHeader = new Map<String, String>();
        mp_responsHeader.put(HireVueConstants.HDR_KEY_HVAPI_ID, '2355255');
        singleReqMock = new HireVueSingleRequestMock(200,'Complete', '', mp_responsHeader);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_POSITION, singleReqMock);
        // fake mock - Session Fetch attached to position
        singleReqMock = new HireVueSingleRequestMock(200,'Complete', '[{"id":2626530}]', null);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_POSITION + '2355255/interview-template/sessions/', singleReqMock);
        // fake mock - Question template fetch
        String qtnTemplateResBody = '[{"id":53522,"questions":[{"maxDuration":180,"id":6299526,"type":"video","text":"What are your key strengths ?","prepTimeSeconds":30,"minDuration":10},{"maxDuration":180,"id":6299527,"type":"video","text":"What is the one thing, which you want to improve about yourself ?","prepTimeSeconds":30,"minDuration":10},{"maxDuration":180,"id":6299528,"type":"video","text":"Tell me something about yourself that is not written in your resume.","prepTimeSeconds":30,"minDuration":10}]}]';
        singleReqMock = new HireVueSingleRequestMock(200,'Complete', qtnTemplateResBody, null);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_QUESTION_TEMPLATE +'[name:in:'+mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_QTN_TEMPLATE)+']', singleReqMock);
        // fake mock - Session Update
        singleReqMock = new HireVueSingleRequestMock(204,'No Content', '', null);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_POSITION +'2355255/interview-template/sessions/2626530/', singleReqMock);
        // fake mock - position update
        singleReqMock = new HireVueSingleRequestMock(204,'No Content', '', null);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_POSITION +'2355255/', singleReqMock);
        return mp_fakeResponses;
    }
    
    public static Map<String, String> getHireVueConfigs() {
        Map<String, String> mp_HireVueConfigs = new Map<String, String>();
        for (HireVueConfiguration__mdt config : [SELECT DeveloperName, Value__c FROM HireVueConfiguration__mdt]) {
            mp_HireVueConfigs.put(config.DeveloperName, config.Value__c);
        }
        return mp_HireVueConfigs;
    }
    
    public static Map<String, HttpCalloutMock> getMockReponsesForScreeningTrigger(Map<String, String> mp_HireVueConfigs) {
        user usr = [SELECT Id, Email, Hirevue_Position_Id__c FROM User WHERE Username = 'abc@screeningtriggettestbytekclan.com'];
        Map<String, HttpCalloutMock> mp_fakeResponses = new Map<String,HttpCalloutMock>();
        Map<String, String> mp_responsHeader = new Map<String, String>();
        String baseUrl = mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL);
        HireVueSingleRequestMock singleReqMock; 
        // fake mock - login
        mp_responsHeader.put(HireVueConstants.HDR_KEY_SET_COOKIE, HireVueConstants.TEST_DATA_COOKIE_VALUE);
        mp_responsHeader.put(HireVueConstants.HDR_KEY_CSRFTOKEN, HireVueConstants.TEST_DATA_CSRFTOKEN_VALUE);
        singleReqMock = new HireVueSingleRequestMock(200,'Complete', '', mp_responsHeader);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_LOGIN, singleReqMock);
        // fake mock - User found for user fetch
        String usrResBody = '{"username":"abc@screeningtriggettestbytekclan.com","phone":"9952991642","language":"en","id":3607527,"firstName":"ABC","fullName":"ABC XYZ","lastName":"XYZ"}';
        singleReqMock = new HireVueSingleRequestMock(200, 'Complete', usrResBody, null);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_USER + usr.Email +'/', singleReqMock);
        // fake mock - candidate creation
        mp_responsHeader = new Map<String, String>();
        mp_responsHeader.put(HireVueConstants.HDR_KEY_HVAPI_ID, '43148575');
        singleReqMock = new HireVueSingleRequestMock(200,'Complete', '', mp_responsHeader);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_POSITION + usr.Hirevue_Position_Id__c + '/interviews/', singleReqMock);
        // fake mock - Candidate Fetch
        String candidateResBody = '{"id": 43148575, "code": "Sjx6j5f-cqi9zu", "myEvaluation": {"participantCode": "XtmaRwPU8aTwwyjhUwEXYD"}}';
        singleReqMock = new HireVueSingleRequestMock(200, 'Complete', candidateResBody, null);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_POSITION + usr.Hirevue_Position_Id__c + '/interviews/43148575/', singleReqMock);
        // fake mock - Binding Evaluators to a position
        mp_responsHeader = new Map<String, String>();
        mp_responsHeader.put(HireVueConstants.HDR_KEY_HVAPI_ID, 'abc.evaluator@usertriggettestbytekclan.com');
        singleReqMock = new HireVueSingleRequestMock(200,'Complete', '', mp_responsHeader);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_POSITION + usr.Hirevue_Position_Id__c + '/evaluators/', singleReqMock);
        return mp_fakeResponses;
    }
    
    public static Map<String, HttpCalloutMock> getMockReponsesForEventNotification(Map<String, String> mp_HireVueConfigs) {
        user usr = [SELECT Id, Email, Hirevue_Position_Id__c FROM User WHERE Username = :HireVueConstants.TEST_DATA_USER_EMAIL_ADDRESS_1];
        Map<String, HttpCalloutMock> mp_fakeResponses = new Map<String,HttpCalloutMock>();
        Map<String, String> mp_responsHeader = new Map<String, String>();
        String baseUrl = mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL);
        HireVueSingleRequestMock singleReqMock; 
        // fake mock - login
        mp_responsHeader.put(HireVueConstants.HDR_KEY_SET_COOKIE, HireVueConstants.TEST_DATA_COOKIE_VALUE);
        mp_responsHeader.put(HireVueConstants.HDR_KEY_CSRFTOKEN, HireVueConstants.TEST_DATA_CSRFTOKEN_VALUE);
        singleReqMock = new HireVueSingleRequestMock(200,'Complete', '', mp_responsHeader);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_LOGIN, singleReqMock);
        // fake mock - Candidate Fetch
        String candidateResBody = '{"id":43148575,"code":"Sjx6j5f-cqi9zu","myEvaluation":{"participantCode":"XtmaRwPU8aTwwyjhUwEXYD"},"video":{"downloadUrls":{"mp4":"https://video-cdn-2.stghv.com/hirevue/431195/positions/2333935/43148575/3035345/final/canonical.mp4?Expires=1589370850&Signature=AOo7kvXPlVCXdxY5q%7E4ufUiO-v5bNapDggMldf-%7ENrEmlhq%7E%7EeKoWCuahMcTIddWUwj0pQ4NDwBdv6x4%7ER8KSe5U%7ENMKetQmAVv0oOV56ARyqh94PosAawh3e8u2MxEeZDPXUkkohS1Xz47-Wf53l0k9HsmPAWSAIzWG2LyftpBRnwunnsSFlrIn%7EZj1IEFi9ebd6Z16Q-Y1G6z2vV8m7FpVg1hwYiFH69nQHZ8RwMBKe746mYNZKTwmsnbqO59h3wMQxXcs4q7CuED%7EKIPCsUBMIED5h0u655wrnaxSGoaUxMtmSCz35-Ed05kwVHlySto-Q%7E-7gljY-oSLrH1tcg__&Key-Pair-Id=APKAIFS7U652VEJVAARQ"}},"evaluations":[{"decision":"yes","averageRating":4,"evaluator":{"firstName":"ABC","username":"abc@hirevuenotificationtestbytekclan.com","lastName":"XYZ","fullName":"ABC XYZ"}}]}';
        singleReqMock = new HireVueSingleRequestMock(200, 'Complete', candidateResBody, null);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_POSITION + usr.Hirevue_Position_Id__c + '/interviews/43148575/', singleReqMock);
        // fake mock - Session fetch
        String sessionResBody = '[{"id": 3456789}]';
        singleReqMock = new HireVueSingleRequestMock(200, 'Complete', sessionResBody, null);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_POSITION + usr.Hirevue_Position_Id__c + '/interviews/43148575/sessions/', singleReqMock);
        // fake mock - comments fetch
        singleReqMock = new HireVueSingleRequestMock(200, 'Complete', sessionResBody, null);
        mp_fakeResponses.put(baseUrl + HireVueConstants.API_POSITION + usr.Hirevue_Position_Id__c + '/interviews/43148575/sessions/3456789/comments/?qo=-createDate', singleReqMock);
        return mp_fakeResponses;
    }
    
    @future
    public static void loadPreRequisiteDatas(String sfusername) {
       	user usr = [SELECT Id, Email FROM User WHERE Username = :sfusername];
        RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='ScreeningSlot__c' And Name = 'Tech Screen'];
        ScreeningSlot__c slot = new ScreeningSlot__c();
        slot.RecordTypeId = rt.Id;
        slot.ProgramType__c = 'Regular';
        slot.Screener__c = usr.Id;
        slot.StartTime__c = Datetime.now().addDays(1);
        insert slot;
        Contact con = new Contact();
        con.LastName = 'Contact';
        con.FirstName = 'Test';
        con.Email = 'test@test.com';
        con.Phone = '1234567891';
        con.WorkAuthorization__c = 'U.S. Citizen';
        con.Gender__c = 'Male';
        insert con; 
        RecordType screeningRecordType = [SELECT Id,Name FROM RecordType WHERE SobjectType='Screening__c' And Name = 'Technical'];
        Screening__c screen = new Screening__c();
        screen.Candidate__c = con.Id;
        screen.Screener__c = usr.Id;
        screen.ScreenType__c = 'Video';
        screen.RecordTypeId = screeningRecordType.Id;
        screen.ScreenDate__c = Datetime.now().addDays(1);
        insert screen;
    }
    
}