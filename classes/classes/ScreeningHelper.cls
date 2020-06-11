public with sharing class ScreeningHelper {
    public ScreeningHelper() {}
    public static void afterUpdate(Map<Id, Screening__c> newScreeningMap, Map<Id, Screening__c> oldScreeningMap) {
        processRecordsForHireVue(newScreeningMap, oldScreeningMap);
    }
    
    public static void afterInsert(Map<Id, Screening__c> newScreeningMap, Map<Id, Screening__c> oldScreeningMap) {
        processRecordsForHireVue(newScreeningMap, oldScreeningMap);
    }
    
    public static void processRecordsForHireVue(Map<Id, Screening__c> newScreeningMap, Map<Id, Screening__c> oldScreeningMap) {
        for (Screening__c screening : [
            SELECT 
                Id, ScreenStatus__c, HireVue_Interview_Id__c, Hirevue_Position_Id__c, ScreenDate__c, ScreenType__c, Screener__c, Screener__r.Email 
            FROM 
                Screening__c 
            WHERE 
                Id IN: newScreeningMap.keySet() AND
                ScreenType__c =: HireVueConstants.TYPE_VIDEO AND  
                ScreenDate__c != null AND
                Screener__r.Hirevue_Position_Id__c != null   
        ]) {
            if ((screening.ScreenStatus__c == HireVueConstants.STATUS_SCREENED) && String.isBlank(screening.HireVue_Interview_Id__c)) {
                createCandidateInHireVue(screening.Id);
            } else if (String.isNotBlank(screening.HireVue_Interview_Id__c) && oldScreeningMap != null) {
                if ((screening.Screener__c != oldScreeningMap.get(screening.Id).Screener__c)) {
                    addEvaluatorToPostion(screening.Id); 
                } else if ((screening.ScreenStatus__c == HireVueConstants.STATUS_CANCELLED || screening.ScreenStatus__c == HireVueConstants.STATUS_RESCHEDULED) && (screening.ScreenStatus__c != oldScreeningMap.get(screening.Id).ScreenStatus__c)) {
                    deleteCandidateFromPostion(screening.Id);
                }                    
            }                          
        }
    }
    
    @future(callout=true)
    public static void createCandidateInHireVue(Id screeningId) {
        String message;
        Screening__c screening;
        HireVueconnector connector = new HireVueconnector();
        try {
            screening = [
                SELECT
                    Name, ScreenDate__c, Screener__r.Hirevue_Position_Id__c, Screener__r.Email, Screener__r.TimeZoneSidKey,
                    Candidate__c, Candidate__r.FirstName, Candidate__r.LastName, Candidate__r.Email, Candidate__r.Phone
                FROM
                    Screening__c
                WHERE
                    Id = :screeningId
            ];
            HireVueAPI.LoginResult loginRslt = connector.getLoginCredentials(screening.Screener__r.Email);
            connector.mp_Credentials = loginRslt.mp_Credentials;
            if(!loginRslt.isSuccess) {
                message = 'User login Failed for username('+screening.Screener__r.Email+'):'+ connector.constructErrorMesage(loginRslt.errorCode, loginRslt.errorMessage);
                connector.createErrorLog(HireVueConstants.MSG_CANDIDATE_CREATION+'('+screening.Name+')', null, message, message, HireVueConstants.CLASS_SCREENINGHELPER, 'createCandidateInHireVue');
                return;
            }
            HireVueObjects.Candidate candidate = new HireVueObjects.Candidate();
            candidate.firstName = screening.Candidate__r.FirstName;
            candidate.lastName = screening.Candidate__r.LastName;
            candidate.email = screening.Candidate__r.Email;
            candidate.phone = screening.Candidate__r.Phone;
            candidate.durationMinutes = Integer.valueOf(connector.mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_INTERVIEW_DURATION));
            candidate.startTime = String.valueOf(screening.ScreenDate__c);
            candidate.timezone = screening.Screener__r.TimeZoneSidKey;
            HireVueAPI.SaveResult candidateSaveRst = connector.createAndAssignCandidateToPostion(screening.Screener__r.Hirevue_Position_Id__c, screening.Screener__r.Email, candidate);
            if(!candidateSaveRst.isSuccess) {
                message = 'Candidate Creation Failed for position('+screening.Screener__r.Hirevue_Position_Id__c+'):' + connector.constructErrorMesage(candidateSaveRst.errorCode, candidateSaveRst.errorMessage);
                connector.createErrorLog(HireVueConstants.MSG_CANDIDATE_CREATION+'('+screening.Name+')', null, message, message, HireVueConstants.CLASS_SCREENINGHELPER, 'createCandidateInHireVue');
                return;
            }
            HireVueAPI.QueryResult candidateQryRslt = connector.getCandidateAttachedToPostion(screening.Screener__r.Hirevue_Position_Id__c, candidateSaveRst.recordId);
            if(!candidateQryRslt.isSuccess) {
                message = 'Candidate fetch failed for position('+screening.Screener__r.Hirevue_Position_Id__c+'):' + connector.constructErrorMesage(candidateQryRslt.errorCode, candidateQryRslt.errorMessage);
                connector.createErrorLog(HireVueConstants.MSG_CANDIDATE_CREATION+'('+screening.Name+')', null, message, message, HireVueConstants.CLASS_SCREENINGHELPER, 'createCandidateInHireVue');
                return;
            }
            candidate = (HireVueObjects.Candidate)candidateQryRslt.data;
            update new Screening__c(
                Id = screeningId,
               	Interviewer_Interview_Link__c = connector.mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL)+HireVueConstants.PATH_INTERVIEWS+candidate.code+'/manager/'+candidate.myEvaluation.participantCode+'/#/',
                HireVue_Interview_Id__c = candidateSaveRst.recordId,
                Hirevue_Position_Id__c = screening.Screener__r.Hirevue_Position_Id__c,
                Candidate_Interview_Link__c = connector.mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL)+HireVueConstants.PATH_INTERVIEWS+candidate.code+'/candidate/'
            );
        } catch(Exception ex) {
            connector.createErrorLog(HireVueConstants.MSG_CANDIDATE_CREATION+'('+screening.Name+')', ex.getLineNumber(), ex.getMessage(), ex.getStackTraceString(), HireVueConstants.CLASS_SCREENINGHELPER, 'createCandidateInHireVue');
        }
    }
    @future(callout=true)
    public static void addEvaluatorToPostion(Id screeningId) {
        Screening__c screening;
        String message;
        HireVueconnector connector = new HireVueconnector();
        try {
            screening = [
                SELECT
                    Name, Hirevue_Position_Id__c, HireVue_Interview_Id__c, Screener__r.Email
                FROM
                    Screening__c
                WHERE
                    Id = :screeningId
            ];
            HireVueAPI.SaveResult svRslt = connector.bindEvaluatorsToPostion(screening.Hirevue_Position_Id__c, screening.Screener__r.Email);
            if(!svRslt.isSuccess && svRslt.errorCode != HireVueConstants.ERROR_DUPLICATE_EVALUATOR) {
                message = HireVueConstants.MSG_EVALUATION_ASSIGNMENT_FAILED+'('+screening.HireVue_Interview_Id__c+'):' + connector.constructErrorMesage(svRslt.errorCode, svRslt.errorMessage);
                connector.createErrorLog(HireVueConstants.MSG_CANDIDATE_CHANGE+'('+screening.Name+')', null, message, message, HireVueConstants.CLASS_SCREENINGHELPER, 'addEvaluatorToPostion');
                return;
            }
            svRslt = connector.assignEvaluatorToInterview(screening.Hirevue_Position_Id__c, screening.HireVue_Interview_Id__c, screening.Screener__r.Email);
            if(!svRslt.isSuccess) {
                message = HireVueConstants.MSG_EVALUATION_ASSIGNMENT_FAILED+'('+screening.HireVue_Interview_Id__c+'):' + connector.constructErrorMesage(svRslt.errorCode, svRslt.errorMessage);
                connector.createErrorLog(HireVueConstants.MSG_CANDIDATE_CHANGE+'('+screening.Name+')', null, message, message, HireVueConstants.CLASS_SCREENINGHELPER, 'addEvaluatorToPostion');
                return;
            }
        } catch(Exception ex) {
            connector.createErrorLog(HireVueConstants.MSG_CANDIDATE_CHANGE+'('+screening.Name+')', ex.getLineNumber(), ex.getMessage(), ex.getStackTraceString(), HireVueConstants.CLASS_SCREENINGHELPER, 'addEvaluatorToPostion');
        }
    }
    @future(callout=true)
    public static void deleteCandidateFromPostion(Id screeningId) {
        Screening__c screening;
        String message;
        HireVueconnector connector = new HireVueconnector();
        try {
             screening = [
                SELECT
                    Name, Hirevue_Position_Id__c, HireVue_Interview_Id__c, Screener__r.Email
                FROM
                    Screening__c
                WHERE
                    Id = :screeningId
            ];
            HireVueAPI.LoginResult loginRslt = connector.getLoginCredentials(screening.Screener__r.Email);
            connector.mp_Credentials = loginRslt.mp_Credentials;
            if(!loginRslt.isSuccess) {
                message = 'User login Failed for username('+screening.Screener__r.Email+'):'+ connector.constructErrorMesage(loginRslt.errorCode, loginRslt.errorMessage);
                connector.createErrorLog(HireVueConstants.MSG_CANDIDATE_DELETION+'('+screening.Name+')', null, message, message, HireVueConstants.CLASS_SCREENINGHELPER, 'deleteCandidateFromPostion');
                return;
            }
            HireVueObjects.Candidate candidate = new HireVueObjects.Candidate();
            candidate.isArchived = true;
            HireVueAPI.SaveResult candidateUpdateRslt = connector.updateCandidate(screening.Hirevue_Position_Id__c, screening.HireVue_Interview_Id__c, candidate);
            if (!candidateUpdateRslt.isSuccess) {
                message = 'Failed while archiving a candidate record('+screening.HireVue_Interview_Id__c+'):' + connector.constructErrorMesage(candidateUpdateRslt.errorCode, candidateUpdateRslt.errorMessage);
                connector.createErrorLog(HireVueConstants.MSG_CANDIDATE_DELETION+'('+screening.Name+')', null, message, message, HireVueConstants.CLASS_SCREENINGHELPER, 'deleteCandidateFromPostion');
            }
        } catch(Exception ex) {
            connector.createErrorLog(HireVueConstants.MSG_CANDIDATE_DELETION+'('+screening.Name+')', ex.getLineNumber(), ex.getMessage(), ex.getStackTraceString(), HireVueConstants.CLASS_SCREENINGHELPER, 'deleteCandidateFromPostion');
        }
    }
}