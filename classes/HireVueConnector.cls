public class HireVueConnector {
    
	public Map<String, String> mp_Credentials {
        get {
            if (mp_Credentials == null) {
            	mp_Credentials = new Map<String, String>(); 
                HireVueAPI.LoginResult loginRslt = getLoginCrendentials(null);
                if(loginRslt.isSuccess) {
					mp_Credentials = loginRslt.mp_Credentials;
                }
            }
            return mp_Credentials;
        } set;
    }
    
    public Map<String, String> mp_HireVueConfigs {
		get {
            if (mp_HireVueConfigs == null) {
            	mp_HireVueConfigs = new Map<String, String>(); 
                for (HireVueConfiguration__mdt config : [SELECT DeveloperName, Value__c FROM HireVueConfiguration__mdt]) {
                    mp_HireVueConfigs.put(config.DeveloperName, config.Value__c);
                }
            }
            return mp_HireVueConfigs;
        } set;	
    }
    /**
     * @description Constructs a request with details supplied and returns the response with JSON acceptable data from HireVue
     *
     * @param end point url
     * @param http request method
     * @param header parameters
     * @param http request body
     * @return http response with JSON data
     */
    public HttpResponse invokeApi(String endpoint, String reqMethod, Map<String, String> mp_Headers, String jsonBody) {
        HttpRequest request = new HttpRequest();
        Http connection = new Http();
        request.setMethod(reqMethod);
        request.setEndpoint(endpoint);
        request.setHeader('Content-Type', 'application/json');
        request.setHeader('Accept', 'application/json');
        if (mp_Headers != null) {
            for (String key : mp_Headers.keySet()) {
                request.setHeader(key, mp_Headers.get(key));
            }
        }
        if (String.isNotBlank(jsonBody)) {
            request.setBody(jsonBody);
        }
        return connection.send(request);
    }
    /**
     * @description send login request to hirevue and returns the credentials in response headers
     *
	 * @param user email address
     * @return credentials with key-value pairs
     */
    public HireVueAPI.LoginResult getLoginCrendentials(String userName) {
        HireVueAPI.LoginResult loginRslt = new HireVueAPI.LoginResult();
        loginRslt.isSuccess = true;
        loginRslt.mp_Credentials = new Map<String, String>();
        JSONGenerator gen = JSON.createGenerator(false);
        gen.writeStartObject();
        if (String.isNotBlank(userName)) {
            gen.writeStringField('impersonate', userName);    
        } else {
            gen.writeStringField('impersonate', mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_USERNAME));
        }
        gen.writeStringField('apiKey', mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_PASSWORD));
        gen.writeStringField('applicationToken', mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_APPLICATION_TOKEN));
        gen.writeStringField('version', mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_VERSION));
        gen.writeEndObject();
        String jsonBody = gen.getAsString();
        HttpResponse res = invokeApi(
            mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL) + HireVueConstants.API_LOGIN, 
            'POST', 
            null, 
            jsonBody
        );
        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            loginRslt.mp_Credentials.put('X-CSRFToken', res.getHeader('csrftoken'));
            String cookieString = res.getHeader('Set-Cookie');
            if (String.isNotBlank(cookieString)) {
                List<String> lst_Cookies = cookieString.split(HireVueConstants.DELIMITER_SEMICOLON);
                String cookieVal = '';
                for (String item : lst_Cookies) {
                    if (item.contains('csrftoken')) {
                        cookieVal += item + HireVueConstants.DELIMITER_SEMICOLON;
                    }
                    if (item.contains('sessionid')) {
                        cookieVal += item + HireVueConstants.DELIMITER_SEMICOLON;
                    }
                }
                loginRslt.mp_Credentials.put('cookie', cookieVal);
            }
        } else {
            loginRslt.errorCode = res.getHeader(HireVueConstants.HDR_KEY_API_ERROR);
            loginRslt.isSuccess = false;
            loginRslt.errorMessage = res.getBody();
        }
        return loginRslt;
    }
    /**
     * @description creates User record in hirevue by invoking a positon Api
     *
 	 * @param user object
     * @return SaveResult Object
     */
    public HireVueAPI.SaveResult createUser(HireVueObjects.User user) {
        HireVueAPI.SaveResult rslt = new HireVueAPI.SaveResult();
        rslt.isSuccess = true;
        HttpResponse res = invokeApi(
            mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL) + HireVueConstants.API_USER, 
            'POST', 
            mp_Credentials, 
            JSON.serialize(user, true)
        );
        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            rslt.recordId = getHireVueObjectId(res);
        } else {
            rslt = setHireVueSaveError(rslt, res);
        }    
        return rslt;
    }
    /**
     * @description upsert User record in hirevue by invoking a positon Api
     *
 	 * @param user object
 	 * @param user Email
     * @return SaveResult Object
     */
    public HireVueAPI.SaveResult updateUser(HireVueObjects.User user, String userEmail) {
        HireVueAPI.SaveResult rslt = new HireVueAPI.SaveResult();
        rslt.isSuccess = true;
        HttpResponse res = invokeApi(
            mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL) + HireVueConstants.API_USER + userEmail + '/', 
            'PUT', 
            mp_Credentials, 
            JSON.serialize(user, true)
        );
        if (res.getStatusCode() == 204 || res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            rslt.recordId = getHireVueObjectId(res);
        } else {
            rslt = setHireVueSaveError(rslt, res);
        }    
        return rslt;
    }
    /**
     * @description fetches User Record from HirVue
     *
     * @param userName
     * @return QueryResult Object
     */
    public HireVueApi.QueryResult getUser(String userName) {
        HireVueApi.QueryResult qryRslt = new HireVueApi.QueryResult();
        qryRslt.isSuccess = true;
        HttpResponse res = invokeApi(
            mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL) + HireVueConstants.API_USER + userName +'/', 
            'GET', 
            mp_Credentials, 
            null
        );
        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            qryRslt.data = JSON.deserialize(res.getBody(), HireVueObjects.User.class);
        } else {
            qryRslt = setHireVueQueryError(qryRslt, res);
        }
        return qryRslt;
    }
    /**
     * @description fetches positions available for a user
     *
     * @param user email address
     * @return QueryResult Object
     */
    public HireVueApi.QueryResult getPositionsAvailableForUser(String userEmail) {
        HireVueApi.QueryResult qryRslt = new HireVueApi.QueryResult();
        qryRslt.isSuccess = true;
        HttpResponse res = invokeApi(
            mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL) + HireVueConstants.API_POSITION +'?qf=[creator.username:exact:'+ userEmail +'][!isArchived][!isDraft]&qo=-createDate', 
            'GET', 
            mp_Credentials, 
            null
        );
        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            qryRslt.data = JSON.deserialize(res.getBody(), List<HireVueObjects.Position>.class);
        } else {
            qryRslt = setHireVueQueryError(qryRslt, res);
        }
        return qryRslt;
    }
    /**
     * @description fetches sessions attached to interviews which is used to get the comments given by evaluators.
     *
     * @param position Id
     * @param Interview Id
     * @return QueryResult Object
     */
    public HireVueApi.QueryResult getSessionForFetchingComments(String positionId, String interviewId) {
        HireVueApi.QueryResult qryRslt = new HireVueApi.QueryResult();
        qryRslt.isSuccess = true;
        HttpResponse res = invokeApi(
            mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL) + HireVueConstants.API_POSITION +positionId+ '/interviews/' +interviewId+ '/sessions/' , 
            'GET', 
            mp_Credentials, 
            null
        );
        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            qryRslt.data = JSON.deserialize(res.getBody(), List<HireVueObjects.Session>.class);
        } else {
            qryRslt = setHireVueQueryError(qryRslt, res);
        }
        return qryRslt;
    }
    
    
    /**
     * @description get comments given by evaluators
     *
     * @param position Id
     * @param interview Id
     * @return QueryResult Object
     */
    public HireVueApi.QueryResult getCommentsGivenByEvaluator(String positionId, String interviewId) {
        HireVueApi.QueryResult qryRslt = new HireVueApi.QueryResult();
        qryRslt.isSuccess = true;
        HireVueApi.QueryResult sessionFetchRslt = getSessionForFetchingComments(positionId, interviewId);
        if (!sessionFetchRslt.isSuccess) {
           qryRslt.errorCode = sessionFetchRslt.errorCode;
           qryRslt.isSuccess = false;
           qryRslt.errorMessage = sessionFetchRslt.errorMessage;
           return qryRslt;
        }
        List<HireVueObjects.Session> lst_Session =  (List<HireVueObjects.Session>)sessionFetchRslt.data;
        if (lst_Session == null || lst_Session.isEmpty()) {
            qryRslt.data = new List<HireVueObjects.Comment>();
            return qryRslt;
        }
        HttpResponse res = invokeApi(
            mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL) + HireVueConstants.API_POSITION +positionId+ '/interviews/' +interviewId+ '/sessions/'+lst_Session[lst_Session.size() - 1].id+'/comments/?qo=-createDate' , 
            'GET', 
            mp_Credentials, 
            null
        );
        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            qryRslt.data = JSON.deserialize(res.getBody(), List<HireVueObjects.Comment>.class);
        } else {
            qryRslt = setHireVueQueryError(qryRslt, res);
        }
        return qryRslt;
    }
    /**
     * @description creates position record in hirevue by invoking a positon Api
     *
	 * @param user email address
     * @return SaveResult Object
     */
    public HireVueAPI.SaveResult createPosition(String userEmail) {
        HireVueAPI.SaveResult rslt = new HireVueAPI.SaveResult();
        try {
            rslt.isSuccess = true;
            //construct postion
            HireVueObjects.Position position = new HireVueObjects.Position();
            HireVueObjects.User usr;
            HireVueApi.QueryResult usrQryRslt = getUser(userEmail);
            if (usrQryRslt.isSuccess) {
                usr = (HireVueObjects.User)usrQryRslt.data;
                if (String.isNotBlank(usr.phone)) {
                    position.pocName = usr.fullName;
                    position.pocEmail = usr.username;
                    position.pocPhone = usr.phone;
                    position.pocUrl = 'https://revature.com/';
                    position.disablePoc = false;    
                }
            }
            position.isDraft = true;
            position.isOpenvue = true;
            position.interviewType = HireVueConstants.INTERVIEW_TYPE_LIVE_RECORDED;
            //position.interviewType = 'on-demand';
            // 'event' or 'live-non-recorded' or 'live-recorded' or 'on-demand' or 'on-site-recorded' or 'phone'
            position.ratingMode = HireVueConstants.RATING_MODE_PER_Interview;
            //per-interview, per-question
            position.visibility = 'private';
            position.teamId = Long.valueOf(mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_POSITION_TEAM_ID));
            String positionName = 'My position';
            if (usr != null && String.isNotBlank(usr.fullName)) {
                positionName = usr.fullName+'- position';
            }
            position.title = positionName;
            position.publicTitle = positionName;
            HttpResponse res = invokeApi(
                mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL) + HireVueConstants.API_POSITION, 
                'POST', 
                mp_Credentials, 
                JSON.serialize(position, true)
            );
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                rslt.recordId = getHireVueObjectId(res);
            } else {
                rslt = setHireVueSaveError(rslt, res);
            }
        } catch(Exception ex) {
           rslt.isSuccess = false;
           rslt.errorMessage = 'Create Position Failed : '+ex.getMessage();
           return rslt; 
        }
        return rslt;
    }
    /**
     * @description update position record in hirevue by invoking a positon Api
     *
     * @param Position id
     * @param Position object
     * @return SaveResult Object
     */
    public HireVueAPI.SaveResult updatePosition(String positionId, HireVueObjects.Position position) {
        HireVueAPI.SaveResult rslt = new HireVueAPI.SaveResult();
        rslt.isSuccess = true;
        HttpResponse res = invokeApi(mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL) + HireVueConstants.API_POSITION + positionId +'/', 'PUT', mp_Credentials, JSON.serialize(position, true));
        if (res.getStatusCode() == 200 || res.getStatusCode() == 201 || res.getStatusCode() == 204) {
            rslt.recordId = getHireVueObjectId(res);
        } else {
            rslt = setHireVueSaveError(rslt, res);
        }
        return rslt;
    }
    /**
     * @description update candidate record in hirevue by invoking a candidate Api
     *
     * @param Position id
     * @param Position object
     * @return SaveResult Object
     */
    public HireVueAPI.SaveResult updateCandidate(String positionId, String interviewId, HireVueObjects.Candidate interview) {
        HireVueAPI.SaveResult rslt = new HireVueAPI.SaveResult();
        rslt.isSuccess = true;
        Map<String, String> mp_Headers = mp_Credentials;
        if (interview != null && interview.isArchived == true) {
            mp_Headers.put(HireVueConstants.HDR_KEY_SEND_CANDIDATE_CANCELLATION_EMAIL, 'true');
            mp_Headers.put(HireVueConstants.HDR_KEY_SEND_INTERVIEWER_CANCELLATION_EMAIL, 'true');
            mp_Headers.put(HireVueConstants.HDR_KEY_SUPPRESS_CANDIDATE_EMAIL, 'true');
        }
        HttpResponse res = invokeApi(mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL) + HireVueConstants.API_POSITION + positionId +'/interviews/'+interviewId+'/', 'PUT', mp_Headers, JSON.serialize(interview, true));
        if (res.getStatusCode() == 200 || res.getStatusCode() == 201 || res.getStatusCode() == 204) {
            rslt.recordId = getHireVueObjectId(res);
        } else {
            rslt = setHireVueSaveError(rslt, res);
        }
        return rslt;
    }
    /**
     * @description Setup notifcation service by acception url that you want to receive notification from hirevue
     *
     * @param url
     * @return SaveResult Object
     */
    public HireVueAPI.SaveResult enableNotification(String url) {
        HireVueAPI.SaveResult rslt = new HireVueAPI.SaveResult();
        rslt.isSuccess = true;
        HireVueObjects.Notification notification = new HireVueObjects.Notification();
        notification.url = url;
        HttpResponse res = invokeApi(mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL) + HireVueConstants.API_ACCOUNTS + mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_ACCOUNT_ID) +'/notifications/', 'POST', mp_Credentials, JSON.serialize(notification, true));
        if (res.getStatusCode() == 200 || res.getStatusCode() == 201 || res.getStatusCode() == 204) {
            rslt.recordId = getHireVueObjectId(res);
        } else {
            rslt = setHireVueSaveError(rslt, res);
        }
        return rslt;
    }
    /**
     * @description fetches Sections Records Available under position
     *
     * @param Position id
     * @return QueryResult Object
     */
    public HireVueApi.QueryResult getSectionsAttachedToPostion(String positionId) {
        HireVueApi.QueryResult qryRslt = new HireVueApi.QueryResult();
        qryRslt.isSuccess = true;
        HttpResponse res = invokeApi(mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL) + HireVueConstants.API_POSITION + positionid + '/sections/', 'GET', mp_Credentials, null);
        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            qryRslt.data = JSON.deserialize(res.getBody(), List<HireVueObjects.Section>.class);
        } else {
            qryRslt = setHireVueQueryError(qryRslt, res);
        }
        return qryRslt;
    }
    /**
     * @description fetches Session Records Available under position
     *
     * @param Position id
     * @return QueryResult Object
     */
    public HireVueApi.QueryResult getSessionAttachedToPostion(String positionId) {
        HireVueApi.QueryResult qryRslt = new HireVueApi.QueryResult();
        qryRslt.isSuccess = true;
        HttpResponse res = invokeApi(mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL) + HireVueConstants.API_POSITION + positionId + '/interview-template/sessions/', 'GET', mp_Credentials, null);
        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            qryRslt.data = JSON.deserialize(res.getBody(), List<HireVueObjects.Session>.class);
        } else {
            qryRslt = setHireVueQueryError(qryRslt, res);
        }
        return qryRslt;
    }
    /**
     * @description fetches Candidate Records Available under position
     *
     * @param Position id
     * @param inteview id
     * @return QueryResult Object
     */
    public HireVueApi.QueryResult getCandidateAttachedToPostion(String positionId, String interviewId) {
        HireVueApi.QueryResult qryRslt = new HireVueApi.QueryResult();
        qryRslt.isSuccess = true;
        HttpResponse res = invokeApi(mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL) + HireVueConstants.API_POSITION + positionId + '/interviews/' +interviewId+'/', 'GET', mp_Credentials, null);
        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            qryRslt.data = JSON.deserialize(res.getBody(), HireVueObjects.Candidate.class);
        } else {
            qryRslt = setHireVueQueryError(qryRslt, res);
        }
        return qryRslt;
    }
    /**
     * @description fetches Question Template available in Revature Account
     *
     * @return QueryResult Object
     */
    public HireVueApi.QueryResult getQuestionTemplate() {
        HireVueApi.QueryResult qryRslt = new HireVueApi.QueryResult();
        qryRslt.isSuccess = true;
        HttpResponse res = invokeApi(
            mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL) + HireVueConstants.API_QUESTION_TEMPLATE +'[name:in:'+mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_QTN_TEMPLATE)+']', 
            'GET', 
            mp_Credentials, 
            null
        );
        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            qryRslt.data = JSON.deserialize(res.getBody(), List<HireVueObjects.QuestionTemplate>.class);
        } else {
            qryRslt = setHireVueQueryError(qryRslt, res);
        }
        return qryRslt;
    }
    /**
     * @description create section along with form on to a postion
     *
     * @param Position id
     * @return SaveResult Object
     */
    public HireVueAPI.SaveResult createSectionWithForm(String positionid) {
        HireVueAPI.SaveResult rslt = new HireVueAPI.SaveResult();
        rslt.isSuccess = true;
        HireVueAPI.QueryResult qryRslt = getQuestionTemplate();
        if (!qryRslt.isSuccess) {
            rslt.isSuccess = false;
            rslt.errorMessage = 'Question Template Fetch Error : ' +qryRslt.errorMessage;
            return rslt;
        }
        HireVueObjects.Section section = new HireVueObjects.Section();
        section.name = 'Section 1';
        section.forms = new List<HireVueObjects.Form>();
        HireVueObjects.Form form = new HireVueObjects.Form();
        form.name = 'Form A';
        HireVueObjects.QuestionTemplate qtnTemplate = ((List<HireVueObjects.QuestionTemplate>)qryRslt.data)[0];
        form.questions = qtnTemplate.questions;
        section.forms.add(form);
        section.forceQuestionResponse = true;
        section.restrictNavigation = true;
        HttpResponse res = invokeApi(
            mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL) + HireVueConstants.API_POSITION + positionId + '/sections/', 
            'POST', 
            mp_Credentials, 
            JSON.serialize(section, true)
        );
        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            rslt.recordId = getHireVueObjectId(res);
        } else {
            rslt = setHireVueSaveError(rslt, res);
        }
        return rslt;
    }
    /**
     * @description add Evaluators to a postion
     *
     * @param Position id
     * @param user email address
     * @return SaveResult Object
     */
    public HireVueAPI.SaveResult bindEvaluatorsToPostion(String positionId, String userEmail) {
        HireVueAPI.SaveResult rslt = new HireVueAPI.SaveResult();
        rslt.isSuccess = true;
        HireVueApi.QueryResult usrQryRslt = getUser(userEmail);
        if (!usrQryRslt.isSuccess) {
            rslt.errorCode = usrQryRslt.errorCode;
            rslt.isSuccess = usrQryRslt.isSuccess;
            rslt.errorMessage = usrQryRslt.errorMessage;
            return rslt;
        }
        HireVueObjects.User usr = (HireVueObjects.User)usrQryRslt.data;
        HireVueObjects.InterViewer interviewer = new HireVueObjects.InterViewer();
        interviewer.username = usr.username;
        interviewer.firstName = usr.firstName;
        interviewer.lastName = usr.lastName;
        interviewer.isAutoAssign = false;
        HttpResponse res = invokeApi(
            mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL) +'/api/v1/positions/' + positionid + '/evaluators/', 
            'POST', 
            mp_Credentials, 
            JSON.serialize(interviewer, true)
        );
        if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
            rslt.recordId = getHireVueObjectId(res);
        } else {
            rslt = setHireVueSaveError(rslt, res);
        }
        return rslt;
    }
    /**
     * @description assign Evaluators to a interview
     *
     * @param Position id
     * @param Interview Id
     * @param user email address
     * @return SaveResult Object
     */
    public HireVueAPI.SaveResult assignEvaluatorToInterview(String positionId, String interviewId, String userEmail) {
        HireVueAPI.SaveResult rslt = new HireVueAPI.SaveResult();
        rslt.isSuccess = true;
		HireVueObjects.Assignment assign = new HireVueObjects.Assignment();
        assign.isAutoAssign = false;
        assign.assignments = new List<HireVueObjects.AssignmentDetail>();
        HireVueObjects.AssignmentDetail assignDetail = new HireVueObjects.AssignmentDetail();
        assignDetail.isAssigned = true;
        assignDetail.interviewId = Long.valueOf(interviewId);
        assign.assignments.add(assignDetail);
        HttpResponse res = invokeApi(
            mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL) +'/api/v1/positions/' + positionid + '/evaluators/'+userEmail+'/assignments/', 
            'PUT', 
            mp_Credentials, 
            JSON.serialize(assign, true)
        );
        if (res.getStatusCode() == 200 || res.getStatusCode() == 201 || res.getStatusCode() == 204) {
            rslt.recordId = getHireVueObjectId(res);
        } else {
            rslt = setHireVueSaveError(rslt, res);
        }
        return rslt;
    }
    /**
     * @description Fethches interview Session record by acception a position id and update it with Questions, Location and participants
     * 
     * @param position record id
     * @param user email address
     * @return SaveResult object
     */
    public HireVueAPI.SaveResult getAndUpdateSessionOnPostion(String positionid, String userEmail) {
        HireVueAPI.SaveResult rslt = new HireVueAPI.SaveResult();
        try {
            rslt.isSuccess = true;
            // Session
            HireVueApi.QueryResult qryRslt = getSessionAttachedToPostion(positionid);
            if (!qryRslt.isSuccess) {
                rslt.errorCode = qryRslt.errorCode;
                rslt.isSuccess = false;
                rslt.errorMessage = qryRslt.errorMessage;
                return rslt;
            }
            HireVueObjects.Session sessionFromPosition = ((List<HireVueObjects.Session>)qryRslt.data)[0];
            HireVueObjects.Session session = new HireVueObjects.Session(); 
            session.name = 'Session 1';
            session.notes = ' ';
            session.durations = new List<Long> {Long.valueOf(mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_INTERVIEW_DURATION))};
            qryRslt = getQuestionTemplate();
            if (!qryRslt.isSuccess) {
                rslt.errorCode = qryRslt.errorCode;
                rslt.isSuccess = false;
                rslt.errorMessage = qryRslt.errorMessage;
                return rslt;
            }
            HireVueObjects.QuestionTemplate qtnTemplate = ((List<HireVueObjects.QuestionTemplate>)qryRslt.data)[0];
            session.questions = qtnTemplate.questions;
            HttpResponse res = invokeApi(
                mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL) + HireVueConstants.API_POSITION + positionid + '/interview-template/sessions/' + sessionFromPosition.id + '/', 
                'PUT', 
                mp_Credentials, 
                JSON.serialize(session, true)
            );
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201 || res.getStatusCode() == 204) {
                rslt.recordId = getHireVueObjectId(res);
            } else {
                rslt = setHireVueSaveError(rslt, res);
            }   
        } catch(Exception ex) {
            rslt.isSuccess = false;
            rslt.errorMessage = ex.getMessage() +'\n'+ ex.getStackTraceString();
        }
        return rslt;
    }
    /**
     * @description creates interview/candidate record in hirevue by accepting the position id
     * 
     * @param position record id
     * @param interviewer email address
     * @param candidate object
     * @return SaveResult object
     */
    public HireVueAPI.SaveResult createAndAssignCandidateToPostion(String positionid, String interviewerEmail, HireVueObjects.Candidate candidate) {
        HireVueAPI.SaveResult rslt = new HireVueAPI.SaveResult();
        try {
            rslt.isSuccess = true;
            candidate.participants = new List<HireVueObjects.InterViewer>();
            HireVueApi.QueryResult usrQryRslt = getUser(interviewerEmail);
            if (usrQryRslt.isSuccess) {
                HireVueObjects.User usrInfo = (HireVueObjects.User)usrQryRslt.data;
                HireVueObjects.InterViewer interviewer = new HireVueObjects.InterViewer();
                interviewer.username = usrInfo.username;
                interviewer.firstName = usrInfo.firstName;
                interviewer.lastName = usrInfo.lastName;
                candidate.participants.add(interviewer);
            }
            HttpResponse res = invokeApi(
                mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL) + HireVueConstants.API_POSITION + positionid + '/interviews/', 
                'POST', 
                mp_Credentials, 
                JSON.serialize(candidate, true)
            );
            if (res.getStatusCode() == 200 || res.getStatusCode() == 201) {
                rslt.recordId = getHireVueObjectId(res);
            } else {
                rslt = setHireVueSaveError(rslt, res);
            }     
        } catch(Exception ex) {
            rslt.isSuccess = false;
            rslt.errorMessage = ex.getMessage() +'\n'+ ex.getStackTraceString();
        }
        return rslt;
    }
    /**
     * @description Returns Object Id from the HTTP Response Header parameters
     * 
     * @param HttpResponse Object
     * @return HireVue Object Id
     */
    public static String getHireVueObjectId(HttpResponse res) {
        String objectId = res.getHeader('x-hvapi-id');
        if (String.isBlank(objectId)) {
            objectId = res.getHeader('X-HvApi-Id');
        }
        String location = res.getHeader('location');
        if (String.isBlank(objectId) && String.isNotBlank(location)) {
            location = location.substringBeforeLast('/');
            objectId = location.substringAfterLast('/');
        }
        return objectId;
    }
    public HireVueApI.SaveResult setHireVueSaveError(HireVueApI.SaveResult rslt, HttpResponse res) {
        rslt.errorCode = res.getHeader(HireVueConstants.HDR_KEY_API_ERROR);
        rslt.isSuccess = false;
        rslt.errorMessage = res.getBody();
        return rslt;
    }
    public HireVueApI.QueryResult setHireVueQueryError(HireVueApI.QueryResult rslt, HttpResponse res) {
        rslt.errorCode = res.getHeader(HireVueConstants.HDR_KEY_API_ERROR);
        rslt.isSuccess = false;
        rslt.errorMessage = res.getBody();
        return rslt;
    }
    /**
     * @description Creates error log record
     * 
     * @param operation
     * @param line number
     * @param message
     * @param stack trace string
     * @param type name
     * @return void
     */
    public void createErrorLog(String operation, Decimal lineNumber, String message, String stackTraceString, String className, String methodName) {
        ErrorLog__c errLog = new ErrorLog__c();
        errLog.Operation__c = operation;
        errLog.LineNumber__c = lineNumber;
        errLog.Message__c = message;
        errLog.StackTrace__c = stackTraceString;
        errLog.Class_Name__c = className;
        errLog.Method_Name__c = methodName;
        insert errLog;
    }
}