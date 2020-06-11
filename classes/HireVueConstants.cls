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
	//Hirvue Config Key
	public static final String HIREVUE_CONFIG_KEY_USERNAME = 'UserName';
    public static final String HIREVUE_CONFIG_KEY_PASSWORD = 'Password';
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
    //Response Header
    public static final String HDR_KEY_API_ERROR = 'X-HvApi-Error';
    //Request Header
    public static final String HDR_KEY_SEND_CANDIDATE_CANCELLATION_EMAIL = 'x-send-candidate-cancellation-email';
    public static final String HDR_KEY_SEND_INTERVIEWER_CANCELLATION_EMAIL = 'x-send-interviewers-cancellation-email';
    public static final String HDR_KEY_SUPPRESS_CANDIDATE_EMAIL = 'x-suppress-candidate-email';
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
}