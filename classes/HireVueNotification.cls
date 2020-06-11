@RestResource(urlMapping='/hirevuenotification/*')
global without sharing class HireVueNotification {
    @HttpPost
    global static void handlePost() {
        HireVueConnector connector = new HireVueConnector();
        try {
        	Set<String> st_EventsToProcess = new Set<String> {
                HireVueConstants.EVENT_TYPE_INTERVIEW_FINISHED,
                HireVueConstants.EVENT_TYPE_RATING_SUBMITTED,
                HireVueConstants.EVENT_TYPE_DECISION_SUBMITTED   
            };
            Set<String> st_ScreeningStatusToProcess = new Set<String> {
                HireVueConstants.STATUS_SCREENED,
                HireVueConstants.STATUS_COMPLETED
            };
            RestRequest req = RestContext.request;
            HireVueObjects.Event evt = (HireVueObjects.Event)JSON.deserialize(req.requestBody.toString(), HireVueObjects.Event.class);
            Screening__c screening;
            if (st_EventsToProcess.contains(evt.eventType) && evt.details.interview_id != null) {
                try {
                	screening = [SELECT id, Evaluation_Link__c FROM Screening__c WHERE HireVue_Interview_Id__c = :String.valueOf(evt.details.interview_id) AND ScreenStatus__c IN :st_ScreeningStatusToProcess LIMIT 1];                    
                } catch(Exception ex) { 
                    System.debug(LoggingLevel.INFO, ex.getMessage());
                }
                if (screening != null) {
					if (evt.eventType == HireVueConstants.EVENT_TYPE_INTERVIEW_FINISHED || String.isBlank(screening.Evaluation_Link__c)) {
                        screening.Evaluation_Link__c = connector.mp_HireVueConfigs.get(HireVueConstants.HIREVUE_CONFIG_KEY_BASE_URL)+'/evaluate/interview/'+evt.details.interview_id+'/';
                        update screening;
                        updateAverageRatingOnSFScreeningRecord(screening.Id);
                    } else if (String.isNotBlank(screening.Evaluation_Link__c)) {
                        updateAverageRatingOnSFScreeningRecord(screening.Id);
                    }                    
                }
            }    
        } catch(Exception ex) {
            connector.createErrorLog('HireVue Notification', ex.getLineNumber(), ex.getMessage(), ex.getStackTraceString(), HireVueConstants.CLASS_HIREVUENOTIFICATION, 'handlePost');        
        }
    }
    
    @future(callout=true)
    public static void updateAverageRatingOnSFScreeningRecord(Id screeningId) {
        HireVueAPI.SaveResult rslt = new HireVueAPI.SaveResult();
        rslt.isSuccess = true;
        Screening__c screening;
        String message;
        HireVueconnector connector = new HireVueconnector();
        try {
            screening = [
                SELECT
                	Name, ScreenDate__c, Hirevue_Position_Id__c, HireVue_Interview_Id__c, Screener__r.Email
                FROM
                	Screening__c
                WHERE
                	Id = :screeningId
            ];
            HireVueAPI.QueryResult candidateQryRslt = connector.getCandidateAttachedToPostion(screening.Hirevue_Position_Id__c, screening.HireVue_Interview_Id__c);
            if(!candidateQryRslt.isSuccess) {
                message = 'Candidate fetch failed : error-code : '+candidateQryRslt.errorCode+', error-message : '+candidateQryRslt.errorMessage;
                connector.createErrorLog(HireVueConstants.MSG_EVALUATION_EXTRACTION + '('+screening.Name+')', null, message, message, HireVueConstants.CLASS_HIREVUENOTIFICATION, HireVueConstants.METHOD_UPDATE_AVERAGE_RATING);
                return;
            }
            HireVueObjects.Candidate candidate = (HireVueObjects.Candidate)candidateQryRslt.data;
            Screening__c screeningToUpdate = new Screening__c();
            screeningToUpdate.Id = screening.Id;
            if (candidate.video != null && candidate.video.downloadUrls != null && candidate.video.downloadUrls.mp4 != null) {
                screeningToUpdate.HireVue_Interview_Recording_Download_URL__c = candidate.video.downloadUrls.mp4;
            }
            Decimal rating;
            String decision;
            if (candidate.evaluations != null && !candidate.evaluations.isEmpty()) {
                for (HireVueObjects.Evaluation eval : candidate.evaluations) {
                    if (eval.evaluator.username == screening.Screener__r.Email) {
                        rating = eval.averageRating;
                        if (HireVueConstants.DECISION_VALUES_MAPPING.containsKey(eval.decision)) {
                            decision = HireVueConstants.DECISION_VALUES_MAPPING.get(eval.decision);
                        }
                        break;
                    }
                }
            }
            String evaluatorComment = '';
            HireVueAPI.QueryResult commentsQryRslt = connector.getCommentsGivenByEvaluator(screening.Hirevue_Position_Id__c, screening.HireVue_Interview_Id__c);
            if(!commentsQryRslt.isSuccess) {
                message = 'Comment fetch failed : error-code : '+commentsQryRslt.errorCode+', error-message : '+commentsQryRslt.errorMessage;
                connector.createErrorLog(HireVueConstants.MSG_EVALUATION_EXTRACTION +'('+screening.Name+')', null, message, message, HireVueConstants.CLASS_HIREVUENOTIFICATION, HireVueConstants.METHOD_UPDATE_AVERAGE_RATING);
            }
            List<HireVueObjects.Comment> lst_Comments = (List<HireVueObjects.Comment>)commentsQryRslt.data;
            if (!lst_Comments.isEmpty()) {
                for (HireVueObjects.Comment cmt : lst_Comments) {
                    if (cmt.author != null && cmt.author.username == screening.Screener__r.Email) {
                        evaluatorComment = cmt.text;
                        break;
                    }                    
                }
            }
            screeningToUpdate.Average_Rating__c = rating;
            screeningToUpdate.Decision__c = decision;
            screeningToUpdate.Evaluator_Comments__c = evaluatorComment;
            update screeningToUpdate;
        } catch(Exception ex) {
            connector.createErrorLog(HireVueConstants.MSG_EVALUATION_EXTRACTION +'('+screening.Name+')', ex.getLineNumber(), ex.getMessage(), ex.getStackTraceString(), HireVueConstants.CLASS_HIREVUENOTIFICATION, HireVueConstants.METHOD_UPDATE_AVERAGE_RATING);
        }
    }
}