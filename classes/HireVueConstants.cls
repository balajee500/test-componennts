/*********************************************************************************************************************************************
 *  Class       :   HireVueConstants
 *  Author      :   Tekclan Software Solutions PVT. LTD.
 *  Created By  :   Balaji Jayaraman
 *  Purpose     :   This is an Contants class that holds static values
 *
 ********************************************************************************************************************************************/
public class HireVueConstants {
    public static final String DELIMITER_SEMICOLON = ';';
    public static final String DELIMITER_EQUAL = '=';  
	//Hirevue end points
    public static final String API_LOGIN = '/api/v1/login/';
	public static final String API_POSITION = '/api/v1/positions/'; 
    public static final String API_USER = '/api/v1/users/';
    public static final String API_ACCOUNTS = '/api/v1/accounts/';
    public static final String API_QUESTION_TEMPLATE = '/api/v1/question-templates/?qr=1&qf=[account.id:self.accountId]';
    //Api Paths
    public static final String PATH_INTERVIEWS = '/interviews/';
    public static final String PATH_SESSIONS = '/sessions/';
    //Hirvue Config Key
	public static final String HIREVUE_CONFIG_KEY_USERNAME = 'UserName';
    public static final String HIREVUE_CONFIG_KEY_API_CODE = 'Password';
    public static final String HIREVUE_CONFIG_KEY_APPLICATION_TOKEN = 'ApplicationToken';
	public static final String HIREVUE_CONFIG_KEY_VERSION = 'version';
    public static final String HIREVUE_CONFIG_KEY_POSITION_TEAM_ID = 'TeamId';
    public static final String HIREVUE_CONFIG_KEY_ACCOUNT_ID = 'AccountId';
    public static final String HIREVUE_CONFIG_KEY_BASE_URL = 'HireVueBaseUrl';
    public static final String HIREVUE_CONFIG_KEY_QTN_TEMPLATE = 'QuestionTemplate';
    public static final String HIREVUE_CONFIG_KEY_INTERVIEW_DURATION = 'InterviewDuration';
    //Notification Event Types
    public static final String EVENT_TYPE_POSITION_ARCHIVED = 'positionArchived';
    public static final String EVENT_TYPE_POSITION_UNARCHIVED = 'positionUnarchived';
    public static final String EVENT_TYPE_POSITION_CREATED = 'positionCreated';
    public static final String EVENT_TYPE_INTERVIEW_CREATED = 'interviewCreated';
    public static final String EVENT_TYPE_INTERVIEW_STARTED = 'interviewStarted';
    public static final String EVENT_TYPE_INTERVIEW_FINISHED = 'interviewFinished';
    public static final String EVENT_TYPE_RATING_SUBMITTED = 'ratingSubmitted';
    public static final String EVENT_TYPE_DECISION_SUBMITTED = 'decisionSubmitted';
    //Error
    public static final String ERROR_USER_NOT_FOUND = 'UserNotFoundError'; 
    public static final String ERROR_DUPLICATE_EVALUATOR = 'DuplicateEvaluator';
    //Req & Response Header
    public static final String HDR_KEY_API_ERROR = 'X-HvApi-Error';
    public static final String HDR_KEY_SEND_CANDIDATE_CANCELLATION_EMAIL = 'x-send-candidate-cancellation-email';
    public static final String HDR_KEY_SEND_INTERVIEWER_CANCELLATION_EMAIL = 'x-send-interviewers-cancellation-email';
    public static final String HDR_KEY_SUPPRESS_CANDIDATE_EMAIL = 'x-suppress-candidate-email';
    public static final String HDR_KEY_SET_COOKIE = 'Set-Cookie';
    public static final String HDR_KEY_CSRFTOKEN = 'csrftoken';
    public static final String HDR_KEY_HVAPI_ID = 'x-hvapi-id';
    //Roles
    public static final String USR_ROLE_SCREENER = 'Screener';
    //Status
    public static final String STATUS_SCREENED = 'Scheduled';
    public static final String STATUS_CANCELLED = 'Cancelled';
    public static final String STATUS_COMPLETED = 'Completed';
    public static final String STATUS_RESCHEDULED = 'Rescheduled';	
    public static final String STATUS_INTERVIEW_STARTED = 'Interview Started';
    public static final String STATUS_INTERVIEW_FINISHED = 'Interview Finished';
    //Type
    public static final String TYPE_VIDEO = 'video';
    //Interview Type
    public static final String INTERVIEW_TYPE_LIVE_RECORDED = 'live-recorded';
    //Scoring Mode
    public static final String RATING_MODE_PER_QTN = 'per-question';
    public static final String RATING_MODE_PER_Interview = 'per-interview';
    //decision
    public static final Map<String, String> DECISION_VALUES_MAPPING = new Map<String, String> {'yes'=>'Yes', 'no'=>'No', 'maybe'=>'Maybe'};
    //classes
    public static final String CLASS_HIREVUENOTIFICATION = 'HireVueNotification.cls';
    public static final String CLASS_SCREENINGHELPER = 'ScreeningHelper.cls';
    //methods
    public static final String METHOD_UPDATE_AVERAGE_RATING = 'updateAverageRatingOnSFScreeningRecord';
    //Messages
    public static final String MSG_EVALUATION_EXTRACTION = 'HireVue Evaluation Extraction for screening';
    public static final String MSG_CANDIDATE_CREATION = 'HireVue Candidate creation for Screening';
    public static final String MSG_CANDIDATE_CHANGE = 'HireVue Screener Change for Screening';
    public static final String MSG_CANDIDATE_DELETION = 'HireVue Candidate Deletion for Screening';
    public static final String MSG_EVALUATION_ASSIGNMENT_FAILED = 'Evaluator assigning failed for a candidate record';
    //Test class constants
    public static final String TEST_DATA_USER_EMAIL_ADDRESS_1 = 'abc@hirevuenotificationtestbytekclan.com';
    public static final String TEST_DATA_USER_EMAIL_ADDRESS_2 = 'abc@usertriggettestbytekclan.com';
    public static final String TEST_DATA_COOKIE_VALUE = 'ajs_group_id=null; _ga=GA1.2.1685704596.1588138661; _gid=GA1.2.1399613300.1588579095; cookie_policy={"date":1588118052000,"analytic":true,"customization":true}; ajs_user_id=%22bb5780e52a634a23b68e3feffde997f5%22; ajs_anonymous_id=%229e8f8920-128d-489d-b157-24db4c027b47%22; csrftoken=hsE9ugmTpIaqJw252Gd4hOK06U34IkCsPtq8q0hM29IoD9kinVYm0GzWHGLiLcil; sessionid=0pdat9uz0drs5ys4dgg573mgpj3058hl';
    public static final String TEST_DATA_CSRFTOKEN_VALUE = 'hsE9ugmTpIaqJw252Gd4hOK06U34IkCsPtq8q0hM29IoD9kinVYm0GzWHGLiLcil';
}